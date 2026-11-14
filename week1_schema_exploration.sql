-- ============================================================
-- IDX Exchange — Data Analyst Internship
-- Week 1: Schema Exploration - Learning the Database Before You Can Query It
-- Tables: rets_openhouses.sql, rets_property.sql, california_sold.sql
-- Author: Brett Loy
-- ============================================================
/*

EDA Summary for rets_property

Regarding null values, most of the null values are in columns that are not very relevant. In the relevant 
columns like price, beds, square foot, or city, there is less than 1% null values. As we check for duplicates, 
there are no duplicates in the rets_property dataset and all rows have distinct IDs. In this dataset checking 
for outliers and inconsistencies is where it gets interesting. For example there are many outliers where the 
price's maximum is 135 million while the minimum is $795. So many variables have outliers and doing an IQR 
filtering method might be best, as well as using the median to find the middle in this dataset. Similarly there 
are some inconsistencies, such as close_date values being in the future. These outliers and inconsistencies 
should be flagged as data quality concerns. In total, with some cleaning and filtering, this dataset can be trusted.

*/



-- Exercise 1.1 Discovering What Tables Exist

-- List all tables
SHOW TABLES;
-- just shows table names
 
-- More detail: table sizes and row counts via INFORMATION_SCHEMA
SELECT TABLE_NAME,
       TABLE_ROWS,
       ROUND(DATA_LENGTH / 1024 / 1024, 2) AS size_mb
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'rets'
ORDER BY TABLE_ROWS DESC;
-- can show tale names, amount of rows(ordered), and size


-- Exerise 1.2 Understand a Table's Structure
-- Quick column overview
DESCRIBE rets_property;
 
-- Full detail via INFORMATION_SCHEMA
SELECT COLUMN_NAME,
       DATA_TYPE,
       IS_NULLABLE,
       CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'rets'
  AND TABLE_NAME   = 'rets_property'
ORDER BY ORDINAL_POSITION;
-- manual way of DESCRIBE

-- Exercise 1.3 Profile Column Quality
-- NULL rate check across key columns
SELECT
  COUNT(*)                                                AS total_rows,
  SUM(CASE WHEN L_SystemPrice IS NULL THEN 1 ELSE 0 END)     AS price_nulls,
  SUM(CASE WHEN L_Keyword2 IS NULL THEN 1 ELSE 0 END) AS beds_nulls,
  SUM(CASE WHEN LM_Int2_3 IS NULL THEN 1 ELSE 0 END)    AS sqft_nulls,
  SUM(CASE WHEN L_City IS NULL THEN 1 ELSE 0 END)          AS city_nulls
FROM rets_property;

-- Distribution check: what values does L_Status actually contain?
SELECT L_Status,
COUNT(*) AS total
FROM rets_property
GROUP BY L_Status
ORDER BY total DESC;

-- Sanity check: are numeric columns within realistic ranges?
SELECT
MIN(L_SystemPrice) AS min_price, MAX(L_SystemPrice) AS max_price,
MIN(L_Keyword2) AS min_beds, MAX(L_Keyword2) AS max_beds,
MIN(LM_Int2_3) AS min_sqft, MAX(LM_Int2_3) AS max_sqft
FROM rets_property
WHERE L_SystemPrice IS NOT NULL;

-- Exercise 1.4 Check for Duplicates

-- Quick summary: total rows vs distinct L_DisplayIds
SELECT COUNT(*) AS total_rows,
COUNT(DISTINCT L_DisplayId) AS distinct_ids,
COUNT(*) - COUNT(DISTINCT L_DisplayId) AS duplicates
FROM rets_property;

-- Detail: which L_DisplayIds appear more than once?
SELECT L_DisplayId, COUNT(*) AS occurrences
FROM rets_property
GROUP BY L_DisplayId
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;

-- Exercise 1.5 — Cardinality Check Between Tables

-- How many open house rows exist per listing? (expect one-to-many)
SELECT
COUNT(DISTINCT L_DisplayId) AS distinct_listings,
COUNT(*) AS total_rows,
ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT L_DisplayId), 1) AS avg_rows_per_listing
FROM rets_openhouse;

-- How many rets_property listings have NO match in rets_openhouse?
SELECT COUNT(*) AS listings_without_openhouse
FROM rets_property p
WHERE NOT EXISTS (
SELECT 1 FROM rets_openhouse o WHERE o.L_DisplayId = p.L_DisplayId
);

-- Describe and check null rates for california_sold
DESCRIBE california_sold;

-- Nulls of ClosePrice and Close_Date, none
SELECT
  COUNT(*) AS total_rows,
  SUM(CASE WHEN `ClosePrice` IS NULL THEN 1 ELSE 0 END) AS price_nulls,
  SUM(CASE WHEN `CloseDate` IS NULL THEN 1 ELSE 0 END) AS date_nulls
FROM california_sold;

-- Distribution of Close_Date
SELECT CloseDate,
COUNT(*) AS total
FROM california_sold
GROUP BY CloseDate
ORDER BY CloseDate DESC;
-- dates from 2025-2072. possibly some error close dates in future flag

-- Do city names match between the two tables?
SHOW COLUMNS FROM california_sold LIKE '%city%';
SHOW COLUMNS FROM rets_property LIKE '%city%';

-- Cities in california_sold but NOT in rets_property
SELECT DISTINCT City
FROM california_sold
WHERE City NOT IN (
	SELECT DISTINCT L_City FROM rets_property
	WHERE L_City IS NOT NULL
)
ORDER BY City
LIMIT 20;

-- BROKEN: Count listings with missing price
SELECT COUNT(*) AS missing_prices
FROM rets_property
WHERE L_SystemPrice IS NULL; -- Bug: this will never match anything

-- = NULL doesn't work because NULL is not a value. so we use IS or IS NOT


-- Week 1 Deliveragles

-- ANALYSIS for each dataset 
DESCRIBE rets_property;

-- duplicates
SELECT
  (SELECT COUNT(*) FROM california_sold) AS total_rows,
  (SELECT COUNT(*) FROM (SELECT DISTINCT * FROM california_sold) AS t) AS unique_rows;
-- 179 duplicate values
DESCRIBE california_sold;

DESCRIBE rets_openhouse;

-- Week 1 Open-Ended Challenge:






