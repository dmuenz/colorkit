# Convert colors to hex color strings

`col2hex()` takes a vector/array of R colors (e.g., `c("red", "#fac")`)
and standardizes them as hex strings (e.g., `c("#FF0000", "#FFAACC")`).
The standardized hex strings will always be uppercase and will have
either 6 or 8 hex digits, depending for each color on whether it's
opaque.

## Usage

``` r
col2hex(col)
```

## Arguments

- col:

  A vector/array of R colors. Can be character or numeric.

## Value

A vector/array with the same dimensions as `col`, where every element of
`col` has been converted to a hex string. If the input is a raster
matrix, then the output will be a raster matrix too.

## Details

This function may be useful for programmatically creating code in a
different language, like HTML/CSS. For example, "violetred" is a valid R
color but is not a valid HTML/CSS color. So you could generate valid
code like so:

    sprintf("<div style='background:%s;'></div>", col2hex("violetred"))

Another use case is when drawing [raster
objects](https://rdrr.io/r/grid/grid.raster.html) with the `grid`
package. If a raster object is specified with R color names, it can
usually be drawn much faster if first converted to hex strings. Compare,
for example, the rendering time for the following two calls to
[`grid::grid.raster()`](https://rdrr.io/r/grid/grid.raster.html). The
latter is noticeably faster in the author's testing.

    # big matrix of color names
    cols <- rand_color(1e6, hex = FALSE) |> matrix(ncol = 1e3)

    # draw the matrix as a raster object
    grid::grid.newpage()
    grid::grid.raster(cols)

    # draw it again, but first convert color names to hex strings
    grid::grid.newpage()
    grid::grid.raster(col2hex(cols))

## See also

[`bg2fg()`](https://dmuenz.github.io/colorkit/reference/bg2fg.md) for
choosing a foreground color to contrast with a background color.

## Examples

``` r
col2hex(1:8)
#> [1] "#000000" "#DF536B" "#61D04F" "#2297E6" "#28E2E5" "#CD0BBC" "#F5C710"
#> [8] "#9E9E9E"
col2hex(c("red", "#fac", "1", NA))
#> [1] "#FF0000"   "#FFAACC"   "#000000"   "#FFFFFF00"
```
