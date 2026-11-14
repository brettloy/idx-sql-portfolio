-- ============================================================
-- IDX Exchange — Data Analyst Internship
-- Week 4: Multi-Table Analysis with JOINs
-- Tables: rets_property.sql, rets_openhouse.sql
-- Author: Brett Loy
-- ============================================================
/*
The top five cities for total open houses on weekends are Los Angeles, Irvine, 
San Diego, and San Jose. These are the busiest cities for open houses on the weekends.
However, these numbers might be skewed due to the fact that these are already larger 
cities in general, with a bigger amount of listings on the market. 

Calculating the percentage of open houses on the weekend by city confirmed that Irvine, 
Los Angeles, and San Diego Have a high open house percentage on the weekend. 

*/


-- Preview tables
SELECT * FROM rets_openhouse LIMIT 20;

SELECT * FROM rets_property LIMIT 20;
-- INNER JOIN vs LEFT JOIN

-- INNER JOIN: only listings that HAVE at least one open house
SELECT p.L_DisplayId, p.L_Address, o.OpenHouseDate
FROM rets_property p
INNER JOIN rets_openhouse o ON p.L_DisplayId = o.L_DisplayId
LIMIT 10;
 
-- LEFT JOIN: ALL listings, NULL for open house fields if none exist
SELECT p.L_DisplayId, p.L_Address, o.OpenHouseDate
FROM rets_property p
LEFT JOIN rets_openhouse o ON p.L_DisplayId = o.L_DisplayId
LIMIT 10;


-- Exercise 4.1 Listings with open houses
SELECT p.L_DisplayId, p.L_Address, p.L_City, p.L_SystemPrice,
       o.OpenHouseDate, o.OH_StartTime, o.OH_EndTime
FROM rets_property p
INNER JOIN rets_openhouse o ON p.L_DisplayId = o.L_DisplayId
ORDER BY o.OpenHouseDate
LIMIT 20;


-- Exercise 4.2: Count open houses per listing
SELECT p.L_DisplayId, p.L_Address, p.L_City, p.L_SystemPrice,
       COUNT(o.OpenHouseDate) AS num_open_houses
FROM rets_property p
INNER JOIN rets_openhouse o ON p.L_DisplayId = o.L_DisplayId
GROUP BY p.L_DisplayId, p.L_Address, p.L_City, p.L_SystemPrice
ORDER BY num_open_houses DESC
LIMIT 20;

-- Exercise 4.3: What percentage have open houses?
SELECT
  COUNT(DISTINCT p.L_DisplayId) AS total_listings,
  COUNT(DISTINCT o.L_DisplayId) AS listings_with_openhouse,
  ROUND(100.0 * COUNT(DISTINCT o.L_DisplayId)
        / COUNT(DISTINCT p.L_DisplayId), 1) AS pct_with_openhouse
FROM rets_property p
LEFT JOIN rets_openhouse o ON p.L_DisplayId = o.L_DisplayId;


-- Exercise 4.4: Open house activity by city
SELECT p.L_City,
       COUNT(DISTINCT p.L_DisplayId) AS total_listings,
       COUNT(o.OpenHouseDate) AS total_open_houses,
       ROUND(100.0 * COUNT(DISTINCT o.L_DisplayId)
             / COUNT(DISTINCT p.L_DisplayId), 1) AS pct_with_openhouse
FROM rets_property p
LEFT JOIN rets_openhouse o ON p.L_DisplayId = o.L_DisplayId
GROUP BY p.L_City
HAVING COUNT(DISTINCT p.L_DisplayId) >= 10
ORDER BY total_open_houses DESC
LIMIT 20;


-- Exercise 4.5: Most Popular Open House Days
SELECT DAYNAME(OpenHouseDate) AS day_of_week,
       COUNT(*)               AS num_open_houses
FROM rets_openhouse
WHERE OpenHouseDate IS NOT NULL
GROUP BY DAYNAME(OpenHouseDate), DAYOFWEEK(OpenHouseDate)
ORDER BY DAYOFWEEK(OpenHouseDate);


-- Debugging exercise
-- BROKEN: Average list price by city for listings with open houses
-- Results are higher than expected — why?
SELECT p.L_City,
       COUNT(*) AS listing_count,
       ROUND(AVG(DISTINCT p.L_SystemPrice), 0) AS avg_price
FROM rets_property p
INNER JOIN rets_openhouse o ON p.L_DisplayId = o.L_DisplayId
GROUP BY p.L_City
ORDER BY avg_price DESC
LIMIT 15;


-- Week 4 deliverables

-- Q1: Top 10 cities by most open houses scheduled
SELECT p.L_City,
       COUNT(o.OpenHouseDate) AS total_open_houses
FROM rets_property p
LEFT JOIN rets_openhouse o ON p.L_DisplayId = o.L_DisplayId
GROUP BY p.L_City
ORDER BY total_open_houses DESC
LIMIT 10;


-- Q2: Most popular day of the week for open houses
SELECT DAYNAME(OpenHouseDate) AS day_of_week,
       COUNT(*)               AS num_open_houses
FROM rets_openhouse
WHERE OpenHouseDate IS NOT NULL
GROUP BY DAYNAME(OpenHouseDate), DAYOFWEEK(OpenHouseDate)
ORDER BY DAYOFWEEK(OpenHouseDate);


-- Q3: Top 10 listings with the most open houses
SELECT p.L_DisplayId, p.L_City, p.L_SystemPrice,
       COUNT(o.OpenHouseDate) AS num_open_houses
FROM rets_property p
INNER JOIN rets_openhouse o ON p.L_DisplayId = o.L_DisplayId
GROUP BY p.L_DisplayId, p.L_City, p.L_SystemPrice
ORDER BY num_open_houses DESC
LIMIT 10;


-- Q4: How many listings have zero open houses? (LEFT JOIN + IS NULL)
SELECT COUNT(*) AS listings_without_open_house
FROM rets_property p
LEFT JOIN rets_openhouse o ON p.L_DisplayId = o.L_DisplayId
WHERE o.L_DisplayId IS NULL;


-- Q5: Do higher-priced listings have more open houses on average?
SELECT num_open_houses,
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
WHERE num_open_houses IN (0, 1)
GROUP BY num_open_houses
ORDER BY num_open_houses;


-- Week 4 open-ended challenge
-- "We're thinking about hosting our own open house events on weekends but only in cities 
-- where open house activity is already high. Which cities and days should we target?"

-- Total open houses
SELECT p.L_City AS city,
       DAYNAME(o.OpenHouseDate) AS day_of_week,
       COUNT(*) AS num_open_houses,
       COUNT(DISTINCT p.L_DisplayId) AS num_listings,
       ROUND(AVG(p.L_SystemPrice)) AS avg_price
FROM rets_openhouse o
INNER JOIN rets_property p ON p.L_DisplayId = o.L_DisplayId
WHERE o.OpenHouseDate IS NOT NULL
  AND p.L_City IS NOT NULL
  AND DAYOFWEEK(o.OpenHouseDate) IN (1, 7)   -- MySQL: 1 = Sunday, 7 = Saturday
GROUP BY p.L_City, DAYNAME(o.OpenHouseDate), DAYOFWEEK(o.OpenHouseDate)
ORDER BY num_open_houses DESC
LIMIT 5;


-- Open houses per city, what fraction of open houses are on the weekend
SELECT p.L_City AS city,
       COUNT(*) AS total_open_houses,
       ROUND(100 * AVG(DAYOFWEEK(o.OpenHouseDate) IN (1,7)), 1) AS pct_weekend
FROM rets_openhouse o
JOIN rets_property p ON p.L_DisplayId = o.L_DisplayId
WHERE o.OpenHouseDate IS NOT NULL
  AND p.L_City IS NOT NULL
GROUP BY p.L_City
HAVING COUNT(*) >= 25
ORDER BY pct_weekend DESC
LIMIT 5;

