# dev/make_test_data.R
# Generates realistic test data matching slumbR, tallieR, and zeitR output
# structures for use in syncR integration testing.
# Run with: source("dev/make_test_data.R")

library(tibble)

set.seed(42)

n_participants <- 5
pids <- sprintf("P%03d", 1:n_participants)
dates <- seq.Date(as.Date("2025-01-13"), by = "day", length.out = 7)

# ── 1. tallieR-style sociodemographic + questionnaire data ─────────────────
# Mirrors the wide output of tallieR::scores_wide() + participant metadata

tallie <- tibble(
  participant_id  = pids,
  code            = pids,
  name            = c("Alice Smith", "Bob Jones", "Clara Diaz",
                      "David Lee",   "Eva Müller"),
  age             = c(28L, 34L, 22L, 45L, 31L),
  sex             = c("female", "male", "female", "male", "female"),
  bmi             = c(22.4, 26.1, 20.8, 28.3, 23.7),
  group           = rep("control", n_participants),
  site            = rep("Newcastle", n_participants),
  session         = rep("baseline", n_participants),
  # ESS (Epworth Sleepiness Scale, 0-24)
  ess_score       = c(8L, 14L, 6L, 11L, 9L),
  ess_completed   = rep("2025-01-13T09:00:00.000Z", n_participants),
  # ISI (Insomnia Severity Index, 0-28)
  isi_score       = c(7L, 18L, 4L, 13L, 9L),
  isi_completed   = rep("2025-01-13T09:10:00.000Z", n_participants),
  # MEQ (Morningness-Eveningness Questionnaire, 16-86)
  meq_score       = c(52L, 38L, 61L, 44L, 57L),
  meq_completed   = rep("2025-01-13T09:20:00.000Z", n_participants),
  created_at      = rep("2025-01-13T08:55:00.000Z", n_participants)
)

# ── 2. slumbR-style sleep diary data (wide format, one row per night) ──────
# Mirrors the output of slumbR::diary_wide() after compute_sleep_vars().
# diary_wide() prefixes morning columns with m_ and evening columns with e_.
# One row per participant per night: 5 participants x 7 nights = 35 rows.
#
# Morning fields (m_):
#   timing:     bed_time, sleep_time, sol_min, final_waking, rise_time
#   wakings:    woke_during_night, n_wakings, waso_min
#   substances: alcohol_drinks, sleep_aid_used, sleep_aid_count
#   derived:    tib_min, tst_min, se_pct
#   flags:      sol_flag, waso_flag, tst_flag, se_flag
#   subjective: sleep_quality, restedness
#
# Evening fields (e_):
#   nap:        nap_taken, nap_duration_min
#   substances: caffeine_drinks, exercised, sleep_med_used, sleep_med_count

slumb <- do.call(rbind, lapply(pids, function(pid) {
  base_bed  <- switch(pid,
    P001 = 23.5, P002 = 24.5, P003 = 23.0, P004 = 23.8, P005 = 23.2
  )
  base_sol  <- switch(pid,
    P001 = 12,   P002 = 28,   P003 =  8,   P004 = 20,   P005 = 14
  )
  base_waso <- switch(pid,
    P001 = 10,   P002 = 35,   P003 =  5,   P004 = 22,   P005 = 12
  )
  # P002 has higher insomnia + occasional sleep aid use
  sleep_aid_prob <- switch(pid,
    P001 = 0.05, P002 = 0.40, P003 = 0.00, P004 = 0.20, P005 = 0.10
  )
  # P002 and P004 drink more alcohol
  alcohol_mean <- switch(pid,
    P001 = 0.3, P002 = 1.2, P003 = 0.1, P004 = 0.8, P005 = 0.2
  )

  tib_raw <- ((7.5 + rnorm(7, 0, 0.3)) - base_bed + 24) %% 24 * 60
  tst_raw <- pmax(tib_raw - base_sol - base_waso, 0)

  sleep_aid_used  <- runif(7) < sleep_aid_prob
  sleep_med_used  <- runif(7) < sleep_aid_prob * 0.5  # evening sleep meds less common
  nap_taken       <- runif(7) < 0.15

  tibble(
    participant_id       = pid,
    date                 = as.character(dates),

    # ── Morning (m_) ──────────────────────────────────────────────────────
    # Timing
    m_bed_time           = round(base_bed + rnorm(7, 0, 0.25), 2),
    m_sleep_time         = round(base_bed + rnorm(7, 0, 0.20) + 0.15, 2),
    m_sol_min            = pmax(round(base_sol + rnorm(7, 0, 5)), 0),
    m_final_waking       = round(7.0 + rnorm(7, 0, 0.3), 2),
    m_rise_time          = round(7.5 + rnorm(7, 0, 0.3), 2),
    # Night wakings
    m_woke_during_night  = base_waso > 20,
    m_n_wakings          = as.integer(pmax(round(rnorm(7, ifelse(base_waso > 20, 2, 1), 1)), 0L)),
    m_waso_min           = pmax(round(base_waso + rnorm(7, 0, 8)), 0),
    # Substances (previous night)
    m_alcohol_drinks     = as.integer(pmax(round(rnorm(7, alcohol_mean, 0.5)), 0L)),
    m_sleep_aid_used     = sleep_aid_used,
    m_sleep_aid_count    = as.integer(sleep_aid_used),
    # Derived sleep variables
    m_tib_min            = round(tib_raw, 1),
    m_tst_min            = round(tst_raw, 1),
    m_se_pct             = round(tst_raw / tib_raw * 100, 1),
    # Clinical flags
    m_sol_flag           = base_sol > 30,
    m_waso_flag          = base_waso > 30,
    m_tst_flag           = tst_raw < 420,
    m_se_flag            = (tst_raw / tib_raw * 100) < 85,
    # Subjective quality (1-5)
    m_sleep_quality      = as.integer(sample(2:5, 7, replace = TRUE)),
    m_restedness         = as.integer(sample(2:5, 7, replace = TRUE)),

    # ── Evening (e_) ──────────────────────────────────────────────────────
    e_nap_taken          = nap_taken,
    e_nap_duration_min   = as.integer(ifelse(nap_taken, sample(c(15, 20, 30, 45), 7, replace = TRUE), NA)),
    e_caffeine_drinks    = as.integer(pmax(round(rnorm(7, 2, 1)), 0L)),
    e_exercised          = runif(7) < 0.35,
    e_sleep_med_used     = sleep_med_used,
    e_sleep_med_count    = as.integer(sleep_med_used)
  )
}))

# ── 3. zeitR-style actigraphy / NPCRA summary (one row per participant) ────
# Mirrors the output of zeitR::study_summary()

zeit <- tibble(
  participant_id = pids,
  n_epochs       = c(20160L, 20160L, 17280L, 20160L, 20160L),
  n_days         = c(7.00,   7.00,   6.00,   7.00,   7.00),
  start          = as.POSIXct(c(
    "2025-01-13 00:00:00", "2025-01-13 00:00:00", "2025-01-13 00:00:00",
    "2025-01-13 00:00:00", "2025-01-13 00:00:00"
  )),
  end            = as.POSIXct(c(
    "2025-01-19 23:59:00", "2025-01-19 23:59:00", "2025-01-18 23:59:00",
    "2025-01-19 23:59:00", "2025-01-19 23:59:00"
  )),
  IS             = round(c(0.72, 0.58, 0.81, 0.65, 0.76), 3),
  IV             = round(c(0.48, 0.71, 0.39, 0.62, 0.44), 3),
  RA             = round(c(0.88, 0.74, 0.92, 0.79, 0.86), 3),
  L5             = round(c(12.3, 18.7,  8.9, 15.4, 11.2), 1),
  L5_onset       = c("02:30", "03:15", "02:00", "02:45", "02:20"),
  M10            = round(c(312.4, 278.9, 341.2, 295.6, 324.8), 1),
  M10_onset      = c("10:30", "11:00", "10:00", "10:45", "10:15")
)

# ── Save as RDS ─────────────────────────────────────────────────────────────
saveRDS(tallie, "inst/testdata/tallie_test.rds")
saveRDS(slumb,  "inst/testdata/slumb_test.rds")
saveRDS(zeit,   "inst/testdata/zeit_test.rds")

cat("Test data written to inst/testdata/\n")
cat(sprintf("  tallie: %d participants, %d cols\n",   nrow(tallie), ncol(tallie)))
cat(sprintf("  slumb:  %d rows (%d participants x 7 nights), %d cols\n",
            nrow(slumb), n_participants, ncol(slumb)))
cat(sprintf("  zeit:   %d participants, %d cols\n",   nrow(zeit),   ncol(zeit)))

# ── Quick integration test ───────────────────────────────────────────────────
cat("\nQuick sync() test:\n")

if (requireNamespace("syncR", quietly = TRUE)) {
  db <- syncR::sync(tallie = tallie, slumb = slumb, zeit = zeit)
  cat(sprintf("  sync() returned %d rows x %d cols\n", nrow(db), ncol(db)))
} else {
  cat("  syncR not installed -- run devtools::load_all() first, then:\n")
  cat("  db <- sync(tallie = tallie, slumb = slumb, zeit = zeit)\n")
}
