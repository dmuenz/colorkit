
<!-- README.md is generated from README.Rmd. Please edit only the Rmd file. -->

<!-- Use `devtools::build_readme()` to render README.Rmd into README.md. -->

# colorkit <img src="man/figures/logo.png" align="right" height="150" alt="" />

<!-- badges: start -->

<!-- badges: end -->

colorkit provides several utility functions for working with colors in
R. There are tools for converting colors to hexadecimal strings,
selecting contrasting foreground colors for a given background, randomly
sampling colors, and displaying colors visually as plotted cells or
printed console output.

This package is meant to complement and not compete with excellent
packages like scales and farver that provide robust color manipulation
tools.

## Installation

You can install the development version of colorkit from GitHub like so:

``` r
# install.packages("pak")
pak::pkg_install("dmuenz/colorkit")
```

## Examples

Here are some examples of how you might use colorkit. First, load the
package.

``` r
library(colorkit)
```

### Visualizing color palettes

To visualize color palettes, you can use either `plot_color()` or
`print_color()`. The former prints to the graphics device, the latter to
the console. Both functions accept either a vector, matrix, or list of
vectors and matrices all containing R colors. Colors can be specified
using any of the standard R color specifications.

Here’s an example of plotting two palettes with `plot_color()`.

``` r
plot_color(list(
  rainbow = rainbow(6),
  hcl.colors = hcl.colors(6)
))
```

<img src="man/figures/README-plot-color-1.png" alt="" width="100%" />

And here are the same palettes printed to the console with
`print_color()`. For `print_color()` to work best, your console must
support 24-bit colors; that way it can display all 256^3 colors in the
hex RGB color space (i.e., colors of the form `"#rrggbb"`).

``` r
print_color(list(
  rainbow = rainbow(6),
  hcl.colors = hcl.colors(6)
))
```

<img src="man/figures/README-/print-color.svg" alt="" width="100%" />

## Selecting contrasting foreground colors

In the above examples, note that some color codes are printed in black
(like `#FFFF00`) while others are printed in white (`#0000FF`). The text
colors were chosen by `bg2fg()` to provide good contrast with the
background, according to the methods defined by WCAG 2.x
(<https://www.w3.org/WAI/GL/wiki/Contrast_ratio>,
<https://www.w3.org/WAI/GL/wiki/Relative_luminance>).

You can easily use `bg2fg()` for your own displays. Here’s an example of
putting text within the bars of a bar plot:

``` r
library(ggplot2)
bg <- scales::pal_viridis()(3)

penguins |>
  dplyr::count(species) |>
  ggplot(aes(species, n, fill = species)) +
  geom_col() +
  geom_text(aes(label = n, color = species), vjust = 1.2) +
  scale_fill_manual(values = bg) +
  scale_color_manual(values = bg2fg(bg))
```

<img src="man/figures/README-bg2fg-1.png" alt="" width="100%" />
