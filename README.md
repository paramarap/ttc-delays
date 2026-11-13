# TTC Subway Delays, 2023 to 2025

An analysis of about 75,000 TTC subway delay records, built with SQL (DuckDB) and a Tableau dashboard.

- Write-up: [Substack link]
- Dashboard: [Tableau Public link]

## Question

What causes the most subway delay time, and has that changed since 2023?

## Data

TTC Subway Delay Data, published by the Toronto Transit Commission on the City of Toronto Open Data portal under the Open Government Licence - Toronto: https://open.toronto.ca/dataset/ttc-subway-delay-data/

Files used:

- `ttc-subway-delay-data-2023.xlsx`
- `ttc-subway-delay-data-2024.xlsx`
- `TTC_Subway_Delay_Data_since_2025.csv`
- `Code_Descriptions.csv` (delay code lookup)
- `ttc-subway-delay-codes.xlsx` (source of the SRT and `PUTO` codes in `extra_codes.csv`)
- `ttc-subway-delay-data-readme.xlsx` (column definitions)

Analysis covers 2023 to 2025 only. The 2026 data is a partial year and is left out of comparisons.

## Tools

DuckDB (SQL), Tableau Public, GitHub.

## How to rerun

1. Put the source files in `raw/` (keep the file names above, plus `extra_codes.csv` and `theme_overrides.csv`).
2. From the repo folder, open DuckDB and run the scripts in order:

```
duckdb ttc.duckdb
.read sql/00_clean.sql
.read sql/03_themes.sql
```

3. Run the analysis and export scripts in `sql/` as needed. Dashboard files are written to `clean/`.

`00_clean.sql` reads the XLSX files with DuckDB's Excel extension. If it won't install, save the XLSX files as CSV and swap `read_xlsx` for `read_csv_auto`.

## What is in the repo

| Folder or file | Purpose |
|---|---|
| `raw/` | Original downloads, never edited |
| `sql/00_clean.sql` | Combines and cleans the sources, builds the `delays` table |
| `sql/01_shape.sql`, `02_causes.sql` | First looks at the data and delay causes |
| `sql/03_themes.sql` | Groups delay codes into themes |
| `sql/04_theme_analysis.sql` | Theme-level analysis |
| `clean/` | Cleaned data, theme review list, dashboard summary files |
| `raw/theme_overrides.csv` | My theme decisions, applied on top of the automatic rules |
| `dashboard/` | Dashboard screenshot |

## Cleaning decisions

- **Combining:** three delay sources with the same columns are stacked into one table. The extra `_id` column in the CSV is dropped.
- **Duplicates:** exact duplicate rows are removed.
- **Line:** many spellings (`YU`, `YUS`, `YU / BD` and so on) are mapped to `YU`, `BD`, `SHP`, `SRT`, `MULTIPLE`, or `UNKNOWN`.
- **Station:** the column is free text. I cut everything after the word "STATION", remove trailing line tags, and group names with fewer than 20 incidents into `OTHER / NOT A STATION`. Interchange stations (Bloor, St George, Spadina) end up as one name, so use the `line` column to separate platforms.
- **Delay codes:** the code list had garbled characters and a typo, which are fixed in the script. SRT codes and `PUTO` come from the TTC's own code workbook. Codes with no description anywhere (mostly new in 2026) are labelled `UNMAPPED`.
- **Dates and times:** stored as ISO text so they cannot be misread when exported.

## Themes

The TTC has nearly 200 delay codes. I grouped them into themes to make them readable. This is my judgment, not a TTC classification.

| Theme | What it covers |
|---|---|
| Customers and security | Disorderly patrons, assaults, unauthorized track access, alarms, graffiti, unsanitary vehicles |
| Medical and injuries | Injured or ill customers and employees, escalator and elevator incidents |
| Track, signals and infrastructure | Track, signal, power, and communications problems |
| Operators and crew | Operator and transportation department issues |
| Vehicles | Rolling stock and equipment problems |
| Fire, weather and external | Fire and smoke, weather, external power failures |
| One-person train operation (OPTO) | Door monitoring codes recorded under three departments |
| Other | Codes no rule claimed, such as miscellaneous |
| Unmapped code | No description in any TTC list |

Rules propose a theme for every code, and `raw/theme_overrides.csv` changes any I disagreed with. To change a theme, edit that file and rerun `03_themes.sql`.

## Key findings

- About 65% of incidents have zero delay minutes. A small number of long delays account for a large share of total minutes, so incident counts and minute totals tell different stories.
- Total delay minutes by year: 68,146 (2023), 74,266 (2024), 70,755 (2025).
- Customer and security delay fell from 2023 to 2025, while infrastructure, weather, and operator-related delay rose.
- The February 2025 spike on the monthly trend comes from a few weather-coded incidents on one day.
- Per day, weekends have fewer delay minutes than weekdays, but the gap is much smaller than raw totals suggest.

## Limitations

- Themes are subjective and unavoidably simplify the TTC's codes.
- Delay minutes measure recorded delay, not rider impact.
- Station names are cleaned by rules, so a few variants may remain.
- Code descriptions are missing for codes added in 2026.
- A code in the data is what the TTC recorded, not a verified root cause.

## Next steps

- Practice joins and combining tables from a blank file.
- Learn window functions properly.
- Look into the `Min Gap` column, which this analysis does not use.
