# bg2fg errors correctly

    Code
      bg2fg("waka")
    Condition
      Error:
      ! Unknown colour name `waka`

---

    Code
      bg2fg(sum)
    Condition
      Error:
      ! cannot coerce type 'builtin' to vector of type 'character'

