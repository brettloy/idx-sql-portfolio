-- ============================================================
-- IDX Exchange — Data Analyst Internship
-- Week 2: SELECT, WHERE, & ORDER BY
-- Tables: rets_property.sql
-- Author: Brett Loy
-- ============================================================


-- Exercise 2.1 — Select Specific Columns
SELECT L_DisplayId, L_Address, L_City, L_SystemPrice,
L_Keyword2, LM_Dec_3
FROM rets_property
LIMIT 20;

-- Exercise 2.2 — Filtering with WHERE
-- Properties in a specific city
SELECT L_DisplayId, L_Address, L_SystemPrice, L_Keyword2
FROM rets_property
WHERE L_City = 'Irvine'
LIMIT 20;

-- or 3+ bedroom homes under $700k
SELECT L_Address, L_City, L_SystemPrice, L_Keyword2
FROM rets_property
WHERE L_Keyword2 >= 3
AND L_SystemPrice < 700000
ORDER BY L_SystemPrice ASC;

-- Exercise 2.3 — BETWEEN and LIKE
-- Properties between $400k and $600k
SELECT L_Address, L_City, L_SystemPrice
FROM rets_property
WHERE L_SystemPrice BETWEEN 400000 AND 600000
ORDER BY L_SystemPrice;

-- Cities starting with 'San'
SELECT DISTINCT L_City
FROM rets_property
WHERE L_City LIKE 'San%';

-- Exercise 2.4 — NULL Handling
-- Listings missing square footage
SELECT L_DisplayId, L_Address, L_City
FROM rets_property
WHERE LM_Int2_3 IS NULL;

-- Listings with square footage, largest first
SELECT L_DisplayId, L_Address, L_City, LM_Int2_3
FROM rets_property
WHERE LM_Int2_3 IS NOT NULL
ORDER BY LM_Int2_3 DESC
LIMIT 10;

-- BROKEN: 10 cheapest listings in Irvine with a valid price
SELECT L_Address, L_City, L_SystemPrice
FROM rets_property
WHERE L_City = 'Irvine' -- Bug 1
AND L_SystemPrice IS NOT NULL
ORDER BY L_SystemPrice ASC
LIMIT 10; -- Bug 2

DESCRIBE rets_property;

-- Q1: How many total listings are in rets_property? 17,523
SELECT COUNT(*) L_ListingID 
FROM rets_property;

-- Q2: Top 10 most expensive listings (address, city, price)
SELECT L_Address, L_City, L_SystemPrice
FROM rets_property
ORDER BY L_SystemPrice DESC
LIMIT 10;

-- Q3: All listings with 4+ bedrooms
SELECT *
FROM rets_property
WHERE L_Keyword2 >= 4;
-- Q4: All listings in a ZIP code of your choosing
SELECT L_ListingID, L_Zip
FROM rets_property
WHERE L_Zip = 94404;

-- Q5: Properties over 3,000 sqft under $1M
SELECT L_ListingID, LM_Int2_3, L_SystemPrice
FROM rets_property
WHERE LM_Int2_3 >= 3000
AND L_SystemPrice < 1000000
LIMIT 20;

-- Q6: Every distinct city — no duplicates
SELECT DISTINCT L_City
FROM rets_property;









