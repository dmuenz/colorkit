# Choose a foreground color (dark or light) to contrast with a background color

Given a background color, `bg2fg()` tells you whether to use a `dark` or
`light` color in the foreground (i.e., for text), so as to maximize
contrast ratio and thus legibility.

## Usage

``` r
bg2fg(bg, dark = "#000000", light = "#F8F8F8")
```

## Arguments

- bg:

  A vector/array of R colors

- dark:

  A single R color; should be a dark color

- light:

  A single R color; should be a light color

## Value

A vector/array with the same dimensions as `bg`, where every element is
either `dark` or `light`.

## Details

Contrast ratio is a function of the luminance of two colors. `bg2fg()`
calculates contrast ratio and luminance according to WCAG 2.x
definitions:

- <https://www.w3.org/WAI/GL/wiki/Contrast_ratio>

- <https://www.w3.org/WAI/GL/wiki/Relative_luminance>

[`plot_color()`](https://dmuenz.github.io/colorkit/reference/plot_color.md)
and
[`print_color()`](https://dmuenz.github.io/colorkit/reference/print_color.md)
both use `bg2fg()` to choose the foreground text color for their
displays.

## See also

[`col2hex()`](https://dmuenz.github.io/colorkit/reference/col2hex.md)
for converting colors to hex strings.

## Examples

``` r
bg2fg(c("red", "black", "white", "purple"))
#> [1] "#000000" "#F8F8F8" "#000000" "#F8F8F8"

# note that bg2fg() is used behind-the-scenes in the following two calls
plot_color(c("red", "black", "white", "purple"))

print_color(c("red", "black", "white", "purple"))
#> (4 colors)
#> red    black  white  purple
```
