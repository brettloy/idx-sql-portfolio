-- ============================================================
-- IDX Exchange — Data Analyst Internship
-- Week 3: Aggregation and Grouping
-- Tables: rets_property.sql
-- Author: Brett Loy
-- ============================================================
/*
Cities recommended for first-time buyers

I queried a specific three-city recommendation that pinpoints inventory size, 
price per square foot, and bedroom mix. Number of listings is at least 50 in 
the city, while minimizing price per square foot and keeping bedrooms from 1 to 6.
I felt that these features would be attractive to first-time buyers and that is why 
I chose them. For example if we were looking for best budget cities, then Victorville, 
Oroville, and 29 Palms would be the best budget cities for the client based on price 
per square foot. If the client was looking for a home greater than $1 million, then 
the best cities would be La Quinta, Palm Springs, and Irvine for a more moderate buy.
 
 */

-- Concept: Aggregate Functions
SELECT COUNT(*) AS total_listings,
AVG(L_SystemPrice) AS avg_price,
MIN(L_SystemPrice) AS cheapest,
MAX(L_SystemPrice) AS most_expensive
FROM rets_property;

-- Exercise 3.1 GROUP BY L_City
SELECT L_City,
COUNT(*) AS total_listings,
ROUND(AVG(L_SystemPrice), 0) AS avg_list_price,
MIN(L_SystemPrice) AS min_price,
MAX(L_SystemPrice) AS max_price
FROM rets_property
WHERE L_SystemPrice IS NOT NULL
GROUP BY L_City
ORDER BY avg_list_price DESC;

-- Exercise 3.2 Price Per Square Foot
SELECT L_City,
COUNT(*) AS listings,
ROUND(AVG(L_SystemPrice), 0) AS avg_price,
ROUND(AVG(LM_Int2_3), 0) AS avg_sqft,
ROUND(AVG(L_SystemPrice / LM_Int2_3), 2) AS avg_price_per_sqft
FROM rets_property
WHERE LM_Int2_3 > 0 AND L_SystemPrice IS NOT NULL
GROUP BY L_City
ORDER BY avg_price_per_sqft DESC
LIMIT 20;

-- Exercise 3.3 HAVING
SELECT L_City,
COUNT(*) AS total_listings,
ROUND(AVG(L_SystemPrice), 0) AS avg_price
FROM rets_property
WHERE L_SystemPrice IS NOT NULL
GROUP BY L_City
HAVING COUNT(*) >= 10
ORDER BY avg_price DESC;

/* WHERE VS HAVING
• WHERE runs before grouping — filters individual rows
• HAVING runs after grouping — filters entire groups
• Rule: if your condition uses COUNT, AVG, SUM — use HAVING
 */

-- Exercise 3.4 Inventory by Bedroom Count
SELECT L_Keyword2 AS bedrooms,
COUNT(*) AS total_listings,
ROUND(AVG(L_SystemPrice), 0) AS avg_price
FROM rets_property
WHERE L_Keyword2 IS NOT NULL AND L_Keyword2 BETWEEN 1 AND 8
GROUP BY L_Keyword2
ORDER BY L_Keyword2;


-- Debugging Exercise:
-- BROKEN: Cities with average price above $600k (min 5 listings)
SELECT L_City,
COUNT(*) AS total_listings,
ROUND(AVG(L_SystemPrice), 0) AS avg_price
FROM rets_property
WHERE  L_SystemPrice IS NOT NULL
GROUP BY L_City
HAVING AVG(L_SystemPrice) > 600000 -- Fixed: moved AVG filter from WHERE to HAVING
AND COUNT(*) >= 5
ORDER BY avg_price DESC;

-- Q1: Top 10 cities by highest average list price (min 10 listings each)
SELECT L_City,
COUNT(*) AS total_listings,
ROUND(AVG(L_SystemPrice), 0) AS avg_price
FROM rets_property
GROUP BY L_City
HAVING COUNT(*) >= 10
ORDER BY avg_price DESC;

-- Q2: Top 10 cities by most active inventory
SELECT L_City,
COUNT(*) AS total_listings
FROM rets_property
GROUP BY L_City
ORDER BY total_listings desc
LIMIT 10;

-- Q3: Average price per sqft by city — top 15 cities
SELECT L_City,
COUNT(*) AS total_listings,
ROUND(AVG(L_SystemPrice), 0) AS avg_price,
ROUND(AVG(LM_Int2_3), 0) AS avg_sqft,
ROUND(AVG(L_SystemPrice / NULLIF(LM_Int2_3, 0)), 2) AS avg_price_per_sqft
FROM rets_property
GROUP BY L_City
ORDER BY avg_price_per_sqft desc
LIMIT 15;

-- Q4: Listing count at each bedroom count 1 through 6
SELECT L_Keyword2,
COUNT(*) as total_listings
FROM rets_property
GROUP BY L_Keyword2
HAVING L_Keyword2 BETWEEN 1 AND 6
ORDER BY L_Keyword2;

-- Q5: ZIP codes with average price above $800,000
SELECT L_Zip,
ROUND(AVG(L_SystemPrice), 0) AS avg_price
FROM rets_property
GROUP BY L_Zip
HAVING avg_price > 800000;


-- Week 3 open-ended challenge
-- We're launching a new ad campaign and want to focus on the three cities that represent the 
-- best opportunity for first-time buyers. Which cities would you recommend and why?"

SELECT L_City,
COUNT(*) AS total_listings,
ROUND(AVG(L_SystemPrice / NULLIF(LM_Int2_3, 0)), 2) AS avg_price_per_sqft
FROM rets_property
WHERE L_Keyword2 BETWEEN 1 AND 6
AND L_SystemPrice > 1000000 -- Comment out for budget 
GROUP BY L_City
HAVING total_listings > 75 
ORDER BY avg_price_per_sqft
LIMIT 3;





