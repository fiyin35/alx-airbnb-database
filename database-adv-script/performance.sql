-- ============================================
-- File: performance.sql
-- Purpose: Retrieve booking details with joins
-- ============================================

-- Initial version: full join of 4 tables
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
-- Refactored version (performance optimized)
-- ============================================

-- Optimization:
-- - Select fewer columns
-- - Ensure indexes on foreign keys:
--   Booking(user_id), Booking(property_id), Payment(booking_id)

-- Refactored query
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
    pay.status AS payment_status
FROM Booking b
JOIN User u ON b.user_id = u.user_id
JOIN Property p ON b.property_id = p.property_id
LEFT JOIN Payment pay ON pay.booking_id = b.booking_id;