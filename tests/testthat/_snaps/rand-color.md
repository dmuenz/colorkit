# rand_color errors correctly

    Code
      rand_color(n = -1)
    Condition
      Error in `rand_color()`:
      ! `n` must be a number >= 0, not the number -1.

---

    Code
      rand_color(hex = -1)
    Condition
      Error in `rand_color()`:
      ! `hex` must be either `TRUE`, `FALSE`, or a number >= 0 and <= 1, not the number -1.

---

    Code
      rand_color(hex = 2)
    Condition
      Error in `rand_color()`:
      ! `hex` must be either `TRUE`, `FALSE`, or a number >= 0 and <= 1, not the number 2.

---

    Code
      rand_color(hex = "a")
    Condition
      Error in `rand_color()`:
      ! `hex` must be either `TRUE`, `FALSE`, or a number >= 0 and <= 1, not the string "a".

---

    Code
      rand_color(alpha = 1)
    Condition
      Error in `rand_color()`:
      ! `alpha` must be `TRUE` or `FALSE`, not the number 1.

