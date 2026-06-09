# FTS Data Extractor

This repository automatically fetches data from the [OCHA FTS API](https://api.hpc.tools/docs/v1/) and stores it as static files — both JSON and Excel. No API credentials needed to consume the data.

## Using the data

All files are available as raw GitHub URLs:

```
https://raw.githubusercontent.com/{owner}/{repo}/main/data/{slug}/latest.json
https://raw.githubusercontent.com/{owner}/{repo}/main/data/{slug}/latest.xlsx
```

Browse available datasets and their update times via the index:

```
https://raw.githubusercontent.com/{owner}/{repo}/main/data/index.json
```

### Example fetch in a static site

```js
const res = await fetch(
  'https://raw.githubusercontent.com/jayasekhon/OCHA_API_FETCH/main/data/funding_2026/latest.json'
)
const data = await res.json()
```

## Folder structure

Each workflow run creates a date-stamped file and updates the `latest` file in the relevant folder. Point anything consuming this data at the `latest` file so it always stays up to date.

```
data/
  index.json                          ← master list of all datasets + last updated
  funding_2026/
    latest.json                       ← always the most recent fetch
    latest.xlsx                       ← Excel version of the most recent fetch
    2026-06-08.json                   ← date-stamped archive
    2026-06-08.xlsx
  flow_2026_ukr_wfp/
    latest.json
    latest.xlsx
    2026-06-08.json
    2026-06-08.xlsx
  ...
```

## Available workflows

Each workflow can be triggered manually via **Actions** → select workflow → **Run workflow**.

| Workflow | What it fetches | Key parameters |
|---|---|---|
| **Fetch — Funding** | Funding flows grouped by organisation — gives both donor and recipient views | year, country, emergency, plan, destination org/sector |
| **Fetch — Flows** | Individual or grouped funding flows | year, country, org, emergency, plan, sector, groupby |
| **Fetch — Emergencies** | Emergency records | emergency ID, year, or country |
| **Fetch — Plans** | Humanitarian response plans | plan ID, plan code, year, or country |
| **Fetch — Locations** | Reference list of all countries and regions | — |
| **Fetch — Organisations** | Reference list of all organisations | — |

All workflows produce both a JSON file and an Excel file in the relevant `data/` folder.

### Output folder naming

Folders are named automatically from the parameters used, e.g.:

- `funding_2026` — global funding, 2026
- `funding_2026_ukr` — Ukraine funding, 2026
- `flow_2026_ukr_wfp` — flows to WFP in Ukraine, 2026
- `emergency_ukr` — emergencies in Ukraine
- `plan_2026` — all plans for 2026
- `location` — full location reference list
- `organization` — full organisation reference list

### Excel output

The **Fetch — Funding** workflow produces an Excel workbook with four sheets:

| Sheet | Contents |
|---|---|
| **All Reports** | Combined view of all four reports |
| **Donors** | Source organisations (who gave), sorted by total funding |
| **Recipients** | Destination organisations (who received), all incoming flows |
| **Recipients (Net)** | Destination organisations, net of outgoing flows |
| **Outgoing Recipients** | Destination organisations for outgoing flows only |

Each sheet includes a **% of Total** column calculated from the report's grand total.

## Scheduled fetches

Automated daily fetches are controlled by a single file:

```
.github/workflows/scheduled-daily.yml
```

This runs at **07:00 UTC every day**. To add or remove a scheduled fetch, edit that file — each job is a commented-out block you can enable by removing the `#` characters. The file contains examples for every available workflow.

Currently scheduled:

| Job | Dataset | Frequency |
|---|---|---|
| Funding 2026 (Global) | `funding_2026` | Daily |

> **Tip:** Location and organisation reference data changes infrequently. Consider adding those to a separate `scheduled-weekly.yml` with a Monday-only cron (`0 7 * * 1`) rather than running them daily.

## Secrets required (repo owner only)

| Secret | Value |
|---|---|
| `FTS_CLIENT_ID` | Your HPC Tools client ID |
| `FTS_PASSWORD` | Your HPC Tools password |

Request credentials at ocha-hpc@un.org.
