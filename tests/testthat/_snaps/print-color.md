# print_color works

    Code
      print_color(pal, num_colors = 256^3)
    Output
      (4 colors)
      [38;2;248;248;248m[48;2;0;0;0mblack    [49m[39m [38;2;0;0;0m[48;2;223;83;107m#DF536B  [49m[39m [38;2;0;0;0m[48;2;64;224;208mturquoise[49m[39m [38;2;0;0;0m[48;2;34;151;230m#2297E6  [49m[39m

---

    Code
      print_color(pal, num_colors = 256)
    Output
      (4 colors)
      [38;5;255m[48;5;232mblack    [49m[39m [38;5;232m[48;5;204m#DF536B  [49m[39m [38;5;232m[48;5;86mturquoise[49m[39m [38;5;232m[48;5;39m#2297E6  [49m[39m

---

    Code
      print_color(pal, num_colors = 8)
    Output
      (4 colors)
      [37m[40mblack    [49m[39m [30m[41m#DF536B  [49m[39m [30m[46mturquoise[49m[39m [30m[46m#2297E6  [49m[39m

---

    Code
      print_color(pal, quote = TRUE, num_colors = 256^3)
    Output
      (4 colors)
      [38;2;248;248;248m[48;2;0;0;0m"black"    [49m[39m [38;2;0;0;0m[48;2;223;83;107m"#DF536B"  [49m[39m [38;2;0;0;0m[48;2;64;224;208m"turquoise"[49m[39m [38;2;0;0;0m[48;2;34;151;230m"#2297E6"  [49m[39m

---

    Code
      print_color(pal, width = 1, num_colors = 256^3)
    Output
      (4 colors)
      [48;2;0;0;0m [48;2;223;83;107m [48;2;64;224;208m [48;2;34;151;230m [49m

---

    Code
      print_color(pal, gap = 2, num_colors = 256^3)
    Output
      (4 colors)
      [38;2;248;248;248m[48;2;0;0;0mblack    [49m[39m  [38;2;0;0;0m[48;2;223;83;107m#DF536B  [49m[39m  [38;2;0;0;0m[48;2;64;224;208mturquoise[49m[39m  [38;2;0;0;0m[48;2;34;151;230m#2297E6  [49m[39m

---

    Code
      print_color(pal_mat, num_colors = 256^3)
    Output
      (2 x 2 = 4 colors)
      [38;2;248;248;248m[48;2;0;0;0mblack    [49m[39m [38;2;0;0;0m[48;2;64;224;208mturquoise[49m[39m
      [38;2;0;0;0m[48;2;223;83;107m#DF536B  [49m[39m [38;2;0;0;0m[48;2;34;151;230m#2297E6  [49m[39m

---

    Code
      print_color(pal_mat, quote = TRUE, num_colors = 256^3)
    Output
      (2 x 2 = 4 colors)
      [38;2;248;248;248m[48;2;0;0;0m"black"    [49m[39m [38;2;0;0;0m[48;2;64;224;208m"turquoise"[49m[39m
      [38;2;0;0;0m[48;2;223;83;107m"#DF536B"  [49m[39m [38;2;0;0;0m[48;2;34;151;230m"#2297E6"  [49m[39m

---

    Code
      print_color(pal_mat, width = 1, num_colors = 256^3)
    Output
      (2 x 2 = 4 colors)
      [48;2;0;0;0m [48;2;64;224;208m [49m
      [48;2;223;83;107m [48;2;34;151;230m [49m

---

    Code
      print_color(pal_mat, gap = 2, num_colors = 256^3)
    Output
      (2 x 2 = 4 colors)
      [38;2;248;248;248m[48;2;0;0;0mblack    [49m[39m  [38;2;0;0;0m[48;2;64;224;208mturquoise[49m[39m
      [38;2;0;0;0m[48;2;223;83;107m#DF536B  [49m[39m  [38;2;0;0;0m[48;2;34;151;230m#2297E6  [49m[39m

---

    Code
      print_color(stats::setNames(list(pal, pal_mat, "red", "blue"), c("",
        "syntactic", "non-syntactic", NA)), num_colors = 256^3)
    Output
      [[1]]
      (4 colors)
      [38;2;248;248;248m[48;2;0;0;0mblack    [49m[39m [38;2;0;0;0m[48;2;223;83;107m#DF536B  [49m[39m [38;2;0;0;0m[48;2;64;224;208mturquoise[49m[39m [38;2;0;0;0m[48;2;34;151;230m#2297E6  [49m[39m
      
      $syntactic
      (2 x 2 = 4 colors)
      [38;2;248;248;248m[48;2;0;0;0mblack    [49m[39m [38;2;0;0;0m[48;2;64;224;208mturquoise[49m[39m
      [38;2;0;0;0m[48;2;223;83;107m#DF536B  [49m[39m [38;2;0;0;0m[48;2;34;151;230m#2297E6  [49m[39m
      
      $`non-syntactic`
      (1 color)
      [38;2;0;0;0m[48;2;255;0;0mred[49m[39m
      
      $<NA>
      (1 color)
      [38;2;248;248;248m[48;2;0;0;255mblue[49m[39m

---

    Code
      print_color(reds1000, max = 10, num_colors = 256^3)
    Output
      (1000 colors)
      [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m
      [38;5;246m# ℹ omitted 990 entries[39m

---

    Code
      print_color(matrix(reds1000, ncol = 50), max = 100, num_colors = 256^3)
    Output
      (20 x 50 = 1000 colors)
      [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m
      [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m
      [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m [38;2;0;0;0m[48;2;255;0;0mred[49m[39m
      [38;5;246m# ℹ omitted 17 rows and 30 columns[39m

# print_color errors correctly

    Code
      print_color("waka")
    Condition
      Error in `print_color()`:
      ! `col`: Unknown colour name `waka`

---

    Code
      print_color("#oops")
    Condition
      Error in `print_color()`:
      ! `col`: Invalid hexadecimal digit in `#oops`

---

    Code
      print_color(sum)
    Condition
      Error in `print_color()`:
      ! `col` must be an atomic vector, matrix, or list of atomic vectors and matrices.

---

    Code
      print_color(list(sum))
    Condition
      Error in `print_color()`:
      ! Element 1 of `col` is not a vector or matrix.

---

    Code
      print_color("red", quote = 0)
    Condition
      Error in `print_color()`:
      ! `quote` must be `TRUE` or `FALSE`, not the number 0.

---

    Code
      print_color("red", quote = rep(TRUE, 2))
    Condition
      Error in `print_color()`:
      ! `quote` must be `TRUE` or `FALSE`, not a logical vector.

---

    Code
      print_color("red", width = 0)
    Condition
      Error in `print_color()`:
      ! `width` must be a number >= 1, `NA`, or `NULL`, not the number 0.

---

    Code
      print_color("red", width = rep(1, 2))
    Condition
      Error in `print_color()`:
      ! `width` must be a number >= 1, `NA`, or `NULL`, not a double vector.

---

    Code
      print_color("red", gap = -1)
    Condition
      Error in `print_color()`:
      ! `gap` must be a number >= 0 or `NULL`, not the number -1.

---

    Code
      print_color("red", gap = rep(1, 2))
    Condition
      Error in `print_color()`:
      ! `gap` must be a number >= 0 or `NULL`, not a double vector.

---

    Code
      print_color("red", max = -1)
    Condition
      Error in `print_color()`:
      ! `max` must be a number >= 0 or `NULL`, not the number -1.

---

    Code
      print_color("red", max = rep(1, 2))
    Condition
      Error in `print_color()`:
      ! `max` must be a number >= 0 or `NULL`, not a double vector.

---

    Code
      print_color("red", count = 0)
    Condition
      Error in `print_color()`:
      ! `count` must be `TRUE` or `FALSE`, not the number 0.

---

    Code
      print_color("red", count = rep(TRUE, 2))
    Condition
      Error in `print_color()`:
      ! `count` must be `TRUE` or `FALSE`, not a logical vector.

