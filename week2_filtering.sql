-- ============================================================
-- IDX Exchange — Data Analyst Internship
-- Week 2: SELECT, WHERE, & ORDER BY
-- Tables: rets_property.sql
-- Author: Brett Loy
-- ============================================================
/*
What is affordable?

From my queries in the open-ended challenge, I looked at four different angles on affordability: 
lowest price per city, value per bedroom, Price per city with number of listings over 50, and 
price per square foot with listings over 50. I think it depends on what the client is looking for 
when we're talking about affordability and what they value. However when making the queries, I 
think it's most important to put that HAVING line to ensure that we are at least getting 
a more full picture of the city's listing.

 */

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

-- Week 2 Deliverables:

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


-- Week 2 Open-Ended Challenge:
-- "We're putting together a buyer's guide and need to know where the 
 -- most affordable options are. Can you pull something together?"

-- Lowest prices by city
SELECT L_City, COUNT(L_DisplayID) AS number_of_listings, ROUND(AVG(L_SystemPrice),2) AS  avg_price 
FROM rets_property
GROUP BY L_City
ORDER BY avg_price;


-- Best value per bedroom
SELECT L_Keyword2 AS number_of_beds, COUNT(L_DisplayID) AS number_of_listings, ROUND(AVG(L_SystemPrice),2) AS  avg_price 
FROM rets_property
GROUP BY number_of_beds
ORDER BY avg_price;


-- Lowest prices by city where # of listings > 50
SELECT L_City, COUNT(L_DisplayID) AS number_of_listings, ROUND(AVG(L_SystemPrice),2) AS  avg_price 
FROM rets_property
GROUP BY L_City
HAVING number_of_listings > 50
ORDER BY avg_price;

-- Price per square foot
SELECT L_City, COUNT(L_DisplayID) AS number_of_listings, ROUND(AVG(L_SystemPrice / NULLIF(LM_Int2_3, 0)), 2) AS price_per_sq_ft
FROM rets_property
GROUP BY L_City
HAVING number_of_listings > 50
ORDER BY price_per_sq_ft;










