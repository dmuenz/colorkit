# plot_color errors correctly

    Code
      plot_color("waka")
    Condition
      Error in `plot_color()`:
      ! `col`: Unknown colour name `waka`

---

    Code
      plot_color(sum)
    Condition
      Error in `plot_color()`:
      ! `col` must be a vector, matrix, or list of vectors and matrices.

---

    Code
      plot_color(list(sum))
    Condition
      Error in `plot_color()`:
      ! Element 1 of `col` is not a vector or matrix.

---

    Code
      plot_color("red", label = 0)
    Condition
      Error in `plot_color()`:
      ! `label` must be `TRUE` or `FALSE`, not the number 0.

---

    Code
      plot_color("red", label = rep(TRUE, 2))
    Condition
      Error in `plot_color()`:
      ! `label` must be `TRUE` or `FALSE`, not a logical vector.

---

    Code
      plot_color("red", index = 0)
    Condition
      Error in `plot_color()`:
      ! `index` must be `TRUE` or `FALSE`, not the number 0.

---

    Code
      plot_color("red", index = rep(TRUE, 2))
    Condition
      Error in `plot_color()`:
      ! `index` must be `TRUE` or `FALSE`, not a logical vector.

---

    Code
      plot_color("red", border = sum)
    Condition
      Error in `plot_color()`:
      ! `border` must be 1 color or `NULL`.

---

    Code
      plot_color("red", border = rep("black", 2))
    Condition
      Error in `plot_color()`:
      ! `border` must be 1 color or `NULL`.

---

    Code
      plot_color("red", cex_label = sum)
    Condition
      Error in `plot_color()`:
      ! `cex_label` must be a number, not a primitive function.

---

    Code
      plot_color("red", cex_label = rep(1, 2))
    Condition
      Error in `plot_color()`:
      ! `cex_label` must be a number, not a double vector.

---

    Code
      plot_color("red", cex_label = Inf)
    Condition
      Error in `plot_color()`:
      ! `cex_label` must be a number, not `Inf`.

