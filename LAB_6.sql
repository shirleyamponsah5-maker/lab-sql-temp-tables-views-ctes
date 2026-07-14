USE sakila;

-- STEP 1: Create a virtual view for customer rental counts
CREATE VIEW customer_rental_summary AS
SELECT
c.customer_id,
c.first_name,
c.last_name,
c.email,
COUNT(r.rental_id) AS rental_count
FROM customer AS c
INNER JOIN rental AS r
ON c.customer_id = r.customer_id
GROUP BY
c.customer_id,
c.first_name,
c.last_name,
c.email;

-- STEP 2: Creating a temporary table for total customer spend using the view
CREATE TEMPORARY TABLE customer_payment_summary AS
SELECT
crs.customer_id,
SUM(p.amount) AS total_paid
FROM customer_rental_summary AS crs
INNER JOIN payment AS p
ON crs.customer_id = p.customer_id
GROUP BY
crs.customer_id;

-- STEP 3: Combining view and temp table in a CTE to produce the final report
WITH customer_summary_cte AS (
SELECT
crs.first_name,
crs.last_name,
crs.email,
crs.rental_count,
cps.total_paid
FROM customer_rental_summary AS crs
INNER JOIN customer_payment_summary AS cps
ON crs.customer_id = cps.customer_id
)
SELECT
first_name,
last_name,
email,
rental_count,
total_paid,
(total_paid / rental_count) AS average_payment_per_rental
FROM customer_summary_cte
ORDER BY total_paid DESC;