# 🔄 syncR

**syncR is the integrator and coordinator of the Circadia Lab R ecosystem.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![R](https://img.shields.io/badge/R-%3E%3D4.1-276DC3)](https://www.r-project.org/)
[![R-CMD-check](https://github.com/circadia-bio/syncR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/circadia-bio/syncR/actions/workflows/R-CMD-check.yaml)
[![pkgdown](https://github.com/circadia-bio/syncR/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/circadia-bio/syncR/actions/workflows/pkgdown.yaml)

---

> ⚠️ **syncR is in early development and has not been formally tested.** The API may change without notice and the package has not undergone peer review. Use with caution and verify outputs independently before using in any research context.

---

## 📖 What is syncR?

syncR provides a single, unified entry point for bringing together data across the Circadia Lab package ecosystem. It pulls sociodemographic and questionnaire data from **tallieR**, sleep diary data from **slumbR**, and actigraphy-derived circadian metrics from **zeitR** into one tidy, participant-indexed database.

> *syncR::sync() — pulling everything into alignment, just like the SCN does.*

Just as the suprachiasmatic nucleus (SCN) coordinates biological rhythms across the body, `syncR` coordinates data streams across the suite — making cross-domain analysis (actigraphy vs. subjective sleep quality, circadian phase vs. demographics) effortless.

## ✨ Features

- 🔗 **One function, three sources** — `sync()` joins tallieR, slumbR, and zeitR outputs in a single call
- 🧩 **Flexible joining** — left, inner, or full join strategies to suit your study design
- 🪪 **Participant-indexed** — all outputs keyed on a shared participant ID column
- 🧹 **Tidy output** — returns a clean tibble ready for modelling or export
- 🔧 **Source-agnostic** — supply any combination of sources; omitted sources are silently ignored

## 🗂️ Project Structure

```
syncR/
├── R/
│   ├── syncR-package.R         # Package-level documentation
│   └── sync.R                  # Core sync() function
├── tests/
│   └── testthat/
│       └── test-sync.R         # Unit tests
├── vignettes/
│   └── syncR.Rmd               # Getting started vignette
├── .github/
│   └── workflows/
│       ├── R-CMD-check.yaml
│       └── pkgdown.yaml
├── _pkgdown.yml
└── DESCRIPTION
```

## 🚀 Getting Started

### Prerequisites

- R ≥ 4.1
- `dplyr`, `rlang`, `cli`

### Installation

```r
# Install from GitHub
remotes::install_github("circadia-bio/syncR")
```

### Basic usage

```r
library(syncR)

db <- sync(
  tallie = tallieR::export(),   # sociodemographics + questionnaires
  slumb  = slumbR::export(),    # sleep diaries
  zeit   = zeitR::export()      # actigraphy + circadian metrics
)
```

### Joining strategies

```r
# Inner join — only participants present in all sources
db <- sync(tallie = ..., slumb = ..., zeit = ..., join = "inner")

# Full join — all participants, NAs where data is absent
db <- sync(tallie = ..., slumb = ..., zeit = ..., join = "full")
```

## 📦 Dependencies

| Package | Role |
|---------|------|
| `dplyr` | Data frame joining |
| `rlang` | Error handling and messaging |
| `cli`   | Formatted console output |

## 👥 Authors

| Role | Name |
|------|------|
| Author & maintainer | Lucas França |
| Author | Mario Leocadio-Miguel |

## 🤝 Related Tools

- 🌙 [**slumbR**](https://github.com/circadia-bio/slumbR) — sleep diary data collection and processing
- ⏱️ [**zeitR**](https://github.com/circadia-bio/zeitR) — wrist actigraphy analysis and circadian rhythm metrics
- 📋 [**tallieR**](https://github.com/circadia-bio/tallieR) — sociodemographic and questionnaire data management
- 🔬 [**circadia-bio**](https://github.com/circadia-bio) — the Circadia Lab GitHub organisation

## 📄 Licence

Released under the [MIT License](./LICENSE).

Copyright © Lucas França & Mario Leocadio-Miguel, 2025
