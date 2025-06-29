# AirBnB Database Normalization Analysis - 3NF

## Overview
This document analyzes the AirBnB database schema for normalization violations and applies the necessary steps to achieve Third Normal Form (3NF). The analysis covers First Normal Form (1NF), Second Normal Form (2NF), and Third Normal Form (3NF) compliance.

## Current Schema Analysis

### Original Tables Structure

#### User Table
- **Primary Key:** user_id (UUID)
- **Attributes:** first_name, last_name, email, password_hash, phone_number, role, created_at
- **Status:** ✅ Already in 3NF

#### Property Table
- **Primary Key:** property_id (UUID)
- **Attributes:** host_id (FK), name, description, location, pricepernight, created_at, updated_at
- **Issues:** Location field may contain multiple pieces of information

#### Booking Table
- **Primary Key:** booking_id (UUID)
- **Attributes:** property_id (FK), user_id (FK), start_date, end_date, total_price, status, created_at
- **Issues:** total_price can be calculated from property price and dates

#### Payment Table
- **Primary Key:** payment_id (UUID)
- **Attributes:** booking_id (FK), amount, payment_date, payment_method
- **Status:** ✅ Already in 3NF

#### Review Table
- **Primary Key:** review_id (UUID)
- **Attributes:** property_id (FK), user_id (FK), rating, comment, created_at
- **Status:** ✅ Already in 3NF

#### Message Table
- **Primary Key:** message_id (UUID)
- **Attributes:** sender_id (FK), recipient_id (FK), message_body, sent_at
- **Status:** ✅ Already in 3NF

## Normalization Process

### Step 1: First Normal Form (1NF) Analysis

**Requirements:**
- Each column contains atomic values
- No repeating groups
- Each row is unique

**Current Status:**
- ✅ All tables have atomic values
- ✅ No repeating groups identified
- ✅ Primary keys ensure uniqueness

**Violation Found:** The `location` field in the Property table may contain composite information (e.g., "123 Main St, New York, NY 10001").

### Step 2: Second Normal Form (2NF) Analysis

**Requirements:**
- Must be in 1NF
- No partial dependencies (non-key attributes fully dependent on entire primary key)

**Current Status:**
- ✅ All tables have single-column primary keys
- ✅ No composite primary keys exist
- ✅ All non-key attributes depend on the full primary key

**No violations found** - all tables are in 2NF.

### Step 3: Third Normal Form (3NF) Analysis

**Requirements:**
- Must be in 2NF
- No transitive dependencies (non-key attributes should not depend on other non-key attributes)

**Violations Identified:**

1. **Property Table - Location Dependency**
   - Current: `location` contains full address
   - Issue: City, state, country information is mixed
   - Solution: Create separate Location table

2. **Booking Table - Calculated Field**
   - Current: `total_price` stored as attribute
   - Issue: Can be calculated from property price and booking duration
   - Solution: Remove total_price or justify its storage for performance

## Normalized Schema Design

### New Tables to Achieve 3NF

#### Location Table (New)
```sql
CREATE TABLE Location (
    location_id UUID PRIMARY KEY,
    street_address VARCHAR NOT NULL,
    city VARCHAR NOT NULL,
    state_province VARCHAR NOT NULL,
    country VARCHAR NOT NULL,
    postal_code VARCHAR,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### Property Table (Modified)
```sql
CREATE TABLE Property (
    property_id UUID PRIMARY KEY,
    host_id UUID NOT NULL,
    location_id UUID NOT NULL,
    name VARCHAR NOT NULL,
    description TEXT NOT NULL,
    pricepernight DECIMAL NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (host_id) REFERENCES User(user_id),
    FOREIGN KEY (location_id) REFERENCES Location(location_id)
);
```

#### Property_Amenities Table (New - Additional Normalization)
```sql
CREATE TABLE Amenity (
    amenity_id UUID PRIMARY KEY,
    name VARCHAR UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Property_Amenities (
    property_id UUID,
    amenity_id UUID,
    PRIMARY KEY (property_id, amenity_id),
    FOREIGN KEY (property_id) REFERENCES Property(property_id) ON DELETE CASCADE,
    FOREIGN KEY (amenity_id) REFERENCES Amenity(amenity_id) ON DELETE CASCADE
);
```

#### Booking Table (Decision on total_price)
**Option 1: Remove total_price (Pure 3NF)**
```sql
CREATE TABLE Booking (
    booking_id UUID PRIMARY KEY,
    property_id UUID NOT NULL,
    user_id UUID NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status ENUM('pending', 'confirmed', 'canceled') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (property_id) REFERENCES Property(property_id),
    FOREIGN KEY (user_id) REFERENCES User(user_id)
);
```

**Option 2: Keep total_price (Justified Denormalization)**
```sql
-- Keep original structure but add justification:
-- total_price stored for:
-- 1. Historical pricing (property prices may change)
-- 2. Discounts and promotions
-- 3. Performance optimization
-- 4. Audit trail
```

## Final Normalized Schema

### Core Tables (3NF Compliant)

1. **User** - No changes needed ✅
2. **Location** - New table for address normalization
3. **Property** - Modified to reference Location
4. **Amenity** - New table for property features
5. **Property_Amenities** - Junction table for many-to-many relationship
6. **Booking** - Consider removing calculated total_price
7. **Payment** - No changes needed ✅
8. **Review** - No changes needed ✅
9. **Message** - No changes needed ✅

### Additional Considerations

#### Property Categories (Further Normalization)
```sql
CREATE TABLE Property_Type (
    type_id UUID PRIMARY KEY,
    name VARCHAR UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Add to Property table:
ALTER TABLE Property ADD COLUMN type_id UUID;
ALTER TABLE Property ADD FOREIGN KEY (type_id) REFERENCES Property_Type(type_id);
```

#### User Roles (Further Normalization)
```sql
CREATE TABLE Role (
    role_id UUID PRIMARY KEY,
    name VARCHAR UNIQUE NOT NULL,
    description TEXT,
    permissions JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Modify User table:
ALTER TABLE User DROP COLUMN role;
ALTER TABLE User ADD COLUMN role_id UUID;
ALTER TABLE User ADD FOREIGN KEY (role_id) REFERENCES Role(role_id);
```

## Benefits of Normalization

### Advantages
1. **Eliminates Data Redundancy** - No duplicate location information
2. **Improves Data Integrity** - Consistent address information
3. **Reduces Storage Space** - Shared location records
4. **Easier Maintenance** - Update location once, affects all properties
5. **Better Query Flexibility** - Can search by city, state, country independently

### Trade-offs
1. **Increased Complexity** - More joins required for queries
2. **Potential Performance Impact** - More tables to join
3. **Development Overhead** - More complex queries and relationships

## Implementation Strategy

### Phase 1: Create New Tables
1. Create Location table
2. Create Amenity and Property_Amenities tables
3. Create Property_Type table (optional)

### Phase 2: Data Migration
1. Extract location data from existing Property records
2. Create Location records
3. Update Property table with location_id references
4. Migrate amenity data if it exists in description fields

### Phase 3: Update Application Code
1. Modify queries to use new table relationships
2. Update insert/update operations
3. Test performance and optimize as needed

### Phase 4: Cleanup
1. Drop old location column from Property table
2. Add proper indexes for performance
3. Update documentation

## Conclusion

The normalized schema achieves 3NF compliance by:
- ✅ Eliminating transitive dependencies through Location table separation
- ✅ Maintaining atomic values in all columns
- ✅ Ensuring all non-key attributes depend only on primary keys
- ✅ Reducing data redundancy while maintaining referential integrity

The design balances normalization principles with practical considerations, providing a solid foundation for the AirBnB application while maintaining data integrity and enabling efficient querying patterns.