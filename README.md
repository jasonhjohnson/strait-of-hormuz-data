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
| [`data/oil.csv`](data/oil.csv) | Brent and WTI front-month futures prices, timestamped. Best-effort hourly since 2026-05-05, with gaps over weekends and whenever the collector is offline. | Hourly, best effort | straits.live |
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
| `methodology_version` | Methodology version the reading was computed under; see <https://straits.live/methodology/changelog> |

`hormuz-index-daily.csv`

| Column | Meaning |
|---|---|
| `date` | Calendar date (UTC) |
| `crisis_open`, `crisis_close`, `crisis_min`, `crisis_max`, `crisis_mean` | Crisis Pressure at day open and close, and its daily minimum, maximum and mean |
| `crisis_band` | Closing band label for Crisis Pressure |
| `forecast_open`, `forecast_close`, `forecast_min`, `forecast_max`, `forecast_mean` | The same five figures for the Escalation Forecast |
| `forecast_band` | Closing band label for the Escalation Forecast |
| `methodology_version` | Methodology version the day ran under. A day that straddled a methodology change lists both, oldest first, e.g. `0.7.1>0.7.2` |

`oil.csv`

| Column | Meaning |
|---|---|
| `timestamp_iso` | ISO 8601 timestamp of the price sample |
| `brent_usd` | Brent crude front-month futures price, USD per barrel |
| `wti_usd` | WTI crude front-month futures price, USD per barrel |
| `brent_symbol` | Delivery-month contract the Brent price came from, e.g. `BZU26.NYM`. Blank on rows older than the field. Compare consecutive rows to tell a contract roll from a market move |
| `wti_symbol` | Delivery-month contract the WTI price came from, e.g. `CLU26.NYM`. Blank on rows older than the field |

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

`status.csv`

One row, 47 columns, in this order. Re-poll to build a history. Columns without a note are named for what they hold; the full text is at <https://straits.live/data>.

| Column | Type | Meaning |
|---|---|---|
| `as_of` | datetime |  |
| `days_since_closure` | integer |  |
| `verdict_status` | string |  |
| `verdict_short` | string |  |
| `ais_status` | string |  |
| `brent_usd` | number | Brent front-month futures price, USD per barrel. While the futures feed has been stale for over 2 hours it carries the EIA daily spot close instead; brent_basis says which |
| `wti_usd` | number | WTI front-month futures price, USD per barrel. Carries the EIA daily spot close in the same cases as brent_usd |
| `brent_change_24h_pct` | number |  |
| `brent_change_source` | string | How brent_change_24h_pct was measured: 'trailing-24h', 'prev-close' or 'frozen-weekend'. Only 'trailing-24h' is a literal 24 hours |
| `insurance_multiple` | number |  |
| `transits_count` | integer |  |
| `transits_baseline` | integer |  |
| `transits_throughput_pct` | number |  |
| `transits_basis` | string |  |
| `transits_cadence` | string |  |
| `transits_source` | string |  |
| `transits_asof_date` | date | Date of the newest IMF PortWatch row behind transits_count (UTC) |
| `transits_asof_age_days` | integer | Age of transits_asof_date in days, relative to today |
| `transits_stale` | boolean | True when transits_count comes from PortWatch and that data is older than the site's staleness limit |
| `ships_transiting` | integer |  |
| `ships_anchored` | integer |  |
| `ships_stopped` | integer |  |
| `ships_stranded` | integer | All-waters rollup of vessels held in the region: every vessel seen holding position in the strait window, including ships at berth at regional ports |
| `ais_dark_tankers` | integer |  |
| `ais_dark_baseline_7d` | number |  |
| `ais_dark_vessels_tracked` | integer |  |
| `sanctioned_in_window` | integer |  |
| `jwc_circular_date` | string |  |
| `jwc_arabian_gulf_mentioned` | boolean |  |
| `carriers_total` | integer |  |
| `carriers_suspended` | integer |  |
| `carriers_rerouting` | integer |  |
| `tehran_toman_per_usd` | number |  |
| `tehran_rial_delta_day_pct` | number |  |
| `tehran_rial_delta_7d_pct` | number |  |
| `events_recent_count` | integer |  |
| `data_oil_source` | string |  |
| `data_ships_source` | string |  |
| `data_events_source` | string |  |
| `ships_basis` | string | Counting basis for the ships_* columns, e.g. 'tiled12-active30m-fix60': a vessel counts only if sighted in the last 30 minutes and its position fix is not stale. The basis changed on 2026-07-20, 2026-07-30 and 2026-09-26, so the ships_* series has breaks at those dates |
| `carriers_hormuz_stopped` | integer | Count of carriers whose Hormuz posture is 'stopped', whatever the age of the advisory. carriers_suspended is always 0, so use this column instead |
| `carriers_hormuz_stopped_current` | integer | Of carriers_hormuz_stopped, the carriers whose own advisory is 60 days old or less; the count the site's open/closed verdict uses |
| `tehran_rate_basis` | string | How tehran_toman_per_usd was obtained: 'direct' is a quoted dollar rate, 'cross-aed' is implied from the UAE dirham rate at the 3.6725 peg because the source is not quoting the dollar |
| `transits_provisional` | boolean | True while the newest PortWatch row is within 3 days of today and can still be revised on the next publish |
| `transits_ma7` | number | 7-day mean of daily transits ending on transits_asof_date; empty when those 7 days are not contiguous |
| `ships_stranded_offshore` | integer | Subset of ships_stranded waiting offshore: leaves out vessels within 25 km of a working port. The figure the site's own text uses |
| `brent_basis` | string | What brent_usd and wti_usd are: 'futures' (front-month futures) or 'eia-spot' (EIA daily spot close, used as a backstop when the futures feed is down; a different instrument that can sit $20 or more above futures). Empty when there is no Brent value |

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
