# SQL Data Analysis: Real Estate Listings (IDX Exchange)

SQL work from my Data Analyst Internship at **IDX Exchange**, analyzing California real estate listing data in MySQL. The repo follows the internship's weekly structure, starting with schema exploration and data-quality checks and building up to multi-table analysis with JOINs.

## Tools

- **MySQL**: database engine
- **DBeaver**: SQL client for writing and running queries
- **Python / pandas** (optional): column-level profiling outside SQL

## Data

The queries run against a `rets` database built from MLS (RETS) listing feeds.

| Table | Description |
|---|---|
| `rets_property` | Current property listings: ID, address, city, price, square footage, bedrooms, status |
| `rets_openhouse` | Open house events, linked to listings by `L_DisplayId` |
| `california_sold` | Closed sales, including close date and close price |

> **Note:** Raw data is not included in this repo. The queries are provided for reference and require access to the `rets` database.

**Key columns used**

| Column | Meaning |
|---|---|
| `L_DisplayId` | Listing ID; the join key between `rets_property` and `rets_openhouse` |
| `L_City` | City |
| `L_SystemPrice` | List price |
| `LM_Int2_3` | Square footage |
| `L_Keyword2` | Bedrooms |
| `L_Status` | Listing status |

## Repository Structure

```
├── week1_schema_exploration.sql   # Table structure, column types, distributions
├── week2_queries.sql              # Data quality: NULLs, duplicates, distinct values
├── week3_queries.sql              # Aggregations: GROUP BY, HAVING, city-level metrics
├── week4_joins.sql                # Multi-table analysis with INNER and LEFT JOINs
└── README.md
```

## What's Covered

### Week 1: Schema Exploration
- Inspecting tables with `DESCRIBE` and `SHOW COLUMNS`
- Distribution checks with `GROUP BY` + `COUNT(*)`
- Finding unique values with `DISTINCT` and `COUNT(DISTINCT ...)`

### Week 2: Data Quality
- Counting and calculating the **percentage of NULLs** per column
- Generating a null-check query for every column via `information_schema`
- Detecting **duplicate listings** by ID and fully duplicated rows
- Comparing city names across tables with `NOT IN` subqueries (with NULL-safe filtering)

### Week 3: Aggregation & Metrics
- Average price by city, filtered to cities with more than 50 listings (`HAVING`)
- **Price per square foot** by city, using `NULLIF` to guard against divide-by-zero
- Filtering by bedroom count with `BETWEEN`

### Week 4: JOINs
- `INNER JOIN` vs. `LEFT JOIN` between listings and open houses
- Counting open houses per listing
- Finding listings with **zero open houses** (anti-join: `LEFT JOIN` + `IS NULL`)
- Comparing **average list price for listings with 0 vs. 1+ open houses** using a subquery and `CASE`

## Example Query

```sql
-- Average listing price: listings with vs. without open houses
SELECT CASE WHEN num_open_houses = 0 THEN 'No open house'
            ELSE '1+ open houses' END AS open_house_group,
       COUNT(*) AS num_listings,
       ROUND(AVG(L_SystemPrice), 2) AS avg_price
FROM (
    SELECT p.L_DisplayId,
           p.L_SystemPrice,
           COUNT(o.L_DisplayId) AS num_open_houses
    FROM rets_property p
    LEFT JOIN rets_openhouse o ON p.L_DisplayId = o.L_DisplayId
    GROUP BY p.L_DisplayId, p.L_SystemPrice
) AS per_listing
GROUP BY open_house_group;
```

## Findings & Notes

- `rets_property` contains **only Active listings** (17,523 rows). It's a current-inventory snapshot, so sale-price analysis uses `california_sold`.
- Averages for home prices are pulled upward by high-end properties; medians give a better "typical" price.
- Differences in price between listings with and without open houses are correlational, not causal.

## How to Run

1. Connect to the `rets` MySQL database in DBeaver (or any MySQL client).
2. Open a `.sql` file from this repo.
3. Run queries individually (Cmd/Ctrl + Enter) to see each result.

## Author

**Brett Loy**
M.S. Applied Analytics, USC · B.S. Statistics (Data Science Track), UC Davis
Data Analyst Intern, IDX Exchange
