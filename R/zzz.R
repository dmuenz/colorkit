.onLoad <- function(libname, pkgname) {
  ct <- colors_lookup_table()
  .Call(col2hex_init, names(ct), unname(ct))
}

.onUnload <- function(libpath) {
  .Call(col2hex_cleanup)
}
