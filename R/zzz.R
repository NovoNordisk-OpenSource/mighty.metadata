.onLoad <- function(...) {
  S7::methods_register() # nocov
}

if (utils::packageVersion("S7") >= "0.2.2.9000") {
  S7::S7_on_build()
}
