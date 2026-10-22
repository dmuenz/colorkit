# Visual test for color support in the R console

Determine, by visual inspection, if the R console supports 256^3 true
colors, 256 ANSI colors, or 8 ANSI colors. For each of those color
levels, `console_color_test()` prints both a rainbow and a greyscale
gradient.

- If the gradients for 256^3 true colors appear fairly smooth (without
  banding), then the console supports 256^3 colors.

- If the gradients for 256 ANSI colors appear fairly smooth (though not
  as smooth as the 256^3 true color gradient), then the console supports
  256 colors.

- If the gradients for 8 ANSI colors show 6 distinct rainbow colors in
  addition to black and white, then the console supports 8 colors.

## Usage

``` r
console_color_test()
```

## See also

[`print_color()`](https://dmuenz.github.io/colorkit/reference/print_color.md)
for printing colors in the console.

## Examples

``` r
console_color_test()
#> 256^3 true color test
#> Rainbow:                                                                   
#> Greyscale:                                                                 
#> 
#> 256 ANSI color test
#> Rainbow:                                                                   
#> Greyscale:                                                                 
#> 
#> 8 ANSI color test
#> Rainbow:                                                                   
#> Greyscale:                                                                 
```
