# Print colored cells in the console

Pass `print_color()` R colors, and it will print each color as a colored
rectangle/cell in the console. The background color of the cell will be
the specified color (or a close approximation, depending on how many
colors your console supports). By default, the color string text will be
printed in the foreground of the cell (in a color that contrasts with
the background).

`print_color()` and
[`plot_color()`](https://dmuenz.github.io/colorkit/reference/plot_color.md)
are sister functions that both display color cells. The primary
difference is where the colors are displayed: in the console or in the
graphics device.

## Usage

``` r
print_color(col, quote = FALSE, width = NULL, gap = NULL, max = NULL)
```

## Arguments

- col:

  A vector, matrix, or list of vectors/matrices, all containing R
  colors. Can be character or numeric. The alpha (transparency) channel
  will be ignored.

- quote:

  `TRUE`/`FALSE` for whether to print quotation marks around color
  strings.

- width:

  Determines the width of each color cell and also whether the color
  string text is printed in the blcellock's foreground. There are 3
  options:

  - If `NULL` (the default), the color string text is printed, and all
    color cells will be the same size. The size will be set based on the
    width of the longest color string.

  - If `NA`, the color string text is printed, and each color cell will
    be only as wide as needed to fit its text.

  - If a number \>= 1, the color string text is *not* printed, and each
    cell will be exactly `floor(width)` characters wide.

- gap:

  Determines the horizontal gap between cells There are 2 options:

  - If `NULL` (the default): If `width` is a number (so cells have no
    foreground text), there will be no gap. Otherwise (when there is
    foreground text), the gap will be 1 space.

  - If a number \>= 0, the gap will be `floor(gap)` spaces.

- max:

  Determines the maximum number of colors to print. Either `NULL` (the
  default, meaning use `getOption("max.print")`) or a number \>= 0. The
  number will be truncated (`floor(max)`) and then will be honored
  exactly when printing a vector or approximately when printing a
  matrix.

## Value

Invisibly returns `col`.

## Details

Printing in color in the console is handled by the [cli
package](https://cli.r-lib.org/reference/cli-package.html), and it works
best if your console supports 24-bit colors. `print_color()` determines
how many colors are available using the following mechanism:

1.  If the `colorkit.num_colors` options is set, use it.

2.  If R is running inside Positron, use 256^3 (~16.7 million).

3.  Otherwise use
    [`cli::num_ansi_colors()`](https://cli.r-lib.org/reference/num_ansi_colors.html).

To visually check whether your console supports 24-bit colors, run the
following code. If the result is a fairly smooth gradient within each
row, then you have 24-bit colors. If you instead see color banding
(wide, distinct steps between colors within a row) or worse (e.g.,
nothing at all), then you have fewer colors available.

    # test: can the console print in 24-bit color?
    options(colorkit.num_colors = 256^3)
    print_color(matrix(rainbow(240), nrow = 6, byrow = TRUE), width = 1)

The foreground text color of each cell is determined by
[`bg2fg()`](https://dmuenz.github.io/colorkit/reference/bg2fg.md).

## See also

[`plot_color()`](https://dmuenz.github.io/colorkit/reference/plot_color.md)
for plotting colors in the graphics device.

## Examples

``` r
print_color(c("red", "steelblue", "#40E0D0"))
#> (3 colors)
#> red       steelblue #40E0D0  
print_color(c("red", "steelblue", "#40E0D0"), width = 5)
#> (3 colors)
#>                

print_color(rainbow(10))
#> (10 colors)
#> #FF0000 #FF9900 #CCFF00 #33FF00 #00FF66 #00FFFF #0066FF #3300FF #CC00FF #FF0099
print_color(rainbow(80), width = 1)
#> (80 colors)
#>                                                                                 

# Print all the RColorBrewer palettes
if (requireNamespace("RColorBrewer")) {
  pals <- sapply(rownames(RColorBrewer::brewer.pal.info), function(pal) {
    RColorBrewer::brewer.pal(Inf, pal)
  }) |> suppressWarnings() |> rev()

  print_color(pals, width = 3)
}
#> $YlOrRd
#> (9 colors)
#>                            
#> 
#> $YlOrBr
#> (9 colors)
#>                            
#> 
#> $YlGnBu
#> (9 colors)
#>                            
#> 
#> $YlGn
#> (9 colors)
#>                            
#> 
#> $Reds
#> (9 colors)
#>                            
#> 
#> $RdPu
#> (9 colors)
#>                            
#> 
#> $Purples
#> (9 colors)
#>                            
#> 
#> $PuRd
#> (9 colors)
#>                            
#> 
#> $PuBuGn
#> (9 colors)
#>                            
#> 
#> $PuBu
#> (9 colors)
#>                            
#> 
#> $OrRd
#> (9 colors)
#>                            
#> 
#> $Oranges
#> (9 colors)
#>                            
#> 
#> $Greys
#> (9 colors)
#>                            
#> 
#> $Greens
#> (9 colors)
#>                            
#> 
#> $GnBu
#> (9 colors)
#>                            
#> 
#> $BuPu
#> (9 colors)
#>                            
#> 
#> $BuGn
#> (9 colors)
#>                            
#> 
#> $Blues
#> (9 colors)
#>                            
#> 
#> $Set3
#> (12 colors)
#>                                     
#> 
#> $Set2
#> (8 colors)
#>                         
#> 
#> $Set1
#> (9 colors)
#>                            
#> 
#> $Pastel2
#> (8 colors)
#>                         
#> 
#> $Pastel1
#> (9 colors)
#>                            
#> 
#> $Paired
#> (12 colors)
#>                                     
#> 
#> $Dark2
#> (8 colors)
#>                         
#> 
#> $Accent
#> (8 colors)
#>                         
#> 
#> $Spectral
#> (11 colors)
#>                                  
#> 
#> $RdYlGn
#> (11 colors)
#>                                  
#> 
#> $RdYlBu
#> (11 colors)
#>                                  
#> 
#> $RdGy
#> (11 colors)
#>                                  
#> 
#> $RdBu
#> (11 colors)
#>                                  
#> 
#> $PuOr
#> (11 colors)
#>                                  
#> 
#> $PRGn
#> (11 colors)
#>                                  
#> 
#> $PiYG
#> (11 colors)
#>                                  
#> 
#> $BrBG
#> (11 colors)
#>                                  

# Convert 'volcano' to a matrix of colors, then print
mat <- volcano[1:20, 1:20]
n <- 50
color_idx <- cut(mat, breaks = n, labels = FALSE)
color_mat <- structure(rainbow(n)[color_idx], dim = dim(mat))
print_color(color_mat, width = 3)
#> (20 x 20 = 400 colors)
#>                                                             
#>                                                             
#>                                                             
#>                                                             
#>                                                             
#>                                                             
#>                                                             
#>                                                             
#>                                                             
#>                                                             
#>                                                             
#>                                                             
#>                                                             
#>                                                             
#>                                                             
#>                                                             
#>                                                             
#>                                                             
#>                                                             
#>                                                             
```
