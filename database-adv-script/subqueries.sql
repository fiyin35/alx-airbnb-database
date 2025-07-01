-- NON-CORRELATED SUBQUERY
-- Find all properties where the average rating is greater than 4.0

SELECT 
    p.property_id,
    p.property_name,
    p.location,
    p.price_per_night,
    p.property_type
FROM properties p
WHERE p.property_id IN (
    SELECT r.property_id
    FROM reviews r
    GROUP BY r.property_id
    HAVING AVG(r.rating) > 4.0
)
ORDER BY p.property_name;

-- CORRELATED SUBQUERY
-- Find all properties where the average rating is greater than 4.0
-- The subquery references the outer query's property table (p.property_id)

SELECT 
    p.property_id,
    p.property_name,
    p.location,
    p.price_per_night,
    p.property_type
FROM properties p
WHERE (
    SELECT AVG(r.rating)
    FROM reviews r
    WHERE r.property_id = p.property_id
) > 4.0
ORDER BY p.property_name;
