# FTS Data Store

This repository automatically fetches data from the [OCHA FTS API](https://api.hpc.tools/docs/v2/) and stores it as static files. No API credentials needed to consume the data.

## Using the data

All files are available as raw GitHub URLs:

```
https://raw.githubusercontent.com/{owner}/{repo}/main/data/{slug}/latest.json
```

Browse available datasets and their update times via the index:

```
https://raw.githubusercontent.com/{owner}/{repo}/main/data/index.json
```

### Example fetch in a static site

```js
const res = await fetch(
  'https://raw.githubusercontent.com/{owner}/{repo}/main/data/flow_2025/latest.json'
)
const data = await res.json()
```

## Data structure

```
data/
  index.json                        ← master list of all datasets + last updated
  flow_2025/
    latest.json                     ← always the most recent fetch
    2025-06-04.json                 ← date-stamped archive
  flow_2025_sdn/
    latest.json
    2025-06-04.json
  ...
```

## Triggering a fetch manually

1. Go to **Actions** → **Fetch FTS Data** → **Run workflow**
2. Fill in the parameters you want (endpoint, year, country, etc.)
3. Choose JSON or XML output
4. Click **Run workflow** — the file appears in `data/` within ~30 seconds

Notes: When a workflow request is made with parameters that haven't been used before, a new folder will appear inside of the data folder containing a dated (e.g., 2025-06-04.json) file from your current request and a latest.json file containing the same data. As more workflow requests with those same parameters come in, this latest.json file updates to the content of the most recent pull. After a while inside each folder will be several dated .json files and one latest.json file. Therefore any static site should point to the latest.json file in the workflow request needed as it will always contain the most up-to-date data.

## Scheduled fetches

Edit `scripts/scheduled-queries.sh` to control what runs automatically each day at 7am UTC.

## Secrets required (repo owner only)

| Secret | Value |
|--------|-------|
| `FTS_CLIENT_ID` | Your HPC Tools client ID |
| `FTS_PASSWORD` | Your HPC Tools password |

Request credentials at ocha-hpc@un.org.
