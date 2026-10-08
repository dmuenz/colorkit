# Random sampling of colors

When `hex` is `TRUE` or `1`, `rand_color()` generates a random sample
uniformly distributed over the RGB(A) color space. When `hex` is `FALSE`
or `0`, `rand_color()` generates a random sample uniformly distributed
over distinct R color names. When `hex` is between 0 and 1, the sampling
distribution is a mixture of those two uniform distributions.

## Usage

``` r
rand_color(n = 1, hex = 0.5, alpha = FALSE)
```

## Arguments

- n:

  The number of colors to sample.

- hex:

  Either `TRUE` (meaning sample only hex strings), `FALSE` (meaning
  sample only color names), or a real number from 0 to 1 indicating the
  proportion of colors that should be hex strings (rather than color
  names).

- alpha:

  `TRUE`/`FALSE` for whether hex strings should have a random alpha
  value.

## Value

A character vector of length `n`.

## See also

[`plot_color()`](https://dmuenz.github.io/colorkit/reference/plot_color.md)
and
[`print_color()`](https://dmuenz.github.io/colorkit/reference/print_color.md)
for visualizing the colors.

## Examples

``` r
# random color vector
v <- rand_color(5)
v
#> [1] "#ACCBE4"    "chocolate"  "orangered4" "rosybrown2" "#963E65"   
print_color(v)
#> (5 colors)
#> #ACCBE4    chocolate  orangered4 rosybrown2 #963E65   

# random color matrix
m <- rand_color(6) |> matrix(ncol = 3)
m
#>      [,1]      [,2]      [,3]        
#> [1,] "#FE4C36" "khaki3"  "chartreuse"
#> [2,] "#1781AA" "#4EBD3D" "steelblue4"
print_color(m)
#> (2 x 3 = 6 colors)
#> #FE4C36    khaki3     chartreuse
#> #1781AA    #4EBD3D    steelblue4

# sample hex strings, color names, or a mixture
rand_color(8, hex = TRUE)
#> [1] "#D5FE15" "#EFB4A1" "#A14510" "#031F74" "#D895B7" "#869F80" "#2A095E"
#> [8] "#A208B3"
rand_color(8, hex = FALSE)
#> [1] "gray89"            "gray25"            "lightskyblue3"    
#> [4] "lightgoldenrod1"   "darkseagreen"      "mediumspringgreen"
#> [7] "lavenderblush"     "orangered"        
rand_color(8, hex = 0.5)
#> [1] "#E9953F"    "gray20"     "tomato3"    "#E6F8C0"    "#C38501"   
#> [6] "slategray3" "azure"      "#409227"   
```
