# sample-size-guidance

Code accompanying:

> Daniels, W.S. & Hammerling, D.M. *Future methane measurement campaigns require basin-specific sampling strategies.* Communications Earth & Environment (2026). https://doi.org/10.1038/s43247-026-04089-4

Methane emissions from oil and gas operations follow right-skewed, heavy-tailed distributions, so the average emission rate estimated from a limited number of measurements can differ substantially from the true average. This repository contains the R code used to quantify that sampling error for six US oil and gas basins: it repeatedly draws samples of every possible size from each basin's emission rate distribution, summarises the resulting error in the sample mean, and produces the figures in the paper.

**Data:** all data needed to run the analysis (Levels 3–5, described below) are archived on Zenodo: https://doi.org/10.5281/zenodo.XXXXXXX

**Interactive webtool:** Michael Basanese at the Colorado School of Mines created a webtool to interact with the data and the sampling results. Access it here: https://mbasanese-sampling.share.connect.posit.cloud/

**Note:** this README was generated with Claude Sonnet 5.5.

## Contents

- [Repository layout](#repository-layout)
- [Data and processing levels](#data-and-processing-levels)
- [Quick start](#quick-start)
- [Script reference](#script-reference)
- [Computational notes](#computational-notes)
- [Troubleshooting](#troubleshooting)
- [Citation](#citation)

## Repository layout

```
sample-size-guidance/
├── code/
│   ├── CODE1_process_L1_to_L2.R           # view only 
│   ├── CODE2_process_L2_to_L3.R           # view only 
│   ├── CODE3_process_L3_to_L4_basins.R
│   ├── CODE3_process_L3_to_L4_heatmap.R
│   ├── CODE4_process_L4_to_L5_basins.R
│   ├── CODE4_process_L4_to_L5_heatmap.R
│   ├── FIG1_plot_data.R
│   ├── FIG2_sampling_overview.R
│   ├── FIG3_heatmaps.R
│   └── FIG4_basin_level.R
├── figures/                               # PNG output from the FIG scripts
└── README.md
```

The scripts are numbered in the order they are run. `CODE*` scripts transform data from one level to the next; `FIG*` scripts make the figures.

## Data and processing levels

Data move through five levels:

```
Level 1 --CODE1--> Level 2 --CODE2--> Level 3 --CODE3--> Level 4 --CODE4--> Level 5 --FIG1-4--> figures
```

| Level | Contents | Produced by | Available? |
|---|---|---|---|
| 1 | Source emission rate data as provided by the data owners | n/a | No, COBE data proprietary |
| 2 | Per-basin, per-source emission rate files (for Williams et al., one file per realization) | `CODE1` | No, COBE data proprietary |
| 3 | **`x_vectors`**: sorted emission rate vectors (kg/h) that define the "true" distribution sampled from in each basin | `CODE2` | Yes, Zenodo |
| 4 | **`sample_means`**: matrices of sample means from repeated random sampling | `CODE3` | Yes, Zenodo |
| 5 | **`metrics`**: summaries of sample mean error as a function of sample size | `CODE4` | Yes, Zenodo |

**Some Level 1 and 2 data are proprietary and cannot be redistributed.** `CODE1` and `CODE2` are included so that the processing from raw data to Level 3 is transparent, but they cannot be run without access to those data. They use hard-coded paths on the original author's machine, not `zenodo.dir`, and you should not need to edit them. **The publicly available data begin at `data_level_3/x_vectors`**, and everything from `CODE3` onward can be run from the Zenodo archive. Other Level 1 and 2 data are publicly available and can be accessed from their respective papers.

### Zenodo archive structure

Download and unzip the Zenodo archive. Its top-level folder is referred to below as `zenodo.dir`:

```
zenodo.dir/
├── data_level_3/x_vectors/basin_level/<basin>/*.rds
├── data_level_4/sample_means/basin_level/<basin>/*.rds
└── data_level_5/metrics/basin_level/<basin>/*.rds
```

`<basin>` is one of `appalachian`, `barnette`, `denver_julesburg`, `permian`, `san_joaquin`, `uinta`. The scripts discover basins with `list.files()` and rely on this alphabetical order (for example, Denver is the third basin and Permian the fourth), so do not add, remove, or rename basin folders.

### Data sources

Each Level 3 file is named `<source>_<statistic>.rds`:

| File prefix | Source in the paper | Basins |
|---|---|---|
| `williams` | Williams et al. | all six |
| `sherwin` | Sherwin et al. | all six |
| `cobe` | Brown et al. (Colorado Ongoing Basin Emissions, COBE) | Denver–Julesburg |
| `kunkel-equip` | Kunkel et al., source-level | Permian |
| `kunkel-site` | Kunkel et al., 150 m | Permian |

See the paper for full references and for how each distribution was constructed.

### File formats

All files are R `.rds` objects (read with `readRDS()`).

- **Level 3** (`data_level_3/x_vectors/basin_level/<basin>/`): numeric vectors of emission rates in kg/h, sorted in ascending order. Vectors are capped at 100,000 elements.
  - `williams_mean.rds`, `williams_lower.rds`, `williams_upper.rds`: Williams et al. provide 500 realizations of each basin's distribution. Each realization is sorted, and the three files are the element-wise mean and 2.5th and 97.5th percentiles across realizations.
  - `sherwin_mean.rds`, `cobe_mean.rds`, `kunkel-equip_mean.rds`, `kunkel-site_mean.rds`: a single vector per source. For Kunkel et al. and COBE, emission rates below 3 kg/h are filled in by sampling from the Williams et al. distribution for the same basin (see `CODE2`).
- **Level 4** (`data_level_4/sample_means/basin_level/<basin>/`): one file per Level 3 file, with the same name. Each is a matrix with 1,250 rows (replicates) and one column per sample size *s* = 1, …, *n*, where *n* is the length of the Level 3 vector. Entry `[r, s]` is the mean of a random sample of size *s*, drawn without replacement, in replicate *r*. The Denver–Julesburg folder also contains `sherwin_mean_heatmap1.rds` to `sherwin_mean_heatmap50.rds` (see [heatmap scripts](#heatmap-scripts)).
- **Level 5** (`data_level_5/metrics/basin_level/<basin>/`): `<source>_mean.rds` is a list of 12 vectors, each with one value per sample size. In every case the percent error is `100 * (sample mean - true mean) / true mean`, where the true mean is the mean of the Level 3 vector.
  - `median`: median percent error across replicates
  - `max.error`: maximum percent error across replicates (signed, so this is the largest overestimate)
  - `within10`, `within20`, …, `within100`: fraction of replicates whose absolute percent error is below 10%, 20%, …, 100%
  - `sherwin_mean_heatmap.rds` (Denver–Julesburg only) is described under [heatmap scripts](#heatmap-scripts).

## Quick start

### 1. Install R packages

```r
install.packages(c("foreach", "doParallel", "scales", "viridis", "fields",
                   "moments", "lubridate", "lmom", "RColorBrewer"))
```

(`data.table` is also used by `CODE1`, which cannot be run.) The scripts were developed on macOS. The parallel code uses `doParallel` clusters, which also work on Linux and Windows.

### 2. Point the scripts at the data

Download the Zenodo archive, unzip it, and set `zenodo.dir` near the top of each of the eight scripts that define it (`CODE3_*`, `CODE4_*`, `FIG1`–`FIG4`). To find them:

```bash
grep -n "^zenodo.dir <-" code/*.R
```

```r
zenodo.dir <- "/path/to/unzipped/zenodo/archive/"   # keep the trailing slash
```

The trailing slash is required, because paths are built with `paste0(zenodo.dir, "data_level_3/...")`.

### 3. Run from the `code/` directory

The figure scripts write to `../figures/`, so set the working directory to `code/` and make sure a `figures/` folder exists next to it.

```bash
cd code
Rscript FIG1_plot_data.R
```

or, in an R session, `setwd("code")` and then `source("FIG1_plot_data.R")`.

### 4. Choose where to start

Because each level is archived on Zenodo, you can start from whichever level you need:

| To reproduce | Run | Reads |
|---|---|---|
| Figure 1 | `FIG1_plot_data.R` | Level 3 |
| Figure 2 | `FIG2_sampling_overview.R` | Level 3, Level 4 (Denver–Julesburg, Sherwin) |
| Figure 3 | `FIG3_heatmaps.R` | Level 3, Level 5 (heatmap file) |
| Figure 4 | `FIG4_basin_level.R` | Level 3, Level 5 |

To regenerate Level 4 and Level 5 yourself, run the following in order. This is only needed if you want to re-run the simulations, since the archived files are the ones used in the paper.

1. `CODE3_process_L3_to_L4_basins.R` and `CODE3_process_L3_to_L4_heatmap.R` (independent of each other)
2. `CODE4_process_L4_to_L5_basins.R` (needs the CODE3 basins output) and `CODE4_process_L4_to_L5_heatmap.R` (needs the CODE3 heatmap output)
3. The `FIG*` scripts

The `CODE3` and `CODE4` scripts save into `data_level_4/` and `data_level_5/` and **do not create folders**. If you are regenerating those levels in an empty location, create the folders first:

```r
basins <- c("appalachian", "barnette", "denver_julesburg", "permian", "san_joaquin", "uinta")
for (b in basins) {
  dir.create(file.path(zenodo.dir, "data_level_4/sample_means/basin_level", b), recursive = TRUE)
  dir.create(file.path(zenodo.dir, "data_level_5/metrics/basin_level", b),      recursive = TRUE)
}
```

## Script reference

### Level 1 to Level 3 (view only)

**`CODE1_process_L1_to_L2.R`** reads the Williams et al. basin files, each a CSV with 500 columns (realizations) and splits each column into its own `williams_<i>.rds` file under `data_level_2/basin_level/<basin>/`. This makes it quick to load one realization at a time.

**`CODE2_process_L2_to_L3.R`** builds the Level 3 `x_vectors` for each basin and source:

1. Reads the Level 2 emission rates (for Williams et al., all 500 realizations).
2. Randomly down-samples any vector longer than 100,000 elements, then sorts it.
3. For Williams et al., takes the element-wise mean and 2.5th and 97.5th percentiles across the sorted realizations.
4. For Kunkel et al. and COBE, keeps the measured emission rates of 3 kg/h and above and fills in the rates below 3 kg/h by sampling from the Williams et al. mean vector, using the Williams et al. share of emission rates at or above 3 kg/h to set how many to add.
5. Saves the results to `data_level_3/x_vectors/basin_level/<basin>/`.

### Level 3 to Level 4: repeated sampling

**`CODE3_process_L3_to_L4_basins.R`** loops over every file in `data_level_3/x_vectors/basin_level/`. For each vector `x` of length *n* it runs 1,250 replicates (`R`), and in each replicate computes the mean of a random sample (without replacement) of every size from 1 to *n*. The result is a 1,250 × *n* matrix saved to Level 4 under the same file name. Replicates run in parallel (`n.cores <- 6`; change this to suit your machine). This also processes `williams_lower.rds` and `williams_upper.rds`, although only the `_mean` files are used downstream.

**`CODE4_process_L4_to_L5_basins.R`** converts each Level 4 matrix of sample means to percent error relative to the true mean of the corresponding Level 3 vector, and for each sample size computes the 12 metrics listed under [File formats](#file-formats). Results are saved to Level 5.

### Heatmap scripts

These scripts look at how the share of total emissions from the single largest emitter controls sampling error, using the Denver–Julesburg Sherwin et al. distribution.

**`CODE3_process_L3_to_L4_heatmap.R`** removes the largest emission rate from the Denver–Julesburg Sherwin vector and replaces it with a synthetic value `y = p * sum(x) / (1 - p)`, so that the largest emitter accounts for a fraction `p` of total emissions. It does this for 50 values of `p` from 0.035 to 0.1575 in steps of 0.0025, and runs the same repeated sampling as above for each. Outputs are `sherwin_mean_heatmap1.rds` to `sherwin_mean_heatmap50.rds` in `data_level_4/sample_means/basin_level/denver_julesburg/`.

**`CODE4_process_L4_to_L5_heatmap.R`** computes the median error, maximum error, and `within10` metric for each `p` at 3,000 sample sizes spaced evenly from 1 to *n*, and saves a single list to `data_level_5/metrics/basin_level/denver_julesburg/sherwin_mean_heatmap.rds`. Each of its 50 elements (one per `p`) contains `median`, `max.error`, `within10`, `sample.sizes`, and `p.vals`.

### Figures

| Script | Output (in `figures/`) | Description |
|---|---|---|
| `FIG1_plot_data.R` | `data_overview.png` | Cumulative share of total emissions against emission rate, for each basin and source. Williams et al. is shown with a 95% envelope. |
| `FIG2_sampling_overview.R` | `histograms.png`, `heatmap_sample_means.png`, `slices.png` | Worked example for the Denver–Julesburg Sherwin et al. distribution: histograms of the full distribution and three example samples of 200; the density of sample mean error against the fraction of the distribution sampled; and slices of that density at selected sample fractions. Also prints some summary statistics to the console. |
| `FIG3_heatmaps.R` | `heatmap_median.png`, `heatmap_max_error.png`, `heatmap_within10.png` | Median error, maximum error, and probability of being within 10% of the true mean, as a function of sample fraction and the largest emitter's share of total emissions. The dashed line marks the actual share in the Denver–Julesburg distribution. |
| `FIG4_basin_level.R` | `metrics_<metric>.png` (one per metric), `basin_summary_stats.png` | Each Level 5 metric against the fraction of the distribution sampled for all basins and sources, followed by the sample fractions needed to reach selected error thresholds and their relationship to two distribution features (the number of emission rates above 100 kg/h, and the largest emission rate's share of the total). |

## Computational notes

- **`CODE3` is by far the most expensive step.** The work grows roughly with the square of the vector length, since a sample is drawn for every size up to *n*, and Level 3 vectors can be as long as 100,000 elements. Level 4 matrices have 1,250 × *n* entries, so for the longest vectors a single file can be on the order of 1 GB. If you only want to reproduce the figures, use the archived Level 4 and Level 5 files instead of re-running `CODE3`.
- **Re-running `CODE3` is not bit-for-bit reproducible.** `set.seed(1)` seeds the main R process, but the replicates are generated on `doParallel` worker processes whose random number streams are not seeded from it. Re-running will give statistically equivalent results, not identical files. The archived Level 4 and Level 5 files are the exact ones used in the paper.
- The figure scripts are deterministic given the archived data. The example samples in `FIG2` use fixed seeds.

## Troubleshooting

- **`cannot open file ... No such file or directory` when reading data:** check that `zenodo.dir` is set in that script, ends with `/`, and points to the unzipped archive.
- **`cannot open the connection` when saving an `.rds` file:** the output folder does not exist; see the folder-creation snippet in [Quick start](#4-choose-where-to-start).
- **Figures are not written, or `cannot open file '../figures/...'`:** run the script from the `code/` directory and make sure `figures/` exists next to it.

## Citation

If you use this code or data, please cite the paper:

```bibtex
@article{daniels2026sampling,
  author  = {Daniels, William S. and Hammerling, Dorit M.},
  title   = {Future methane measurement campaigns require basin-specific sampling strategies},
  journal = {Communications Earth \& Environment},
  year    = {2026},
  doi     = {10.1038/s43247-026-04089-4}
}
```

and the Zenodo data archive: https://doi.org/10.5281/zenodo.XXXXXXX

For questions or bug reports, please open an issue on this repository.
