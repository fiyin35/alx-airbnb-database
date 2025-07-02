-- =====================================================
-- AirBnB Database Schema - SQL DDL Statements
-- Normalized to Third Normal Form (3NF)
-- =====================================================

-- Drop existing tables if they exist (in reverse dependency order)
DROP TABLE IF EXISTS Property_Amenities;
DROP TABLE IF EXISTS Message;
DROP TABLE IF EXISTS Review;
DROP TABLE IF EXISTS Payment;
DROP TABLE IF EXISTS Booking;
DROP TABLE IF EXISTS Property;
DROP TABLE IF EXISTS Amenity;
DROP TABLE IF EXISTS Property_Type;
DROP TABLE IF EXISTS Location;
DROP TABLE IF EXISTS User;

-- =====================================================
-- CORE TABLES
-- =====================================================

-- User Table
CREATE TABLE User (
    user_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20) NULL,
    role ENUM('guest', 'host', 'admin') NOT NULL DEFAULT 'guest',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_email_format CHECK (email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT chk_phone_format CHECK (phone_number IS NULL OR phone_number REGEXP '^[+]?[0-9\s\-\(\)]{10,20}$'),
    CONSTRAINT chk_name_length CHECK (LENGTH(first_name) >= 1 AND LENGTH(last_name) >= 1)
);

-- Location Table (Normalized from Property)
CREATE TABLE Location (
    location_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    street_address VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state_province VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NULL,
    latitude DECIMAL(10, 8) NULL,
    longitude DECIMAL(11, 8) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_latitude CHECK (latitude IS NULL OR (latitude >= -90 AND latitude <= 90)),
    CONSTRAINT chk_longitude CHECK (longitude IS NULL OR (longitude >= -180 AND longitude <= 180)),
    CONSTRAINT chk_address_length CHECK (LENGTH(TRIM(street_address)) >= 5),
    CONSTRAINT chk_city_length CHECK (LENGTH(TRIM(city)) >= 2),
    CONSTRAINT chk_country_length CHECK (LENGTH(TRIM(country)) >= 2)
);

-- Property Type Table (Further Normalization)
CREATE TABLE Property_Type (
    type_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_type_name_length CHECK (LENGTH(TRIM(name)) >= 2)
);

-- Amenity Table (Normalized from Property)
CREATE TABLE Amenity (
    amenity_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT NULL,
    category VARCHAR(50) NULL DEFAULT 'General',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_amenity_name_length CHECK (LENGTH(TRIM(name)) >= 2),
    CONSTRAINT chk_amenity_category CHECK (category IN ('General', 'Kitchen', 'Bathroom', 'Entertainment', 'Outdoor', 'Safety', 'Accessibility'))
);

-- Property Table (Modified for 3NF)
CREATE TABLE Property (
    property_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    host_id CHAR(36) NOT NULL,
    location_id CHAR(36) NOT NULL,
    type_id CHAR(36) NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    pricepernight DECIMAL(10, 2) NOT NULL,
    max_guests INT NOT NULL DEFAULT 1,
    bedrooms INT NOT NULL DEFAULT 1,
    bathrooms DECIMAL(3, 1) NOT NULL DEFAULT 1.0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key Constraints
    FOREIGN KEY (host_id) REFERENCES User(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (location_id) REFERENCES Location(location_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (type_id) REFERENCES Property_Type(type_id) ON DELETE SET NULL ON UPDATE CASCADE,
    
    -- Business Logic Constraints
    CONSTRAINT chk_price_positive CHECK (pricepernight > 0),
    CONSTRAINT chk_max_guests_positive CHECK (max_guests > 0 AND max_guests <= 50),
    CONSTRAINT chk_bedrooms_positive CHECK (bedrooms > 0 AND bedrooms <= 20),
    CONSTRAINT chk_bathrooms_positive CHECK (bathrooms > 0 AND bathrooms <= 20),
    CONSTRAINT chk_property_name_length CHECK (LENGTH(TRIM(name)) >= 5),
    CONSTRAINT chk_description_length CHECK (LENGTH(TRIM(description)) >= 20)
);

-- Property_Amenities Junction Table (Many-to-Many)
CREATE TABLE Property_Amenities (
    property_id CHAR(36) NOT NULL,
    amenity_id CHAR(36) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Composite Primary Key
    PRIMARY KEY (property_id, amenity_id),
    
    -- Foreign Key Constraints
    FOREIGN KEY (property_id) REFERENCES Property(property_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (amenity_id) REFERENCES Amenity(amenity_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Booking Table (Modified - removed calculated total_price for 3NF)
CREATE TABLE Booking (
    booking_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    property_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    guest_count INT NOT NULL DEFAULT 1,
    status ENUM('pending', 'confirmed', 'canceled', 'completed') NOT NULL DEFAULT 'pending',
    special_requests TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key Constraints
    FOREIGN KEY (property_id) REFERENCES Property(property_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    
    -- Business Logic Constraints
    CONSTRAINT chk_booking_dates CHECK (end_date > start_date),
    CONSTRAINT chk_booking_future CHECK (start_date >= CURDATE()),
    CONSTRAINT chk_guest_count_positive CHECK (guest_count > 0),
    CONSTRAINT chk_booking_duration CHECK (DATEDIFF(end_date, start_date) <= 365), -- Max 1 year booking
    
    -- Prevent double booking (will be enforced by unique index)
    UNIQUE KEY uk_property_dates (property_id, start_date, end_date)
);

-- Payment Table
CREATE TABLE Payment (
    payment_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    booking_id CHAR(36) NOT NULL UNIQUE, -- One payment per booking
    amount DECIMAL(12, 2) NOT NULL,
    currency CHAR(3) NOT NULL DEFAULT 'USD',
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_method ENUM('credit_card', 'debit_card', 'paypal', 'stripe', 'bank_transfer') NOT NULL,
    payment_status ENUM('pending', 'completed', 'failed', 'refunded') NOT NULL DEFAULT 'pending',
    transaction_id VARCHAR(100) UNIQUE NULL,
    payment_gateway VARCHAR(50) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key Constraints
    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    
    -- Business Logic Constraints
    CONSTRAINT chk_payment_amount_positive CHECK (amount > 0),
    CONSTRAINT chk_currency_format CHECK (currency REGEXP '^[A-Z]{3}$')
);

-- Review Table
CREATE TABLE Review (
    review_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    property_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    booking_id CHAR(36) NULL, -- Link to specific booking
    rating INTEGER NOT NULL,
    comment TEXT NOT NULL,
    is_visible BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key Constraints
    FOREIGN KEY (property_id) REFERENCES Property(property_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id) ON DELETE SET NULL ON UPDATE CASCADE,
    
    -- Business Logic Constraints
    CONSTRAINT chk_rating_range CHECK (rating >= 1 AND rating <= 5),
    CONSTRAINT chk_comment_length CHECK (LENGTH(TRIM(comment)) >= 10),
    
    -- Prevent multiple reviews for same property by same user
    UNIQUE KEY uk_user_property_review (user_id, property_id, booking_id)
);

-- Message Table
CREATE TABLE Message (
    message_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    sender_id CHAR(36) NOT NULL,
    recipient_id CHAR(36) NOT NULL,
    property_id CHAR(36) NULL, --  link to specific property discussion
    booking_id CHAR(36) NULL, -- link to specific booking discussion
    subject VARCHAR(255) NULL,
    message_body TEXT NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP NULL,
    
    -- Foreign Key Constraints
    FOREIGN KEY (sender_id) REFERENCES User(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (recipient_id) REFERENCES User(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (property_id) REFERENCES Property(property_id) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id) ON DELETE SET NULL ON UPDATE CASCADE,
    
    -- Business Logic Constraints
    CONSTRAINT chk_message_body_length CHECK (LENGTH(TRIM(message_body)) >= 1),
    CONSTRAINT chk_different_users CHECK (sender_id != recipient_id),
    CONSTRAINT chk_read_timestamp CHECK (read_at IS NULL OR read_at >= sent_at)
);

-- =====================================================
-- PERFORMANCE INDEXES
-- =====================================================

-- User Table Indexes
CREATE INDEX idx_user_email ON User(email);
CREATE INDEX idx_user_role ON User(role);
CREATE INDEX idx_user_created_at ON User(created_at);

-- Location Table Indexes
CREATE INDEX idx_location_city ON Location(city);
CREATE INDEX idx_location_country ON Location(country);
CREATE INDEX idx_location_city_country ON Location(city, country);
CREATE INDEX idx_location_coordinates ON Location(latitude, longitude);

-- Property Table Indexes
CREATE INDEX idx_property_host_id ON Property(host_id);
CREATE INDEX idx_property_location_id ON Property(location_id);
CREATE INDEX idx_property_type_id ON Property(type_id);
CREATE INDEX idx_property_price ON Property(pricepernight);
CREATE INDEX idx_property_active ON Property(is_active);
CREATE INDEX idx_property_price_active ON Property(pricepernight, is_active);
CREATE INDEX idx_property_created_at ON Property(created_at);

-- Booking Table Indexes
CREATE INDEX idx_booking_property_id ON Booking(property_id);
CREATE INDEX idx_booking_user_id ON Booking(user_id);
CREATE INDEX idx_booking_dates ON Booking(start_date, end_date);
CREATE INDEX idx_booking_status ON Booking(status);
CREATE INDEX idx_booking_start_date ON Booking(start_date);
CREATE INDEX idx_booking_property_status ON Booking(property_id, status);
CREATE INDEX idx_booking_user_status ON Booking(user_id, status);

-- Payment Table Indexes
CREATE INDEX idx_payment_booking_id ON Payment(booking_id);
CREATE INDEX idx_payment_status ON Payment(payment_status);
CREATE INDEX idx_payment_method ON Payment(payment_method);
CREATE INDEX idx_payment_date ON Payment(payment_date);
CREATE INDEX idx_payment_transaction_id ON Payment(transaction_id);

-- Review Table Indexes
CREATE INDEX idx_review_property_id ON Review(property_id);
CREATE INDEX idx_review_user_id ON Review(user_id);
CREATE INDEX idx_review_booking_id ON Review(booking_id);
CREATE INDEX idx_review_rating ON Review(rating);
CREATE INDEX idx_review_visible ON Review(is_visible);
CREATE INDEX idx_review_created_at ON Review(created_at);
CREATE INDEX idx_review_property_visible ON Review(property_id, is_visible);

-- Message Table Indexes
CREATE INDEX idx_message_sender_id ON Message(sender_id);
CREATE INDEX idx_message_recipient_id ON Message(recipient_id);
CREATE INDEX idx_message_property_id ON Message(property_id);
CREATE INDEX idx_message_booking_id ON Message(booking_id);
CREATE INDEX idx_message_sent_at ON Message(sent_at);
CREATE INDEX idx_message_is_read ON Message(is_read);
CREATE INDEX idx_message_recipient_read ON Message(recipient_id, is_read);

-- Property_Amenities Junction Table Indexes
CREATE INDEX idx_property_amenities_amenity_id ON Property_Amenities(amenity_id);

-- =====================================================
-- VIEWS FOR COMMON QUERIES
-- =====================================================

-- Property Details View (with location and amenities)
CREATE VIEW vw_property_details AS
SELECT 
    p.property_id,
    p.name AS property_name,
    p.description,
    p.pricepernight,
    p.max_guests,
    p.bedrooms,
    p.bathrooms,
    p.is_active,
    u.first_name AS host_first_name,
    u.last_name AS host_last_name,
    u.email AS host_email,
    pt.name AS property_type,
    l.street_address,
    l.city,
    l.state_province,
    l.country,
    l.postal_code,
    l.latitude,
    l.longitude,
    p.created_at,
    p.updated_at
FROM Property p
JOIN User u ON p.host_id = u.user_id
JOIN Location l ON p.location_id = l.location_id
LEFT JOIN Property_Type pt ON p.type_id = pt.type_id;

-- Booking Summary View
CREATE VIEW vw_booking_summary AS
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.guest_count,
    b.status,
    DATEDIFF(b.end_date, b.start_date) AS duration_days,
    p.name AS property_name,
    p.pricepernight,
    (p.pricepernight * DATEDIFF(b.end_date, b.start_date)) AS calculated_total,
    CONCAT(u.first_name, ' ', u.last_name) AS guest_name,
    u.email AS guest_email,
    CONCAT(h.first_name, ' ', h.last_name) AS host_name,
    pay.amount AS paid_amount,
    pay.payment_status,
    b.created_at AS booking_created_at
FROM Booking b
JOIN Property p ON b.property_id = p.property_id
JOIN User u ON b.user_id = u.user_id
JOIN User h ON p.host_id = h.user_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id;

-- Property Reviews Summary View
CREATE VIEW vw_property_reviews AS
SELECT 
    p.property_id,
    p.name AS property_name,
    COUNT(r.review_id) AS total_reviews,
    AVG(r.rating) AS average_rating,
    COUNT(CASE WHEN r.rating = 5 THEN 1 END) AS five_star_count,
    COUNT(CASE WHEN r.rating = 4 THEN 1 END) AS four_star_count,
    COUNT(CASE WHEN r.rating = 3 THEN 1 END) AS three_star_count,
    COUNT(CASE WHEN r.rating = 2 THEN 1 END) AS two_star_count,
    COUNT(CASE WHEN r.rating = 1 THEN 1 END) AS one_star_count,
    MAX(r.created_at) AS latest_review_date
FROM Property p
LEFT JOIN Review r ON p.property_id = r.property_id AND r.is_visible = TRUE
GROUP BY p.property_id, p.name;

-- =====================================================
-- TRIGGERS FOR BUSINESS LOGIC
-- =====================================================

-- Trigger to prevent booking overlaps (additional safety)
DELIMITER //
CREATE TRIGGER trg_prevent_booking_overlap
BEFORE INSERT ON Booking
FOR EACH ROW
BEGIN
    DECLARE overlap_count INT DEFAULT 0;
    
    SELECT COUNT(*) INTO overlap_count
    FROM Booking
    WHERE property_id = NEW.property_id
      AND status IN ('confirmed', 'pending')
      AND (
          (NEW.start_date BETWEEN start_date AND end_date - INTERVAL 1 DAY) OR
          (NEW.end_date BETWEEN start_date + INTERVAL 1 DAY AND end_date) OR
          (start_date BETWEEN NEW.start_date AND NEW.end_date - INTERVAL 1 DAY) OR
          (end_date BETWEEN NEW.start_date + INTERVAL 1 DAY AND NEW.end_date)
      );
    
    IF overlap_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Booking dates overlap with existing booking';
    END IF;
END//
DELIMITER ;

-- Trigger to update property updated_at when amenities change
DELIMITER //
CREATE TRIGGER trg_property_amenities_update
AFTER INSERT ON Property_Amenities
FOR EACH ROW
BEGIN
    UPDATE Property 
    SET updated_at = CURRENT_TIMESTAMP 
    WHERE property_id = NEW.property_id;
END//
DELIMITER ;

-- =====================================================
-- SAMPLE DATA INSERTION
-- =====================================================

-- Insert sample property types
INSERT INTO Property_Type (name, description) VALUES
('Apartment', 'Self-contained housing unit in a building'),
('House', 'Standalone residential building'),
('Condo', 'Individually owned unit in a building'),
('Villa', 'Luxury house with extensive grounds'),
('Studio', 'Single large room serving multiple functions'),
('Loft', 'Large, open space converted from commercial use');

-- Insert sample amenities
INSERT INTO Amenity (name, description, category) VALUES
('WiFi', 'Wireless internet access', 'General'),
('Air Conditioning', 'Climate control system', 'General'),
('Kitchen', 'Full kitchen with appliances', 'Kitchen'),
('Parking', 'Dedicated parking space', 'General'),
('Pool', 'Swimming pool access', 'Outdoor'),
('Gym', 'Fitness center access', 'Entertainment'),
('Pet Friendly', 'Pets allowed', 'General'),
('Wheelchair Accessible', 'Accessible for wheelchair users', 'Accessibility');

-- =====================================================
-- PERFORMANCE ANALYSIS QUERIES
-- =====================================================

-- Query to analyze table sizes and index usage
-- (Uncomment to run performance analysis)
/*
SELECT 
    TABLE_NAME,
    TABLE_ROWS,
    DATA_LENGTH,
    INDEX_LENGTH,
    DATA_FREE
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = DATABASE()
ORDER BY DATA_LENGTH DESC;
*/