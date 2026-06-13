---
pretty_name: Strait of Hormuz Crisis Data
license: other
license_name: mixed-per-series
license_link: https://straits.live/data
language:
  - en
tags:
  - geopolitics
  - maritime
  - shipping
  - energy
  - oil
  - time-series
  - osint
size_categories:
  - 1K<n<10K
source_datasets:
  - original
configs:
  - config_name: transits
    data_files:
      - split: train
        path: data/transits.csv
  - config_name: hormuz_index
    data_files:
      - split: train
        path: data/hormuz-index.csv
  - config_name: hormuz_index_daily
    data_files:
      - split: train
        path: data/hormuz-index-daily.csv
  - config_name: oil
    data_files:
      - split: train
        path: data/oil.csv
  - config_name: events
    data_files:
      - split: train
        path: data/events.csv
---

# Strait of Hormuz Crisis Data

Open, daily-refreshed time series behind [straits.live](https://straits.live),
the real-time Strait of Hormuz crisis monitor. Free, no API key. Mirrored
automatically from the site's public endpoints; canonical home and methodology
at **<https://straits.live/data>** and **<https://straits.live/methodology>**.

## Configurations

| Config | Rows are | Source |
|---|---|---|
| `transits` | Daily vessel-transit counts through the strait. The series the major prediction-market reopening contracts (Kalshi `KXHORMUZNORM`, Polymarket) resolve on. | IMF PortWatch |
| `hormuz_index` | The composite Hormuz Index (Crisis Pressure + Escalation Forecast), 0-100, at 5-minute resolution. | straits.live (computed) |
| `hormuz_index_daily` | Daily open/high/low/close/mean rollup of both index composites. | straits.live (computed) |
| `oil` | Brent and WTI crude spot prices, timestamped. | straits.live |
| `events` | Indexed strikes, ship incidents, closures, and diplomatic developments, each with a cited source URL. | straits.live |

```python
from datasets import load_dataset

transits = load_dataset("REPLACE_WITH_HF_USERNAME/strait-of-hormuz-crisis-data", "transits")
index = load_dataset("REPLACE_WITH_HF_USERNAME/strait-of-hormuz-crisis-data", "hormuz_index")
```

## Column contracts

**transits**: `date`, `n_total`, `n_tanker`, `n_cargo`.
**hormuz_index**: `timestamp_iso`, `crisis_pressure` (0-100), `crisis_band`, `escalation_forecast` (0-100), `forecast_band`.
**hormuz_index_daily**: `date`, then `crisis_*` and `forecast_*` open/close/min/max/mean plus closing band labels.
**oil**: `timestamp_iso`, `brent_usd`, `wti_usd`.
**events**: `occurred_at_iso`, `type`, `severity`, `title`, `description`, `lat`, `lng`, `source_name`, `source_url`.

## Licensing

Per-series, matching <https://straits.live/data>:

- **Hormuz Index** and **status**: CC0, straits.live's own computed work, no attribution required.
- **transits**: free to use; underlying data (c) IMF PortWatch, cite IMF PortWatch when republishing.
- **oil**: free to use, attribution requested.
- **events**: free to use, each row carries its own cited source.

## Citation

> Strait of Hormuz crisis data, straits.live, https://straits.live/data

## Updates

Refreshed daily from the public straits.live API. Source repository and the
refresh job: <https://github.com/REPLACE_WITH_GH_USERNAME/strait-of-hormuz-data>.
