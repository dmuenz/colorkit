#include <R.h>
#include <Rinternals.h>
#include <R_ext/Rdynload.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include <stdint.h>

/* ── Hash table (persistent, lives for session) ────────────────────── */

/*
 * Simple hash table for color name -> hex lookup.
 * Open addressing with linear probing, using FNV-1a hash.
 */

typedef struct {
  char *key;     /* normalized color name (malloc'd) */
  SEXP  value;   /* CHARSXP (R_PreserveObject'd) */
} ht_entry;

typedef struct {
  ht_entry *entries;
  int capacity;
  int size;
} hash_table;

static unsigned int fnv1a(const char *s) {
  unsigned int h = 2166136261u;
  while (*s) {
    h ^= (unsigned char)*s++;
    h *= 16777619u;
  }
  return h;
}

static void ht_init(hash_table *ht, int capacity) {
  ht->capacity = capacity;
  ht->size = 0;
  ht->entries = (ht_entry *)calloc(capacity, sizeof(ht_entry));
  if (!ht->entries) error("Failed to allocate color name hash table");
}

static void ht_insert(hash_table *ht, const char *key, SEXP value) {
  unsigned int idx = fnv1a(key) % ht->capacity;
  while (ht->entries[idx].key != NULL) {
    if (strcmp(ht->entries[idx].key, key) == 0) {
      R_ReleaseObject(ht->entries[idx].value);
      ht->entries[idx].value = value;
      R_PreserveObject(value);
      return;
    }
    idx = (idx + 1) % ht->capacity;
  }
  ht->entries[idx].key   = strdup(key);
  ht->entries[idx].value = value;
  R_PreserveObject(value);
  ht->size++;
}

static SEXP ht_lookup(const hash_table *ht, const char *key) {
  unsigned int idx = fnv1a(key) % ht->capacity;
  while (ht->entries[idx].key != NULL) {
    if (strcmp(ht->entries[idx].key, key) == 0) {
      return ht->entries[idx].value;
    }
    idx = (idx + 1) % ht->capacity;
  }
  return R_NilValue;
}

static void ht_destroy(hash_table *ht) {
  if (ht->entries) {
    for (int i = 0; i < ht->capacity; ++i) {
      if (ht->entries[i].key) {
        free(ht->entries[i].key);
        R_ReleaseObject(ht->entries[i].value);
      }
    }
    free(ht->entries);
    ht->entries = NULL;
  }
  ht->capacity = 0;
  ht->size = 0;
}

/* ── Per-call CHARSXP cache (input pointer -> output CHARSXP) ──────── */

typedef struct {
  SEXP *keys;
  SEXP *values;
  int mask;  /* capacity - 1; capacity is always a power of 2 */
} sexp_cache;

static void cache_init(sexp_cache *c, int n) {
  int cap = 16;
  while (cap < n * 2) cap *= 2;
  c->mask = cap - 1;
  c->keys   = (SEXP *)R_alloc(cap, sizeof(SEXP));
  c->values = (SEXP *)R_alloc(cap, sizeof(SEXP));
  memset(c->keys, 0, cap * sizeof(SEXP));
}

static SEXP cache_get(const sexp_cache *c, SEXP key) {
  unsigned int idx = ((unsigned int)(uintptr_t)key * 2654435761u) & c->mask;
  while (c->keys[idx] != NULL) {
    if (c->keys[idx] == key) return c->values[idx];
    idx = (idx + 1) & c->mask;
  }
  return R_NilValue;
}

static void cache_put(sexp_cache *c, SEXP key, SEXP value) {
  unsigned int idx = ((unsigned int)(uintptr_t)key * 2654435761u) & c->mask;
  while (c->keys[idx] != NULL) {
    if (c->keys[idx] == key) {
      c->values[idx] = value;
      return;
    }
    idx = (idx + 1) & c->mask;
  }
  c->keys[idx] = key;
  c->values[idx] = value;
}

/* ── Persistent state ──────────────────────────────────────────────── */

static hash_table color_ht = {NULL, 0, 0};
static SEXP transparent_charsxp = NULL;

/* Called from .onLoad via .Call */
SEXP col2hex_init(SEXP color_names, SEXP color_hexes) {
  int n = LENGTH(color_names);
  char buf[64];

  /* Tear down any previous table (e.g. if called twice) */
  if (color_ht.entries) {
    ht_destroy(&color_ht);
  }

  ht_init(&color_ht, n * 2 + 1);

  for (int i = 0; i < n; ++i) {
    const char *name_i = CHAR(STRING_ELT(color_names, i));
    const char *hex_i  = CHAR(STRING_ELT(color_hexes, i));

    int name_len = (int)strlen(name_i);
    if (name_len >= (int)sizeof(buf)) continue; /* skip absurdly long names */
    memcpy(buf, name_i, name_len + 1);

    /* Normalize in place: lowercase + strip spaces */
    int write = 0;
    for (int r = 0; r < name_len; ++r) {
      if (buf[r] != ' ') {
        buf[write] = (buf[r] >= 'A' && buf[r] <= 'Z')
          ? buf[r] - 'A' + 'a'
          : buf[r];
        write++;
      }
    }
    buf[write] = '\0';

    SEXP hex_charsxp = mkChar(hex_i);
    ht_insert(&color_ht, buf, hex_charsxp);
  }

  /* Pre-intern the transparent constant */
  if (transparent_charsxp) {
    R_ReleaseObject(transparent_charsxp);
  }
  transparent_charsxp = mkChar("#FFFFFF00");
  R_PreserveObject(transparent_charsxp);

  return R_NilValue;
}

/* Called from .onUnload via .Call */
SEXP col2hex_cleanup(void) {
  ht_destroy(&color_ht);
  if (transparent_charsxp) {
    R_ReleaseObject(transparent_charsxp);
    transparent_charsxp = NULL;
  }
  return R_NilValue;
}

/* ── Hex / name helpers ────────────────────────────────────────────── */

/* Check if a character is a valid hex digit (after uppercasing) */
static int is_hex_digit(char c) {
  return (c >= '0' && c <= '9') || (c >= 'A' && c <= 'F');
}

/*
 * Normalize a hex color string in place in buf (null-terminated).
 * Returns the final length (excluding '\0'), or 0 on failure.
 * buf must have room for at least 10 chars (#RRGGBBAA\0).
 *
 *   1. Uppercase a-f -> A-F
 *   2. Validate all chars after '#' are hex digits
 *   3. Expand shorthand (#RGB -> #RRGGBB, #RGBA -> #RRGGBBAA)
 *   4. Trim trailing FF alpha
 */
static int normalize_hex(char *buf, int len) {
  int i;

  if (len != 4 && len != 5 && len != 7 && len != 9) return 0;

  /* Uppercase and validate hex digits after '#' */
  for (i = 1; i < len; ++i) {
    if (buf[i] >= 'a' && buf[i] <= 'f') {
      buf[i] = buf[i] - 'a' + 'A';
    }
    if (!is_hex_digit(buf[i])) return 0;
  }

  /* Expand shorthand: #RGB -> #RRGGBB, #RGBA -> #RRGGBBAA */
  if (len == 4 || len == 5) {
    /* Work backwards to expand in place without a temp buffer.
       buf has room for 10 chars, so this is safe. */
    int new_len = len * 2 - 1;
    buf[new_len] = '\0';
    for (i = len - 1; i >= 1; --i) {
      buf[i * 2]     = buf[i];
      buf[i * 2 - 1] = buf[i];
    }
    /* buf[0] is still '#' */
    len = new_len;
  }

  /* Trim trailing "FF" alpha */
  if (len == 9 && buf[7] == 'F' && buf[8] == 'F') {
    buf[7] = '\0';
    len = 7;
  }

  return len;
}

/*
 * Normalize a color name in place: lowercase and strip spaces.
 * Returns the new length.
 */
static int normalize_name(char *buf, int len) {
  int read, write = 0;
  for (read = 0; read < len; ++read) {
    if (buf[read] != ' ') {
      buf[write++] = (buf[read] >= 'A' && buf[read] <= 'Z')
        ? buf[read] - 'A' + 'a'
        : buf[read];
    }
  }
  buf[write] = '\0';
  return write;
}

/* ── Main function ─────────────────────────────────────────────────── */

SEXP col2hex_c(SEXP col, SEXP palette_hexes) {
  int n         = LENGTH(col);
  int n_palette = LENGTH(palette_hexes);
  char buf[64]; /* working buffer for normalization */

  if (!color_ht.entries) {
    error("Color name table not initialized. Was .onLoad called?");
  }

  /* Allocate output */
  SEXP out = PROTECT(allocVector(STRSXP, n));

  /* Per-call cache: input CHARSXP -> output CHARSXP */
  sexp_cache cache;
  cache_init(&cache, n < 256 ? 256 : n);

  for (int i = 0; i < n; ++i) {
    SEXP elem = STRING_ELT(col, i);

    /* 1. Handle NA */
    if (elem == NA_STRING) {
      SET_STRING_ELT(out, i, transparent_charsxp);
      continue;
    }

    /* 2. Per-call cache hit: skip all processing */
    SEXP cached = cache_get(&cache, elem);
    if (cached != R_NilValue) {
      SET_STRING_ELT(out, i, cached);
      continue;
    }

    const char *val = CHAR(elem);
    int len = LENGTH(elem);

    if (len == 0) {
      error("Invalid color value: '%s'", val);
    }

    SEXP result;
    char first = val[0];

    /* 3. Hex path: must start with '#' */
    if (first == '#') {
      if (len >= (int)sizeof(buf)) {
        error("Invalid hexadecimal color: '%s'", val);
      }
      memcpy(buf, val, len + 1);
      int new_len = normalize_hex(buf, len);
      if (new_len > 0) {
        result = mkChar(buf);
        SET_STRING_ELT(out, i, result);
        cache_put(&cache, elem, result);
        continue;
      } else {
        error("Invalid hexadecimal color: '%s'", val);
      }
    }

    /* 4. Numeric path: first character must be a digit */
    if (first >= '0' && first <= '9') {
      /* Read until the first space (or end of string) */
      int end = 0;
      while (end < len && val[end] != ' ') ++end;

      /* Copy the numeric portion into buf */
      if (end >= (int)sizeof(buf)) {
        error("Invalid numeric color: '%s'", val);
      }
      memcpy(buf, val, end);
      buf[end] = '\0';

      char *endptr = NULL;
      double num = strtod(buf, &endptr);

      if (endptr == buf || isnan(num) || isinf(num)) {
        error("Invalid numeric color: '%s'", val);
      }

      /* > 0 and < 1 -> transparent */
      if (num > 0.0 && num < 1.0) {
        SET_STRING_ELT(out, i, transparent_charsxp);
        cache_put(&cache, elem, transparent_charsxp);
        continue;
      }

      /* 0 or negative -> invalid */
      if (num <= 0.0) {
        error("Invalid numeric color: '%s'", val);
      }

      /* Truncate to integer for palette index (1-based, recycled) */
      int idx = (int)num;
      if (idx < 1) {
        error("Invalid numeric color: '%s'", val);
      }

      int pal_idx = (idx - 1) % n_palette;
      result = STRING_ELT(palette_hexes, pal_idx);
      SET_STRING_ELT(out, i, result);
      cache_put(&cache, elem, result);
      continue;
    }

    /* 5. Color name path: normalize (lowercase + strip spaces) and look up */
    if (len >= (int)sizeof(buf)) {
      error("Invalid color name: '%s'", val);
    }
    memcpy(buf, val, len + 1);
    normalize_name(buf, len);

    result = ht_lookup(&color_ht, buf);
    if (result != R_NilValue) {
      SET_STRING_ELT(out, i, result);
      cache_put(&cache, elem, result);
      continue;
    }

    error("Invalid color name: '%s'", val);
  }

  UNPROTECT(1);
  return out;
}

/* ── Registration ──────────────────────────────────────────────────── */

static const R_CallMethodDef CallEntries[] = {
  {"col2hex_c",       (DL_FUNC) &col2hex_c,        2},
  {"col2hex_init",    (DL_FUNC) &col2hex_init,     2},
  {"col2hex_cleanup", (DL_FUNC) &col2hex_cleanup,  0},
  {NULL, NULL, 0}
};

void R_init_colorkit(DllInfo *dll) {
  R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
  R_forceSymbols(dll, TRUE);
}
