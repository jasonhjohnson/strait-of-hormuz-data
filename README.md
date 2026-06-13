# Strait of Hormuz crisis data

Open, daily-refreshed time series behind [straits.live](https://straits.live),
the real-time Strait of Hormuz crisis monitor. Every series here is free, needs
no API key, and is mirrored automatically from the site's public endpoints.

If you are building a chart, a model, a bot, or a story about the Strait of
Hormuz, this is the data, in plain CSV and JSON, with a documented column
contract. The live dashboard is at **<https://straits.live>**, the methodology
is at **<https://straits.live/methodology>**, and the machine-readable status
bundle is at **<https://straits.live/status>**.

## Datasets

All files live in [`data/`](data/) and refresh once a day (see
[How it updates](#how-it-updates)).

| File | What it is | Cadence | Source |
|---|---|---|---|
| [`data/transits.csv`](data/transits.csv) | Daily vessel-transit counts through the strait. The series the major prediction-market reopening contracts (Kalshi `KXHORMUZNORM`, Polymarket) resolve on, via its 7-day moving average against a 60-transit threshold. | Daily rows, weekly IMF publish | IMF PortWatch |
| [`data/hormuz-index.csv`](data/hormuz-index.csv) | The composite Hormuz Index: Crisis Pressure and Escalation Forecast, both 0-100, joined on timestamp with band labels. 5-minute resolution, last 7 days. | 5-minute | straits.live (computed) |
| [`data/hormuz-index-daily.csv`](data/hormuz-index-daily.csv) | Daily open/high/low/close rollup of both index composites, full history. | Daily | straits.live (computed) |
| [`data/oil.csv`](data/oil.csv) | Brent and WTI crude spot prices, timestamped. | 5-minute, rolling ~7 days | straits.live |
| [`data/events.csv`](data/events.csv) | Indexed strikes, ship incidents, closures, and diplomatic developments, each with a cited source URL. | As indexed | straits.live |
| [`data/status.csv`](data/status.csv) | One-row snapshot of the current dashboard state. | Latest poll | straits.live (computed) |
| [`data/status.json`](data/status.json) | The full live status bundle (verdict, transits, Brent, insurance, Hormuz Index summary, carriers, events). The recommended machine entry point. | Latest poll | straits.live (computed) |
| [`data/hormuz-index.json`](data/hormuz-index.json) | Current Hormuz Index reading with per-component breakdown plus 24h history. | 5-minute | straits.live (computed) |
| [`data/transits.json`](data/transits.json) | Same transit series as `transits.csv` with the full vessel-type and capacity breakdown on the latest record. | Daily | IMF PortWatch |

### Column contracts

`transits.csv` and `transits.json`

| Column | Meaning |
|---|---|
| `date` | Calendar date of the transit count (UTC) |
| `n_total` | Total vessel transits recorded that day |
| `n_tanker` | Tanker transits |
| `n_cargo` | Cargo-vessel transits |

`hormuz-index.csv`

| Column | Meaning |
|---|---|
| `timestamp_iso` | ISO 8601 timestamp of the reading |
| `crisis_pressure` | Crisis Pressure Index, 0 to 100 |
| `crisis_band` | Band label for the Crisis Pressure value |
| `escalation_forecast` | Escalation Forecast Index, 0 to 100 |
| `forecast_band` | Band label for the Escalation Forecast value |

`oil.csv`

| Column | Meaning |
|---|---|
| `timestamp_iso` | ISO 8601 timestamp of the price sample |
| `brent_usd` | Brent crude spot price, USD per barrel |
| `wti_usd` | WTI crude spot price, USD per barrel |

`events.csv`

| Column | Meaning |
|---|---|
| `occurred_at_iso` | ISO 8601 timestamp the event occurred |
| `type` | Event class: `strike`, `ship_incident`, `closure`, or `negotiation` |
| `severity` | Severity label where assigned |
| `title` | Short event headline |
| `description` | Event summary |
| `lat`, `lng` | Coordinates where geolocated |
| `source_name` | Publication the event is cited from |
| `source_url` | Direct link to the cited source |

The CSV column order is a stable contract: new columns are appended, never
reordered or renamed.

## How it updates

A scheduled [GitHub Action](.github/workflows/refresh.yml) runs
[`scripts/refresh.sh`](scripts/refresh.sh) once a day. It curls the public
straits.live endpoints, writes the files into `data/`, and commits anything
that changed. There are no secrets and no servers: it runs entirely on GitHub's
hosted runners against the live public API, so the mirror keeps refreshing on
its own. You can run the same script locally with `bash scripts/refresh.sh`.

## Cite this

> Strait of Hormuz crisis data, straits.live, <https://straits.live/data>.

For the transit series specifically, also credit IMF PortWatch (see Licensing).

## Licensing

The **code** in this repository (the refresh script and workflow) is MIT
licensed; see [`LICENSE`](LICENSE).

The **data** carries per-series terms, matching the policy published at
<https://straits.live/data> and <https://straits.live/methodology>:

| Series | Terms |
|---|---|
| Hormuz Index (`hormuz-index.*`), status snapshot (`status.*`) | CC0. These are straits.live's own computed work; no attribution required. |
| Daily transits (`transits.*`) | Free to use; the underlying transit data is &copy; IMF PortWatch. Cite IMF PortWatch when you republish. |
| Oil prices (`oil.csv`) | Free to use; attribution requested. |
| Events (`events.csv`) | Free to use; each row carries its own cited source. |

When in doubt, "data: straits.live" with a link is always enough for the
computed series.

## Related

- Live dashboard: <https://straits.live>
- Data downloads page: <https://straits.live/data>
- Methodology and indicator catalogue: <https://straits.live/methodology>
- Reopening tracker: <https://straits.live/when-will-the-strait-of-hormuz-reopen>
- Machine-readable status: <https://straits.live/status>
