# Getting started with syncR

## Overview

syncR is the integrator and coordinator of the Circadia Lab R ecosystem.

> *syncR::sync() — pulling everything into alignment, just like the SCN
> does.*

The [`sync()`](https://syncr.circadia-lab.uk/reference/sync.md) function
pulls three streams of participant data into a single unified,
participant-indexed database:

| Argument | Package     | Typical source function                                                          | Data type                                     |
|----------|-------------|----------------------------------------------------------------------------------|-----------------------------------------------|
| `tallie` | **tallieR** | [`scores_wide()`](https://tallier.circadia-lab.uk/reference/scores_wide.html)    | Sociodemographics + questionnaire scores      |
| `slumb`  | **slumbR**  | [`diary_wide()`](https://slumbr.circadia-lab.uk/reference/diary_wide.html)       | Sleep diary entries, subjective sleep quality |
| `zeit`   | **zeitR**   | [`study_summary()`](https://slumbr.circadia-lab.uk/reference/study_summary.html) | Actigraphy metrics, circadian parameters      |

------------------------------------------------------------------------

## Test data

This vignette uses the built-in test data bundled with syncR, which
mirrors the real output of each package. Load it with
[`readRDS()`](https://rdrr.io/r/base/readRDS.html):

``` r
tallie <- readRDS(system.file("testdata/tallie_test.rds", package = "syncR"))
slumb  <- readRDS(system.file("testdata/slumb_test.rds",  package = "syncR"))
zeit   <- readRDS(system.file("testdata/zeit_test.rds",   package = "syncR"))
```

### tallieR data

One row per participant, with demographics and questionnaire scores from
[`tallieR::scores_wide()`](https://tallier.circadia-lab.uk/reference/scores_wide.html):

``` r
dplyr::glimpse(tallie)
#> Rows: 5
#> Columns: 16
#> $ participant_id <chr> "P001", "P002", "P003", "P004", "P005"
#> $ code           <chr> "P001", "P002", "P003", "P004", "P005"
#> $ name           <chr> "Alice Smith", "Bob Jones", "Clara Diaz", "David Lee", …
#> $ age            <int> 28, 34, 22, 45, 31
#> $ sex            <chr> "female", "male", "female", "male", "female"
#> $ bmi            <dbl> 22.4, 26.1, 20.8, 28.3, 23.7
#> $ group          <chr> "control", "control", "control", "control", "control"
#> $ site           <chr> "Newcastle", "Newcastle", "Newcastle", "Newcastle", "Ne…
#> $ session        <chr> "baseline", "baseline", "baseline", "baseline", "baseli…
#> $ ess_score      <int> 8, 14, 6, 11, 9
#> $ ess_completed  <chr> "2025-01-13T09:00:00.000Z", "2025-01-13T09:00:00.000Z",…
#> $ isi_score      <int> 7, 18, 4, 13, 9
#> $ isi_completed  <chr> "2025-01-13T09:10:00.000Z", "2025-01-13T09:10:00.000Z",…
#> $ meq_score      <int> 52, 38, 61, 44, 57
#> $ meq_completed  <chr> "2025-01-13T09:20:00.000Z", "2025-01-13T09:20:00.000Z",…
#> $ created_at     <chr> "2025-01-13T08:55:00.000Z", "2025-01-13T08:55:00.000Z",…
```

Key fields: `participant_id` (the join key), sociodemographic variables
(`age`, `sex`, `bmi`, `group`), and instrument scores (`ess_score`,
`isi_score`, `meq_score`).

### slumbR data

One row per participant per night, from
[`slumbR::diary_wide()`](https://slumbr.circadia-lab.uk/reference/diary_wide.html) +
[`slumbR::compute_sleep_vars()`](https://slumbr.circadia-lab.uk/reference/compute_sleep_vars.html).
Morning columns are prefixed `m_` and evening columns `e_`. Seven nights
across five participants gives 35 rows:

``` r
dplyr::glimpse(slumb)
#> Rows: 35
#> Columns: 28
#> $ participant_id      <chr> "P001", "P001", "P001", "P001", "P001", "P001", "P…
#> $ date                <chr> "2025-01-13", "2025-01-14", "2025-01-15", "2025-01…
#> $ m_bed_time          <dbl> 23.74, 23.30, 23.57, 23.46, 23.98, 23.93, 23.59, 2…
#> $ m_sleep_time        <dbl> 23.71, 23.57, 23.81, 23.78, 23.46, 23.66, 24.07, 2…
#> $ m_sol_min           <dbl> 13, 8, 17, 8, 7, 12, 15, 25, 18, 22, 29, 31, 26, 2…
#> $ m_final_waking      <dbl> 6.90, 6.11, 6.70, 7.11, 7.05, 6.60, 6.85, 7.34, 7.…
#> $ m_rise_time         <dbl> 6.45, 7.95, 7.69, 7.51, 7.59, 7.27, 7.42, 7.47, 7.…
#> $ m_woke_during_night <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, T…
#> $ m_n_wakings         <int> 3, 2, 0, 2, 1, 1, 1, 2, 3, 1, 2, 0, 3, 2, 1, 0, 0,…
#> $ m_waso_min          <dbl> 18, 8, 12, 8, 24, 15, 12, 31, 25, 35, 29, 31, 45, …
#> $ m_alcohol_drinks    <int> 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 2, 1, 1, 0, 0, 1,…
#> $ m_sleep_aid_used    <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, F…
#> $ m_sleep_aid_count   <int> 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0,…
#> $ m_tib_min           <dbl> 504.7, 469.8, 486.5, 491.4, 487.3, 478.1, 507.2, 4…
#> $ m_tst_min           <dbl> 482.7, 447.8, 464.5, 469.4, 465.3, 456.1, 485.2, 3…
#> $ m_se_pct            <dbl> 95.6, 95.3, 95.5, 95.5, 95.5, 95.4, 95.7, 84.6, 85…
#> $ m_sol_flag          <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, F…
#> $ m_waso_flag         <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, T…
#> $ m_tst_flag          <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, T…
#> $ m_se_flag           <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, T…
#> $ m_sleep_quality     <int> 3, 4, 3, 3, 5, 2, 4, 3, 5, 5, 4, 2, 4, 2, 5, 3, 2,…
#> $ m_restedness        <int> 2, 2, 2, 4, 4, 5, 2, 4, 3, 2, 3, 5, 3, 3, 4, 2, 3,…
#> $ e_nap_taken         <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, FA…
#> $ e_nap_duration_min  <int> NA, NA, NA, NA, NA, NA, 30, NA, NA, NA, NA, NA, NA…
#> $ e_caffeine_drinks   <int> 1, 3, 2, 2, 3, 3, 3, 2, 1, 3, 2, 2, 2, 1, 1, 4, 1,…
#> $ e_exercised         <lgl> TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, TRUE, FALS…
#> $ e_sleep_med_used    <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, F…
#> $ e_sleep_med_count   <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0,…
```

Key morning fields: timing (`m_bed_time`, `m_rise_time`, `m_sol_min`),
derived sleep variables (`m_tib_min`, `m_tst_min`, `m_se_pct`),
substance use (`m_alcohol_drinks`, `m_sleep_aid_used`), clinical flags
(`m_sol_flag`, `m_waso_flag`, `m_tst_flag`, `m_se_flag`), and subjective
ratings (`m_sleep_quality`, `m_restedness`).

Key evening fields: napping (`e_nap_taken`, `e_nap_duration_min`),
substance use (`e_caffeine_drinks`, `e_sleep_med_used`), and activity
(`e_exercised`).

### zeitR data

One row per participant, from
[`zeitR::study_summary()`](https://zeitr.circadia-lab.uk/reference/study_summary.html):

``` r
dplyr::glimpse(zeit)
#> Rows: 5
#> Columns: 12
#> $ participant_id <chr> "P001", "P002", "P003", "P004", "P005"
#> $ n_epochs       <int> 20160, 20160, 17280, 20160, 20160
#> $ n_days         <dbl> 7, 7, 6, 7, 7
#> $ start          <dttm> 2025-01-13, 2025-01-13, 2025-01-13, 2025-01-13, 2025-01…
#> $ end            <dttm> 2025-01-19 23:59:00, 2025-01-19 23:59:00, 2025-01-18 23…
#> $ IS             <dbl> 0.72, 0.58, 0.81, 0.65, 0.76
#> $ IV             <dbl> 0.48, 0.71, 0.39, 0.62, 0.44
#> $ RA             <dbl> 0.88, 0.74, 0.92, 0.79, 0.86
#> $ L5             <dbl> 12.3, 18.7, 8.9, 15.4, 11.2
#> $ L5_onset       <chr> "02:30", "03:15", "02:00", "02:45", "02:20"
#> $ M10            <dbl> 312.4, 278.9, 341.2, 295.6, 324.8
#> $ M10_onset      <chr> "10:30", "11:00", "10:00", "10:45", "10:15"
```

Key circadian fields: `IS` (interdaily stability), `IV` (intradaily
variability), `RA` (relative amplitude), `L5` / `L5_onset`, `M10` /
`M10_onset`.

------------------------------------------------------------------------

## Synchronising with `sync()`

### Default left join

The default call performs a **left join** anchored on the first supplied
source. Since `slumb` has multiple rows per participant, the result
expands to one row per participant per night — with questionnaire scores
and circadian variables repeated across all nights for each participant:

``` r
db <- sync(
  tallie = tallie,
  slumb  = slumb,
  zeit   = zeit
)

dim(db)
#> [1] 35 54
```

``` r
db |>
  dplyr::select(
    participant_id, date,
    age, sex, ess_score, isi_score, meq_score,
    m_tst_min, m_se_pct, m_sleep_quality,
    IS, IV, RA
  ) |>
  head(10)
#> # A tibble: 10 × 13
#>    participant_id date         age sex   ess_score isi_score meq_score m_tst_min
#>    <chr>          <chr>      <int> <chr>     <int>     <int>     <int>     <dbl>
#>  1 P001           2025-01-13    28 fema…         8         7        52      483.
#>  2 P001           2025-01-14    28 fema…         8         7        52      448.
#>  3 P001           2025-01-15    28 fema…         8         7        52      464.
#>  4 P001           2025-01-16    28 fema…         8         7        52      469.
#>  5 P001           2025-01-17    28 fema…         8         7        52      465.
#>  6 P001           2025-01-18    28 fema…         8         7        52      456.
#>  7 P001           2025-01-19    28 fema…         8         7        52      485.
#>  8 P002           2025-01-13    34 male         14        18        38      347.
#>  9 P002           2025-01-14    34 male         14        18        38      371.
#> 10 P002           2025-01-15    34 male         14        18        38      337.
#> # ℹ 5 more variables: m_se_pct <dbl>, m_sleep_quality <int>, IS <dbl>,
#> #   IV <dbl>, RA <dbl>
```

### Inner join

Use `join = "inner"` to retain only participants present in **all
three** sources:

``` r
db_inner <- sync(
  tallie = tallie,
  slumb  = slumb,
  zeit   = zeit,
  join   = "inner"
)

nrow(db_inner)
#> [1] 35
```

### Full join

Use `join = "full"` to retain **all** participants from any source,
filling `NA` where data is absent:

``` r
db_full <- sync(
  tallie = tallie,
  slumb  = slumb,
  zeit   = zeit,
  join   = "full"
)

nrow(db_full)
#> [1] 35
```

### Custom participant ID column

If your data uses a different column name, pass it via `id_col`:

``` r
db <- sync(
  tallie = my_tallie_data,
  slumb  = my_slumb_data,
  zeit   = my_zeit_data,
  id_col = "pid"
)
```

### Partial sync

All sources are optional — pass only what you have:

``` r
db_partial <- sync(
  tallie = tallie,
  zeit   = zeit
)

dim(db_partial)
#> [1]  5 27
```

------------------------------------------------------------------------

## Example analyses

With a unified database, cross-domain analyses require no further
joining.

### Circadian type vs. sleep efficiency

MEQ chronotype score against actigraphy-derived IS and mean subjective
sleep efficiency:

``` r
db |>
  dplyr::group_by(participant_id) |>
  dplyr::summarise(
    meq_score    = dplyr::first(meq_score),
    IS           = dplyr::first(IS),
    mean_se_pct  = mean(m_se_pct,        na.rm = TRUE),
    mean_quality = mean(m_sleep_quality,  na.rm = TRUE),
    .groups = "drop"
  ) |>
  dplyr::arrange(dplyr::desc(meq_score))
#> # A tibble: 5 × 5
#>   participant_id meq_score    IS mean_se_pct mean_quality
#>   <chr>              <int> <dbl>       <dbl>        <dbl>
#> 1 P003                  61  0.81        97.4         3.57
#> 2 P005                  57  0.76        94.7         3.86
#> 3 P001                  52  0.72        95.5         3.43
#> 4 P004                  44  0.65        91.0         4.29
#> 5 P002                  38  0.58        84.7         3.57
```

### Insomnia severity vs. objective sleep

ISI score against mean TST and WASO from the diary:

``` r
db |>
  dplyr::group_by(participant_id) |>
  dplyr::summarise(
    isi_score     = dplyr::first(isi_score),
    mean_tst_h    = mean(m_tst_min,  na.rm = TRUE) / 60,
    mean_waso_min = mean(m_waso_min, na.rm = TRUE),
    mean_se_pct   = mean(m_se_pct,   na.rm = TRUE),
    .groups = "drop"
  ) |>
  dplyr::arrange(dplyr::desc(isi_score))
#> # A tibble: 5 × 5
#>   participant_id isi_score mean_tst_h mean_waso_min mean_se_pct
#>   <chr>              <int>      <dbl>         <dbl>       <dbl>
#> 1 P002                  18       5.82         32.9         84.7
#> 2 P004                  13       7.09         23.4         91.0
#> 3 P005                   9       7.83         13.7         94.7
#> 4 P001                   7       7.79         13.9         95.5
#> 5 P003                   4       8.25          7.86        97.4
```

### Substance use and sleep quality

Nights with alcohol consumption or sleep aid use, and their impact on
next- morning sleep quality and efficiency:

``` r
db |>
  dplyr::mutate(
    any_substance = m_alcohol_drinks > 0 | m_sleep_aid_used | e_caffeine_drinks > 3
  ) |>
  dplyr::group_by(any_substance) |>
  dplyr::summarise(
    n_nights        = dplyr::n(),
    mean_tst_h      = mean(m_tst_min,      na.rm = TRUE) / 60,
    mean_se_pct     = mean(m_se_pct,        na.rm = TRUE),
    mean_waso_min   = mean(m_waso_min,      na.rm = TRUE),
    mean_quality    = mean(m_sleep_quality, na.rm = TRUE),
    .groups = "drop"
  )
#> # A tibble: 2 × 6
#>   any_substance n_nights mean_tst_h mean_se_pct mean_waso_min mean_quality
#>   <lgl>            <int>      <dbl>       <dbl>         <dbl>        <dbl>
#> 1 FALSE               12       7.90        96.1          12.2         4   
#> 2 TRUE                23       7.07        90.9          21.6         3.61
```

### Nights with poor sleep efficiency

Flagging nights where SE \< 85%, alongside each participant’s circadian
profile:

``` r
db |>
  dplyr::filter(m_se_flag == TRUE) |>
  dplyr::select(
    participant_id, date,
    m_tst_min, m_se_pct, m_alcohol_drinks, m_sleep_aid_used,
    IS, RA
  ) |>
  dplyr::arrange(m_se_pct)
#> # A tibble: 4 × 8
#>   participant_id date       m_tst_min m_se_pct m_alcohol_drinks m_sleep_aid_used
#>   <chr>          <chr>          <dbl>    <dbl>            <int> <lgl>           
#> 1 P002           2025-01-16      328.     83.9                1 FALSE           
#> 2 P002           2025-01-15      337.     84.2                1 FALSE           
#> 3 P002           2025-01-17      335.     84.2                2 FALSE           
#> 4 P002           2025-01-13      347.     84.6                1 FALSE           
#> # ℹ 2 more variables: IS <dbl>, RA <dbl>
```

------------------------------------------------------------------------

## Working with real data

In a real study, the inputs to
[`sync()`](https://syncr.circadia-lab.uk/reference/sync.md) come
directly from the package export functions:

``` r
library(tallieR)
library(slumbR)
library(zeitR)
library(syncR)

tallie <- tallieR::read_scoreme("exports/scoreme_export.json") |>
  tallieR::scores_wide()

slumb <- slumbR::read_study("exports/sleep_diaries/") |>
  slumbR::diary_wide()

zeit <- zeitR::read_actigraphy_dir("recordings/", tz = "Europe/London") |>
  zeitR::study_summary()

db <- sync(
  tallie = tallie,
  slumb  = slumb,
  zeit   = zeit
)
```

------------------------------------------------------------------------

## Session info

``` r
sessionInfo()
#> R version 4.6.0 (2026-04-24)
#> Platform: x86_64-pc-linux-gnu
#> Running under: Ubuntu 24.04.4 LTS
#> 
#> Matrix products: default
#> BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3 
#> LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.26.so;  LAPACK version 3.12.0
#> 
#> locale:
#>  [1] LC_CTYPE=C.UTF-8       LC_NUMERIC=C           LC_TIME=C.UTF-8       
#>  [4] LC_COLLATE=C.UTF-8     LC_MONETARY=C.UTF-8    LC_MESSAGES=C.UTF-8   
#>  [7] LC_PAPER=C.UTF-8       LC_NAME=C              LC_ADDRESS=C          
#> [10] LC_TELEPHONE=C         LC_MEASUREMENT=C.UTF-8 LC_IDENTIFICATION=C   
#> 
#> time zone: UTC
#> tzcode source: system (glibc)
#> 
#> attached base packages:
#> [1] stats     graphics  grDevices utils     datasets  methods   base     
#> 
#> other attached packages:
#> [1] dplyr_1.2.1 syncR_0.1.0
#> 
#> loaded via a namespace (and not attached):
#>  [1] vctrs_0.7.3       cli_3.6.6         knitr_1.51        rlang_1.2.0      
#>  [5] xfun_0.59         otel_0.2.0        generics_0.1.4    textshaping_1.0.5
#>  [9] jsonlite_2.0.0    glue_1.8.1        htmltools_0.5.9   ragg_1.5.2       
#> [13] sass_0.4.10       rmarkdown_2.31    tibble_3.3.1      evaluate_1.0.5   
#> [17] jquerylib_0.1.4   fastmap_1.2.0     yaml_2.3.12       lifecycle_1.0.5  
#> [21] compiler_4.6.0    fs_2.1.0          pkgconfig_2.0.3   systemfonts_1.3.2
#> [25] digest_0.6.39     R6_2.6.1          utf8_1.2.6        tidyselect_1.2.1 
#> [29] pillar_1.11.1     magrittr_2.0.5    bslib_0.11.0      withr_3.0.3      
#> [33] tools_4.6.0       pkgdown_2.2.0     cachem_1.1.0      desc_1.4.3
```
