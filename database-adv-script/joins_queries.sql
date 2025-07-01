-- 1. INNER JOIN: Retrieve all bookings and the respective users who made those bookings
-- This will only return bookings that have matching users
SELECT 
    b.booking_id,
    b.booking_date,
    b.check_in_date,
    b.check_out_date,
    b.total_amount,
    u.user_id,
    u.first_name,
    u.last_name,
    u.email
FROM bookings b
INNER JOIN users u ON b.user_id = u.user_id
ORDER BY b.booking_date DESC;


