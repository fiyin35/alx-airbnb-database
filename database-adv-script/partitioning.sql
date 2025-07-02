--Implement Partitioning by start_date
🔧 --Strategy:
-- Use RANGE partitioning by YEAR(start_date), because:

    -- start_date is a natural partition key.

-- Most queries use date filters (WHERE start_date BETWEEN ...).

-- Backup original
RENAME TABLE Booking TO Booking_old;

-- Recreate with partitioning
CREATE TABLE Booking (
    booking_id CHAR(36) PRIMARY KEY,
    property_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    guest_count INT NOT NULL DEFAULT 1,
    status ENUM('pending', 'confirmed', 'canceled', 'completed') NOT NULL DEFAULT 'pending',
    special_requests TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_property_dates (property_id, start_date, end_date)
)
PARTITION BY RANGE (YEAR(start_date)) (
    PARTITION p2021 VALUES LESS THAN (2022),
    PARTITION p2022 VALUES LESS THAN (2023),
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p2025 VALUES LESS THAN (2026),
    PARTITION pmax VALUES LESS THAN MAXVALUE
);
