# col2hex errors correctly

    Code
      col2hex("waka")
    Condition
      Error in `col2hex()`:
      ! Invalid color name: 'waka'

---

    Code
      col2hex(-1)
    Condition
      Error in `col2hex()`:
      ! Invalid color name: '-1'

---

    Code
      col2hex("#")
    Condition
      Error in `col2hex()`:
      ! Invalid hexadecimal color: '#'

---

    Code
      col2hex("#fa")
    Condition
      Error in `col2hex()`:
      ! Invalid hexadecimal color: '#fa'

---

    Code
      col2hex(sum)
    Condition
      Error:
      ! Colors must be a vector or array of strings or numbers.

