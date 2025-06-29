-- Property Booking Database Sample Data
-- Execute these INSERT statements in order due to foreign key dependencies

-- ============================================================================
-- 1. USERS TABLE
-- ============================================================================
INSERT INTO users (user_id, first_name, last_name, email, phone, date_of_birth, created_at, updated_at, is_active) VALUES
(1, 'John', 'Doe', 'john.doe@email.com', '+1-555-0101', '1985-03-15', '2024-01-15 10:30:00', '2024-01-15 10:30:00', TRUE),
(2, 'Sarah', 'Johnson', 'sarah.johnson@email.com', '+1-555-0102', '1990-07-22', '2024-01-20 14:45:00', '2024-01-20 14:45:00', TRUE),
(3, 'Michael', 'Chen', 'michael.chen@email.com', '+1-555-0103', '1988-11-08', '2024-02-01 09:15:00', '2024-02-01 09:15:00', TRUE),
(4, 'Emily', 'Rodriguez', 'emily.rodriguez@email.com', '+1-555-0104', '1992-05-30', '2024-02-10 16:20:00', '2024-02-10 16:20:00', TRUE),
(5, 'David', 'Wilson', 'david.wilson@email.com', '+1-555-0105', '1983-09-12', '2024-02-15 11:00:00', '2024-02-15 11:00:00', TRUE),
(6, 'Lisa', 'Anderson', 'lisa.anderson@email.com', '+1-555-0106', '1987-12-03', '2024-03-01 13:30:00', '2024-03-01 13:30:00', TRUE),
(7, 'Robert', 'Taylor', 'robert.taylor@email.com', '+1-555-0107', '1991-04-18', '2024-03-05 15:45:00', '2024-03-05 15:45:00', TRUE),
(8, 'Jessica', 'Brown', 'jessica.brown@email.com', '+1-555-0108', '1989-08-25', '2024-03-10 08:20:00', '2024-03-10 08:20:00', TRUE);

-- ============================================================================
-- 2. PROPERTY OWNERS (subset of users who own properties)
-- ============================================================================
INSERT INTO property_owners (owner_id, user_id, business_name, tax_id, created_at) VALUES
(1, 3, 'Chen Property Management', 'TAX123456789', '2024-02-01 09:15:00'),
(2, 5, 'Wilson Vacation Rentals', 'TAX987654321', '2024-02-15 11:00:00'),
(3, 6, 'Anderson Properties LLC', 'TAX456789123', '2024-03-01 13:30:00');

-- ============================================================================
-- 3. PROPERTIES TABLE
-- ============================================================================
INSERT INTO properties (property_id, owner_id, title, description, property_type, address, city, state, country, postal_code, latitude, longitude, bedrooms, bathrooms, max_guests, price_per_night, cleaning_fee, is_active, created_at, updated_at) VALUES
(1, 1, 'Downtown Luxury Apartment', 'Modern 2-bedroom apartment in the heart of downtown with city views and premium amenities.', 'APARTMENT', '123 Main Street, Apt 15B', 'New York', 'NY', 'USA', '10001', 40.7589, -73.9851, 2, 2, 4, 250.00, 50.00, TRUE, '2024-02-01 10:00:00', '2024-02-01 10:00:00'),
(2, 1, 'Cozy Studio Near Central Park', 'Charming studio with park views, perfect for couples or solo travelers.', 'STUDIO', '456 Park Avenue, Unit 8A', 'New York', 'NY', 'USA', '10065', 40.7614, -73.9776, 1, 1, 2, 180.00, 30.00, TRUE, '2024-02-02 11:30:00', '2024-02-02 11:30:00'),
(3, 2, 'Beachfront Villa', 'Stunning 4-bedroom villa with private beach access and ocean views.', 'VILLA', '789 Ocean Drive', 'Miami Beach', 'FL', 'USA', '33139', 25.7907, -80.1300, 4, 3, 8, 450.00, 100.00, TRUE, '2024-02-15 12:00:00', '2024-02-15 12:00:00'),
(4, 2, 'Mountain Cabin Retreat', 'Rustic 3-bedroom cabin in the mountains, perfect for nature lovers.', 'CABIN', '321 Pine Trail', 'Aspen', 'CO', 'USA', '81611', 39.1911, -106.8175, 3, 2, 6, 320.00, 75.00, TRUE, '2024-02-16 14:15:00', '2024-02-16 14:15:00'),
(5, 3, 'Historic Townhouse', 'Beautiful 3-bedroom townhouse in historic district with modern updates.', 'TOWNHOUSE', '654 Heritage Lane', 'Charleston', 'SC', 'USA', '29401', 32.7765, -79.9311, 3, 2, 6, 280.00, 60.00, TRUE, '2024-03-01 15:30:00', '2024-03-01 15:30:00'),
(6, 3, 'Modern Loft Space', 'Industrial-style loft with high ceilings and contemporary design.', 'LOFT', '987 Art District Blvd', 'Los Angeles', 'CA', 'USA', '90013', 34.0522, -118.2437, 2, 1, 4, 220.00, 40.00, TRUE, '2024-03-02 16:45:00', '2024-03-02 16:45:00');

-- ============================================================================
-- 4. PROPERTY AMENITIES TABLE
-- ============================================================================
INSERT INTO property_amenities (amenity_id, property_id, amenity_type, description) VALUES
(1, 1, 'WIFI', 'High-speed wireless internet'),
(2, 1, 'KITCHEN', 'Fully equipped modern kitchen'),
(3, 1, 'PARKING', 'Underground parking space'),
(4, 1, 'GYM', 'Building fitness center access'),
(5, 2, 'WIFI', 'Complimentary WiFi'),
(6, 2, 'KITCHEN', 'Kitchenette with basic appliances'),
(7, 3, 'WIFI', 'High-speed internet'),
(8, 3, 'POOL', 'Private swimming pool'),
(9, 3, 'BEACH_ACCESS', 'Direct beach access'),
(10, 3, 'PARKING', 'Private driveway parking'),
(11, 4, 'WIFI', 'Satellite internet'),
(12, 4, 'FIREPLACE', 'Wood-burning fireplace'),
(13, 4, 'PARKING', 'Mountain trail parking'),
(14, 5, 'WIFI', 'High-speed internet'),
(15, 5, 'PARKING', 'Street parking available'),
(16, 6, 'WIFI', 'Fiber optic internet'),
(17, 6, 'PARKING', 'Secured garage parking');

-- ============================================================================
-- 5. BOOKINGS TABLE
-- ============================================================================
INSERT INTO bookings (booking_id, property_id, guest_id, check_in_date, check_out_date, num_guests, total_amount, booking_status, special_requests, created_at, updated_at) VALUES
(1, 1, 1, '2024-04-15', '2024-04-18', 2, 800.00, 'CONFIRMED', 'Late check-in requested', '2024-03-15 10:30:00', '2024-03-15 10:30:00'),
(2, 2, 2, '2024-04-20', '2024-04-22', 1, 390.00, 'CONFIRMED', NULL, '2024-03-18 14:20:00', '2024-03-18 14:20:00'),
(3, 3, 4, '2024-05-01', '2024-05-07', 6, 2800.00, 'CONFIRMED', 'Anniversary celebration', '2024-04-01 09:15:00', '2024-04-01 09:15:00'),
(4, 1, 7, '2024-05-15', '2024-05-17', 3, 575.00, 'PENDING', NULL, '2024-04-20 16:45:00', '2024-04-20 16:45:00'),
(5, 4, 8, '2024-06-10', '2024-06-15', 4, 1675.00, 'CONFIRMED', 'Bringing pets', '2024-05-01 11:30:00', '2024-05-01 11:30:00'),
(6, 5, 1, '2024-06-20', '2024-06-23', 4, 900.00, 'CONFIRMED', NULL, '2024-05-15 13:45:00', '2024-05-15 13:45:00'),
(7, 2, 3, '2024-07-01', '2024-07-05', 2, 750.00, 'CANCELLED', 'Family emergency', '2024-06-01 08:20:00', '2024-06-15 10:30:00'),
(8, 6, 2, '2024-07-15', '2024-07-18', 3, 700.00, 'CONFIRMED', NULL, '2024-06-20 15:10:00', '2024-06-20 15:10:00');

-- ============================================================================
-- 6. PAYMENTS TABLE
-- ============================================================================
INSERT INTO payments (payment_id, booking_id, amount, payment_method, payment_status, transaction_id, payment_date, created_at) VALUES
(1, 1, 800.00, 'CREDIT_CARD', 'COMPLETED', 'TXN_001_20240315', '2024-03-15 10:35:00', '2024-03-15 10:35:00'),
(2, 2, 390.00, 'DEBIT_CARD', 'COMPLETED', 'TXN_002_20240318', '2024-03-18 14:25:00', '2024-03-18 14:25:00'),
(3, 3, 1400.00, 'CREDIT_CARD', 'COMPLETED', 'TXN_003_20240401', '2024-04-01 09:20:00', '2024-04-01 09:20:00'),
(4, 3, 1400.00, 'CREDIT_CARD', 'COMPLETED', 'TXN_004_20240415', '2024-04-15 08:00:00', '2024-04-15 08:00:00'),
(5, 4, 287.50, 'CREDIT_CARD', 'PENDING', 'TXN_005_20240420', '2024-04-20 16:50:00', '2024-04-20 16:50:00'),
(6, 5, 837.50, 'PAYPAL', 'COMPLETED', 'TXN_006_20240501', '2024-05-01 11:35:00', '2024-05-01 11:35:00'),
(7, 5, 837.50, 'PAYPAL', 'COMPLETED', 'TXN_007_20240525', '2024-05-25 10:00:00', '2024-05-25 10:00:00'),
(8, 6, 450.00, 'CREDIT_CARD', 'COMPLETED', 'TXN_008_20240515', '2024-05-15 13:50:00', '2024-05-15 13:50:00'),
(9, 6, 450.00, 'CREDIT_CARD', 'COMPLETED', 'TXN_009_20240605', '2024-06-05 09:30:00', '2024-06-05 09:30:00'),
(10, 7, 375.00, 'CREDIT_CARD', 'REFUNDED', 'TXN_010_20240601', '2024-06-01 08:25:00', '2024-06-01 08:25:00'),
(11, 8, 350.00, 'DEBIT_CARD', 'COMPLETED', 'TXN_011_20240620', '2024-06-20 15:15:00', '2024-06-20 15:15:00');

-- ============================================================================
-- 7. REVIEWS TABLE
-- ============================================================================
INSERT INTO reviews (review_id, booking_id, reviewer_id, property_id, rating, title, comment, created_at) VALUES
(1, 1, 1, 1, 5, 'Excellent Stay!', 'The apartment was exactly as described. Great location and very clean. Would definitely book again!', '2024-04-20 15:30:00'),
(2, 2, 2, 2, 4, 'Cozy and Convenient', 'Perfect for a short stay. The park views were lovely, though the space was a bit smaller than expected.', '2024-04-25 10:15:00'),
(3, 3, 4, 3, 5, 'Dream Vacation', 'Absolutely stunning villa! The beach access was amazing and the house had everything we needed for our anniversary trip.', '2024-05-10 14:20:00'),
(4, 5, 8, 4, 4, 'Great Mountain Getaway', 'Beautiful cabin with amazing views. The fireplace was perfect for chilly evenings. Only minor issue was weak WiFi signal.', '2024-06-18 11:45:00'),
(5, 6, 1, 5, 5, 'Historic Charm', 'Loved the character of this townhouse! Great location for exploring the historic district. Host was very responsive.', '2024-06-25 16:30:00');

-- ============================================================================
-- 8. PROPERTY IMAGES TABLE
-- ============================================================================
INSERT INTO property_images (image_id, property_id, image_url, image_type, display_order, alt_text, created_at) VALUES
(1, 1, 'https://example.com/images/prop1_main.jpg', 'MAIN', 1, 'Downtown luxury apartment main view', '2024-02-01 10:00:00'),
(2, 1, 'https://example.com/images/prop1_bedroom.jpg', 'BEDROOM', 2, 'Master bedroom with city view', '2024-02-01 10:00:00'),
(3, 1, 'https://example.com/images/prop1_kitchen.jpg', 'KITCHEN', 3, 'Modern fully equipped kitchen', '2024-02-01 10:00:00'),
(4, 2, 'https://example.com/images/prop2_main.jpg', 'MAIN', 1, 'Cozy studio with park views', '2024-02-02 11:30:00'),
(5, 2, 'https://example.com/images/prop2_view.jpg', 'VIEW', 2, 'Central Park view from window', '2024-02-02 11:30:00'),
(6, 3, 'https://example.com/images/prop3_main.jpg', 'MAIN', 1, 'Beachfront villa exterior', '2024-02-15 12:00:00'),
(7, 3, 'https://example.com/images/prop3_beach.jpg', 'EXTERIOR', 2, 'Private beach access', '2024-02-15 12:00:00'),
(8, 3, 'https://example.com/images/prop3_pool.jpg', 'EXTERIOR', 3, 'Private swimming pool', '2024-02-15 12:00:00'),
(9, 4, 'https://example.com/images/prop4_main.jpg', 'MAIN', 1, 'Mountain cabin exterior', '2024-02-16 14:15:00'),
(10, 4, 'https://example.com/images/prop4_interior.jpg', 'LIVING_ROOM', 2, 'Rustic living room with fireplace', '2024-02-16 14:15:00'),
(11, 5, 'https://example.com/images/prop5_main.jpg', 'MAIN', 1, 'Historic townhouse facade', '2024-03-01 15:30:00'),
(12, 6, 'https://example.com/images/prop6_main.jpg', 'MAIN', 1, 'Modern loft interior', '2024-03-02 16:45:00');

-- ============================================================================
-- 9. BOOKING GUEST DETAILS TABLE (for additional guests)
-- ============================================================================
INSERT INTO booking_guests (guest_detail_id, booking_id, guest_name, guest_email, guest_phone, is_primary_guest) VALUES
(1, 1, 'John Doe', 'john.doe@email.com', '+1-555-0101', TRUE),
(2, 1, 'Jane Doe', 'jane.doe@email.com', '+1-555-0201', FALSE),
(3, 2, 'Sarah Johnson', 'sarah.johnson@email.com', '+1-555-0102', TRUE),
(4, 3, 'Emily Rodriguez', 'emily.rodriguez@email.com', '+1-555-0104', TRUE),
(5, 3, 'Carlos Rodriguez', 'carlos.rodriguez@email.com', '+1-555-0204', FALSE),
(6, 3, 'Maria Rodriguez', 'maria.rodriguez@email.com', '+1-555-0304', FALSE),
(7, 3, 'Sofia Rodriguez', 'sofia.rodriguez@email.com', '+1-555-0404', FALSE),
(8, 4, 'Robert Taylor', 'robert.taylor@email.com', '+1-555-0107', TRUE),
(9, 4, 'Linda Taylor', 'linda.taylor@email.com', '+1-555-0207', FALSE),
(10, 4, 'Mike Taylor', 'mike.taylor@email.com', '+1-555-0307', FALSE),
(11, 5, 'Jessica Brown', 'jessica.brown@email.com', '+1-555-0108', TRUE),
(12, 5, 'James Brown', 'james.brown@email.com', '+1-555-0208', FALSE),
(13, 6, 'John Doe', 'john.doe@email.com', '+1-555-0101', TRUE),
(14, 8, 'Sarah Johnson', 'sarah.johnson@email.com', '+1-555-0102', TRUE),
(15, 8, 'Mark Johnson', 'mark.johnson@email.com', '+1-555-0302', FALSE);

-- ============================================================================
-- 10. PROPERTY AVAILABILITY TABLE
-- ============================================================================
INSERT INTO property_availability (availability_id, property_id, available_date, is_available, price_override, minimum_stay) VALUES
-- Property 1 availability for next 30 days
(1, 1, '2024-07-01', TRUE, NULL, 1),
(2, 1, '2024-07-02', TRUE, NULL, 1),
(3, 1, '2024-07-03', TRUE, NULL, 1),
(4, 1, '2024-07-04', TRUE, 275.00, 1), -- July 4th premium
(5, 1, '2024-07-05', TRUE, NULL, 1),
-- Property 2 availability
(6, 2, '2024-07-01', TRUE, NULL, 1),
(7, 2, '2024-07-02', TRUE, NULL, 1),
(8, 2, '2024-07-15', FALSE, NULL, 1), -- Booked
(9, 2, '2024-07-16', FALSE, NULL, 1), -- Booked
(10, 2, '2024-07-17', FALSE, NULL, 1), -- Booked
-- Property 3 summer availability
(11, 3, '2024-08-01', TRUE, 500.00, 3), -- Summer premium, min 3 nights
(12, 3, '2024-08-02', TRUE, 500.00, 3),
(13, 3, '2024-08-03', TRUE, 500.00, 3),
(14, 3, '2024-08-04', TRUE, 500.00, 3),
(15, 3, '2024-08-05', TRUE, 500.00, 3);

-- ============================================================================
-- SUMMARY OF INSERTED DATA
-- ============================================================================
-- Users: 8 users with varied profiles
-- Property Owners: 3 owners managing multiple properties
-- Properties: 6 diverse properties (apartments, villa, cabin, townhouse, loft)
-- Amenities: 17 amenity records across all properties
-- Bookings: 8 bookings with different statuses (confirmed, pending, cancelled)
-- Payments: 11 payment records including refunds and partial payments
-- Reviews: 5 reviews with ratings from 4-5 stars
-- Property Images: 12 image records for property galleries
-- Booking Guests: 15 guest detail records for group bookings
-- Property Availability: 15 availability records with pricing variations

-- This sample data represents realistic usage patterns including:
-- - Repeat customers (User 1 has multiple bookings)
-- - Group bookings with multiple guests
-- - Seasonal pricing adjustments
-- - Various payment methods and statuses
-- - Cancelled bookings with refunds
-- - Property reviews and ratings
-- - Mixed property types and price ranges