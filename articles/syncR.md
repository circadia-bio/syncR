# Getting started with syncR

## Overview

syncR is the integrator and coordinator of the Circadia Lab R ecosystem.

> *syncR::sync() — pulling everything into alignment, just like the SCN
> does.*

The package pulls three streams of participant data into a single
unified, participant-indexed database:

| Source   | Package     | Data type                                     |
|----------|-------------|-----------------------------------------------|
| `tallie` | **tallieR** | Sociodemographics, one-time questionnaires    |
| `slumb`  | **slumbR**  | Sleep diary entries, subjective sleep quality |
| `zeit`   | **zeitR**   | Actigraphy metrics, circadian parameters      |

## Basic usage

``` r
library(syncR)

db <- sync(
  tallie = tallieR::export(),
  slumb  = slumbR::export(),
  zeit   = zeitR::export()
)
```

The result is a tidy, participant-indexed tibble with one row per
participant per night (where applicable), with columns from all supplied
sources.

## Joining strategies

By default [`sync()`](https://syncr.circadia-lab.uk/reference/sync.md)
performs a left join anchored on the first supplied source. Use the
`join` argument to change this:

``` r
# Only participants present in all three sources
db_complete <- sync(
  tallie = tallieR::export(),
  slumb  = slumbR::export(),
  zeit   = zeitR::export(),
  join   = "inner"
)

# All participants from any source, NAs where data is absent
db_all <- sync(
  tallie = tallieR::export(),
  slumb  = slumbR::export(),
  zeit   = zeitR::export(),
  join   = "full"
)
```

## Custom participant ID column

If your data uses a different participant identifier column name, pass
it via `id_col`:

``` r
db <- sync(
  tallie = my_tallie_data,
  zeit   = my_zeit_data,
  id_col = "pid"
)
```
