#' Synchronise data across the Circadia Lab package ecosystem
#'
#' @description
#' `sync()` is the primary entry point for syncR. It pulls sociodemographic and
#' questionnaire data from **tallieR**, sleep diary data from **slumbR**, and
#' actigraphy-derived circadian metrics from **zeitR** into a single unified,
#' participant-indexed database.
#'
#' *syncR::sync() — pulling everything into alignment, just like the SCN does.*
#'
#' @param tallie A data frame of sociodemographic / questionnaire data, typically
#'   the output of `tallieR::export()`. Pass `NULL` to omit.
#' @param slumb A data frame of sleep diary data, typically the output of
#'   `slumbR::export()`. Pass `NULL` to omit.
#' @param zeit A data frame of actigraphy / circadian metrics, typically the
#'   output of `zeitR::export()`. Pass `NULL` to omit.
#' @param id_col Character. Name of the participant ID column shared across all
#'   input data frames. Defaults to `"participant_id"`.
#' @param join Character. Type of join to perform when combining sources. One of
#'   `"left"` (default), `"inner"`, or `"full"`.
#'
#' @return A tibble with one row per participant per night (where applicable),
#'   containing columns from all supplied sources, indexed by `id_col`.
#'
#' @examples
#' \dontrun{
#' db <- sync(
#'   tallie = tallieR::export(),
#'   slumb  = slumbR::export(),
#'   zeit   = zeitR::export()
#' )
#' }
#'
#' @export
sync <- function(tallie = NULL,
                 slumb  = NULL,
                 zeit   = NULL,
                 id_col = "participant_id",
                 join   = c("left", "inner", "full")) {

  join <- match.arg(join)

  sources <- list(tallie = tallie, slumb = slumb, zeit = zeit)
  sources <- Filter(Negate(is.null), sources)

  if (length(sources) == 0L) {
    rlang::abort(
      "At least one of `tallie`, `slumb`, or `zeit` must be supplied.",
      call = rlang::caller_env()
    )
  }

  join_fn <- switch(join,
    left  = dplyr::left_join,
    inner = dplyr::inner_join,
    full  = dplyr::full_join
  )

  result <- Reduce(
    f = function(x, y) join_fn(x, y, by = id_col),
    x = sources
  )

  rlang::inform(
    cli::format_message(
      c("v" = "syncR synchronised {length(sources)} source{?s}: {names(sources)}.")
    )
  )

  result
}
