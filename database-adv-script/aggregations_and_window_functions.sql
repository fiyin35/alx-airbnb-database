--  A query to find the total number of bookings made by each user, using the COUNT function and GROUP BY clause.

SELECT 
    u.user_id,
    COUNT(b.booking_id) AS total_bookings
FROM users u
LEFT JOIN bookings b ON u.user_id = b.user_id
GROUP BY u.user_id
ORDER BY total_bookings DESC;

-- A window function (ROW_NUMBER, RANK) to rank properties based on the total number of bookings they have received.
SELECT 
    property_id,
    total_bookings,
    ROW_NUMBER() OVER (ORDER BY total_bookings DESC) AS row_rank,
    RANK() OVER (ORDER BY total_bookings DESC) AS standard_rank,
    DENSE_RANK() OVER (ORDER BY total_bookings DESC) AS dense_rank
FROM (
    SELECT 
        property_id,
        COUNT(*) AS total_bookings
    FROM bookings
    GROUP BY property_id
) booking_counts
ORDER BY total_bookings DESC;