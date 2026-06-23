# Synchronise data across the Circadia Lab package ecosystem

`sync()` is the primary entry point for syncR. It pulls sociodemographic
and questionnaire data from **tallieR**, sleep diary data from
**slumbR**, and actigraphy-derived circadian metrics from **zeitR** into
a single unified, participant-indexed database.

*syncR::sync() — pulling everything into alignment, just like the SCN
does.*

## Usage

``` r
sync(
  tallie = NULL,
  slumb = NULL,
  zeit = NULL,
  id_col = "participant_id",
  join = c("left", "inner", "full")
)
```

## Arguments

- tallie:

  A data frame of sociodemographic / questionnaire data, typically the
  output of `tallieR::export()`. Pass `NULL` to omit.

- slumb:

  A data frame of sleep diary data, typically the output of
  `slumbR::export()`. Pass `NULL` to omit.

- zeit:

  A data frame of actigraphy / circadian metrics, typically the output
  of `zeitR::export()`. Pass `NULL` to omit.

- id_col:

  Character. Name of the participant ID column shared across all input
  data frames. Defaults to `"participant_id"`.

- join:

  Character. Type of join to perform when combining sources. One of
  `"left"` (default), `"inner"`, or `"full"`.

## Value

A tibble with one row per participant per night (where applicable),
containing columns from all supplied sources, indexed by `id_col`.

## Examples

``` r
if (FALSE) { # \dontrun{
db <- sync(
  tallie = tallieR::export(),
  slumb  = slumbR::export(),
  zeit   = zeitR::export()
)
} # }
```
