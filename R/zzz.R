#++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Before package sealing
#++++++++++++++++++++++++++++++++++++++++++++++++++++++
.onLoad <- function(libname, pkgname) {
    options(keep.source = TRUE)

    invisible()
}


#++++++++++++++++++++++++++++++++++++++++++++++++++++++
# After package sealing
#++++++++++++++++++++++++++++++++++++++++++++++++++++++
.onAttach <- function(libname, pkgname) {

}
