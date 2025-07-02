-- ============================================
-- File: performance_optimized.sql
-- Purpose: Optimized booking details retrieval with comprehensive analysis
-- ============================================

-- ============================================
-- SECTION 1: ORIGINAL QUERY ANALYSIS
-- ============================================

-- Original query with EXPLAIN analysis
EXPLAIN FORMAT=JSON
SELECT
    b.booking_id,
    b.start_date,
    b.end_date,
    b.status,
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    p.property_id,
    p.name AS property_name,
    p.pricepernight,
    pay.payment_id,
    pay.amount,
    pay.payment_date,
    pay.status AS payment_status
FROM Booking b
JOIN User u ON b.user_id = u.user_id
JOIN Property p ON b.property_id = p.property_id
LEFT JOIN Payment pay ON pay.booking_id = b.booking_id;

-- ============================================
-- SECTION 2: OPTIMIZED QUERIES WITH WHERE AND AND CONDITIONS
-- ============================================

-- Query 1: Get bookings for a specific date range and status
EXPLAIN FORMAT=JSON
SELECT
    b.booking_id,
    b.start_date,
    b.end_date,
    b.status,
    CONCAT(u.first_name, ' ', u.last_name) AS guest_name,
    u.email,
    p.name AS property_name,
    p.pricepernight,
    pay.amount,
    pay.payment_status
FROM Booking b
JOIN User u ON b.user_id = u.user_id 
    AND u.role = 'guest'  -- Additional condition on User table
JOIN Property p ON b.property_id = p.property_id 
    AND p.is_active = TRUE  -- Additional condition on Property table
LEFT JOIN Payment pay ON pay.booking_id = b.booking_id 
    AND pay.booking_start_date = b.start_date  -- For partitioned table compatibility
    AND pay.payment_status IN ('completed', 'pending')  -- Filter payments
WHERE b.start_date >= '2024-01-01' 
    AND b.start_date <= '2024-12-31'
    AND b.status IN ('confirmed', 'completed')
    AND b.guest_count <= 4;

-- Query 2: Get recent bookings for a specific property with payment details
EXPLAIN FORMAT=JSON
SELECT
    b.booking_id,
    b.start_date,
    b.end_date,
    b.status,
    b.guest_count,
    CONCAT(u.first_name, ' ', u.last_name) AS guest_name,
    u.email,
    u.phone_number,
    p.name AS property_name,
    p.pricepernight,
    (p.pricepernight * DATEDIFF(b.end_date, b.start_date)) AS calculated_total,
    pay.amount AS paid_amount,
    pay.payment_method,
    pay.payment_status,
    pay.payment_date
FROM Booking b
JOIN User u ON b.user_id = u.user_id 
    AND u.role = 'guest'
    AND u.email IS NOT NULL  -- Ensure valid email
JOIN Property p ON b.property_id = p.property_id 
    AND p.is_active = TRUE
    AND p.pricepernight > 0  -- Valid pricing
LEFT JOIN Payment pay ON pay.booking_id = b.booking_id 
    AND pay.booking_start_date = b.start_date
    AND pay.payment_status != 'failed'  -- Exclude failed payments
WHERE b.property_id = 'specific-property-uuid'  -- Replace with actual property ID
    AND b.start_date >= CURDATE() - INTERVAL 6 MONTH  -- Last 6 months
    AND b.status != 'canceled'
    AND b.guest_count BETWEEN 1 AND 8
ORDER BY b.start_date DESC
LIMIT 50;

-- Query 3: Get bookings by host with aggregated payment information
EXPLAIN FORMAT=JSON
SELECT
    b.booking_id,
    b.start_date,
    b.end_date,
    b.status,
    b.guest_count,
    DATEDIFF(b.end_date, b.start_date) AS duration_days,
    CONCAT(guest.first_name, ' ', guest.last_name) AS guest_name,
    guest.email AS guest_email,
    p.name AS property_name,
    p.pricepernight,
    CONCAT(host.first_name, ' ', host.last_name) AS host_name,
    pay.amount AS payment_amount,
    pay.payment_status,
    pay.payment_method,
    CASE 
        WHEN pay.payment_status = 'completed' THEN 'Paid'
        WHEN pay.payment_status = 'pending' THEN 'Payment Pending'
        WHEN pay.payment_status IS NULL THEN 'No Payment Record'
        ELSE 'Payment Issue'
    END AS payment_summary
FROM Booking b
JOIN User guest ON b.user_id = guest.user_id 
    AND guest.role = 'guest'
    AND guest.email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'  -- Valid email format
JOIN Property p ON b.property_id = p.property_id 
    AND p.is_active = TRUE
    AND p.max_guests >= b.guest_count  -- Property can accommodate guests
JOIN User host ON p.host_id = host.user_id 
    AND host.role = 'host'
LEFT JOIN Payment pay ON pay.booking_id = b.booking_id 
    AND pay.booking_start_date = b.start_date
    AND pay.amount > 0  -- Valid payment amount
WHERE host.user_id = 'specific-host-uuid'  -- Replace with actual host ID
    AND b.start_date >= '2024-01-01'
    AND b.start_date <= '2024-12-31'
    AND b.status IN ('confirmed', 'completed', 'pending')
    AND (pay.payment_status IS NULL OR pay.payment_status != 'refunded')
ORDER BY b.start_date DESC, b.created_at DESC;

-- Query 4: Complex booking analysis with multiple conditions
EXPLAIN FORMAT=JSON
SELECT
    b.booking_id,
    b.start_date,
    b.end_date,
    b.status,
    b.guest_count,
    b.special_requests,
    CONCAT(u.first_name, ' ', u.last_name) AS guest_name,
    u.email,
    p.name AS property_name,
    p.city,
    p.country,
    p.pricepernight,
    p.bedrooms,
    p.bathrooms,
    pay.amount,
    pay.payment_method,
    pay.payment_status,
    pay.transaction_id,
    DATEDIFF(b.end_date, b.start_date) AS stay_duration,
    (p.pricepernight * DATEDIFF(b.end_date, b.start_date)) AS expected_total
FROM Booking b
JOIN User u ON b.user_id = u.user_id 
    AND u.role = 'guest'
    AND u.created_at <= b.created_at  -- User existed before booking
JOIN Property p ON b.property_id = p.property_id 
    AND p.is_active = TRUE
    AND p.created_at <= b.created_at  -- Property existed before booking
    AND p.max_guests >= b.guest_count  -- Capacity check
JOIN Location l ON p.location_id = l.location_id
    AND l.country IN ('United States', 'Canada', 'United Kingdom')  -- Specific countries
LEFT JOIN Payment pay ON pay.booking_id = b.booking_id 
    AND pay.booking_start_date = b.start_date
    AND pay.payment_date >= b.created_at  -- Payment after booking creation
    AND pay.amount BETWEEN (p.pricepernight * DATEDIFF(b.end_date, b.start_date) * 0.8) 
                       AND (p.pricepernight * DATEDIFF(b.end_date, b.start_date) * 1.2)  -- Payment within reasonable range
WHERE b.start_date >= '2024-06-01'
    AND b.start_date <= '2024-08-31'  -- Summer season
    AND b.status = 'confirmed'
    AND b.guest_count BETWEEN 2 AND 6  -- Family-sized bookings
    AND p.pricepernight BETWEEN 100 AND 500  -- Mid-range properties
    AND p.bedrooms >= 2
    AND DATEDIFF(b.end_date, b.start_date) BETWEEN 3 AND 14  -- 3-14 day stays
ORDER BY p.pricepernight DESC, b.start_date ASC;

-- ============================================
-- SECTION 3: PERFORMANCE ANALYSIS QUERIES
-- ============================================

-- Analyze query execution without EXPLAIN to see actual performance
SET profiling = 1;

-- Run a sample optimized query
SELECT
    b.booking_id,
    b.start_date,
    b.end_date,
    b.status,
    CONCAT(u.first_name, ' ', u.last_name) AS guest_name,
    p.name AS property_name,
    pay.payment_status
FROM Booking b
JOIN User u ON b.user_id = u.user_id 
    AND u.role = 'guest'
JOIN Property p ON b.property_id = p.property_id 
    AND p.is_active = TRUE
LEFT JOIN Payment pay ON pay.booking_id = b.booking_id 
    AND pay.booking_start_date = b.start_date
WHERE b.start_date >= CURDATE() - INTERVAL 3 MONTH
    AND b.status IN ('confirmed', 'completed')
LIMIT 100;

-- Show query profile
SHOW PROFILES;

-- Get detailed profile for last query
SHOW PROFILE FOR QUERY 1;

-- ============================================
-- SECTION 4: INDEX OPTIMIZATION RECOMMENDATIONS
-- ============================================

-- Recommended indexes for optimal performance
-- (These should already exist from the partitioning implementation)

-- Composite indexes for common WHERE clause combinations
CREATE INDEX IF NOT EXISTS idx_booking_date_status ON Booking(start_date, status);
CREATE INDEX IF NOT EXISTS idx_booking_property_date ON Booking(property_id, start_date);
CREATE INDEX IF NOT EXISTS idx_booking_user_date ON Booking(user_id, start_date);
CREATE INDEX IF NOT EXISTS idx_booking_status_date ON Booking(status, start_date);

-- User table indexes
CREATE INDEX IF NOT EXISTS idx_user_role_email ON User(role, email);
CREATE INDEX IF NOT EXISTS idx_user_created_at ON User(created_at);

-- Property table indexes
CREATE INDEX IF NOT EXISTS idx_property_active_price ON Property(is_active, pricepernight);
CREATE INDEX IF NOT EXISTS idx_property_host_active ON Property(host_id, is_active);
CREATE INDEX IF NOT EXISTS idx_property_location_active ON Property(location_id, is_active);

-- Payment table indexes
CREATE INDEX IF NOT EXISTS idx_payment_status_method ON Payment(payment_status, payment_method);
CREATE INDEX IF NOT EXISTS idx_payment_date_status ON Payment(payment_date, payment_status);

-- Location table indexes
CREATE INDEX IF NOT EXISTS idx_location_country_city ON Location(country, city);

-- ============================================
-- SECTION 5: QUERY PERFORMANCE COMPARISON
-- ============================================

-- Compare execution plans for different query approaches

-- Approach 1: Using subqueries (generally slower)
EXPLAIN FORMAT=JSON
SELECT 
    b.booking_id,
    b.start_date,
    (SELECT CONCAT(first_name, ' ', last_name) FROM User WHERE user_id = b.user_id) AS guest_name,
    (SELECT name FROM Property WHERE property_id = b.property_id) AS property_name,
    (SELECT payment_status FROM Payment WHERE booking_id = b.booking_id LIMIT 1) AS payment_status
FROM Booking b
WHERE b.start_date >= '2024-01-01'
    AND b.status = 'confirmed';

-- Approach 2: Using JOINs (optimized approach)
EXPLAIN FORMAT=JSON
SELECT 
    b.booking_id,
    b.start_date,
    CONCAT(u.first_name, ' ', u.last_name) AS guest_name,
    p.name AS property_name,
    pay.payment_status
FROM Booking b
JOIN User u ON b.user_id = u.user_id
JOIN Property p ON b.property_id = p.property_id
LEFT JOIN Payment pay ON pay.booking_id = b.booking_id AND pay.booking_start_date = b.start_date
WHERE b.start_date >= '2024-01-01'
    AND b.status = 'confirmed';

-- ============================================
-- SECTION 6: QUERY MONITORING AND ANALYSIS
-- ============================================

-- Query to analyze slow queries (if slow query log is enabled)
-- SELECT 
--     sql_text,
--     exec_count,
--     avg_timer_wait/1000000000 as avg_time_seconds,
--     max_timer_wait/1000000000 as max_time_seconds
-- FROM performance_schema.events_statements_summary_by_digest
-- WHERE schema_name = DATABASE()
--     AND sql_text LIKE '%Booking%'
-- ORDER BY avg_timer_wait DESC
-- LIMIT 10;

-- Analyze table access patterns
SELECT 
    TABLE_NAME,
    INDEX_NAME,
    SEQ_IN_INDEX,
    COLUMN_NAME,
    CARDINALITY
FROM INFORMATION_SCHEMA.STATISTICS 
WHERE TABLE_SCHEMA = DATABASE() 
    AND TABLE_NAME IN ('Booking', 'User', 'Property', 'Payment')
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;

-- Check partition pruning effectiveness (for partitioned Booking table)
EXPLAIN PARTITIONS
SELECT COUNT(*) 
FROM Booking 
WHERE start_date BETWEEN '2024-07-01' AND '2024-09-30'
    AND status = 'confirmed';

-- ============================================
-- SECTION 7: PERFORMANCE TESTING QUERIES
-- ============================================

-- Test query performance with different LIMIT values
EXPLAIN FORMAT=JSON
SELECT
    b.booking_id,
    CONCAT(u.first_name, ' ', u.last_name) AS guest_name,
    p.name AS property_name
FROM Booking b
JOIN User u ON b.user_id = u.user_id AND u.role = 'guest'
JOIN Property p ON b.property_id = p.property_id AND p.is_active = TRUE
WHERE b.start_date >= CURDATE() - INTERVAL 1 YEAR
    AND b.status IN ('confirmed', 'completed')
ORDER BY b.start_date DESC
LIMIT 10;  -- Test with different values: 10, 100, 1000

-- Test query with complex WHERE conditions
EXPLAIN FORMAT=JSON
SELECT
    b.booking_id,
    b.start_date,
    b.guest_count,
    CONCAT(u.first_name, ' ', u.last_name) AS guest_name,
    p.name AS property_name,
    p.pricepernight,
    pay.payment_status
FROM Booking b
JOIN User u ON b.user_id = u.user_id 
    AND u.role = 'guest'
    AND u.email IS NOT NULL
JOIN Property p ON b.property_id = p.property_id 
    AND p.is_active = TRUE
    AND p.pricepernight BETWEEN 50 AND 300
LEFT JOIN Payment pay ON pay.booking_id = b.booking_id 
    AND pay.booking_start_date = b.start_date
    AND pay.payment_status IN ('completed', 'pending')
WHERE b.start_date BETWEEN CURDATE() AND CURDATE() + INTERVAL 6 MONTH
    AND b.status = 'confirmed'
    AND b.guest_count <= p.max_guests
    AND DATEDIFF(b.end_date, b.start_date) BETWEEN 2 AND 30
    AND (pay.payment_status IS NULL OR pay.payment_status != 'failed')
ORDER BY b.start_date ASC, p.pricepernight DESC;

-- ============================================
-- SECTION 8: EXECUTION PLAN ANALYSIS GUIDE
-- ============================================

/*
EXPLAIN OUTPUT ANALYSIS GUIDE:

Key metrics to look for in EXPLAIN results:

1. **type** column values (best to worst):
   - system: Only one row
   - const: At most one matching row
   - eq_ref: One row read for each row from previous table
   - ref: Multiple rows with matching index value
   - range: Index range scan
   - index: Full index scan
   - ALL: Full table scan (avoid this!)

2. **key** column:
   - Shows which index is being used
   - NULL means no index is used (bad!)

3. **rows** column:
   - Estimated number of rows examined
   - Lower is better

4. **Extra** column important values:
   - "Using index": Query uses covering index (good!)
   - "Using where": WHERE clause filters rows
   - "Using temporary": Creates temporary table (can be expensive)
   - "Using filesort": Sorting required (expensive for large datasets)
   - "Using index condition": Index condition pushdown used

5. **partitions** column (for partitioned tables):
   - Shows which partitions are accessed
   - Fewer partitions = better performance

OPTIMIZATION PRIORITIES:
1. Ensure indexes are used (avoid type=ALL)
2. Minimize rows examined
3. Use covering indexes when possible
4. Avoid temporary tables and filesorts for large datasets
5. Ensure partition pruning works for partitioned tables
*/