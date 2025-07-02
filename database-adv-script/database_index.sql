-- ============================================
-- File: database_index.sql
-- Purpose: Add indexes to improve query performance
-- ============================================

-- ------------------------------------------------
-- Booking table indexes
-- ------------------------------------------------
-- 1. Quickly find bookings made by a specific user
CREATE INDEX idx_booking_user ON Booking (user_id);

-- 2. Speed up look‑ups for availability/conflict checks that
--    filter by property, status, and date range
CREATE INDEX idx_booking_property_status_dates
    ON Booking (property_id, status, start_date, end_date);

-- 3. Simple status filter (small but common column)
CREATE INDEX idx_booking_status ON Booking (status);

-- ------------------------------------------------
-- User table indexes
-- ------------------------------------------------
-- 4. Filter users by role (e.g., list all hosts/admins)
CREATE INDEX idx_user_role ON User (role);

-- 5. Support case‑insensitive alphabetical look‑ups / search
CREATE INDEX idx_user_name ON User (last_name, first_name);

-- ------------------------------------------------
-- Property table indexes
-- ------------------------------------------------
-- 6. List properties that belong to a given host
CREATE INDEX idx_property_host ON Property (host_id);

-- 7. Filter properties by location (most frequent filter)
CREATE INDEX idx_property_location ON Property (location_id);

-- 8. Location + active flag + price to support
--    search pages that show active listings in a city
--    sorted/filtered by price
CREATE INDEX idx_property_location_active_price
    ON Property (location_id, is_active, pricepernight);

-- 9. Narrow down properties by type (optional look‑up)
CREATE INDEX idx_property_type ON Property (type_id);

-- Optional: standalone price index if you often run
--           global price range scans without location
-- CREATE INDEX idx_property_price ON Property (pricepernight);