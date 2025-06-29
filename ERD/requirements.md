Key Features:

6 Entities: User, Property, Booking, Payment, Review, and Message
Visual Coding: Primary keys (PK) in red, Foreign keys (FK) in blue
Complete Attributes: All attributes with their data types and constraints
Relationship Documentation: Detailed explanations of how entities relate to each other

Main Relationships:

User ↔ Property: One-to-Many (Users can host multiple properties)
User ↔ Booking: One-to-Many (Users can make multiple bookings)
Property ↔ Booking: One-to-Many (Properties can have multiple bookings)
Booking ↔ Payment: One-to-One (Each booking has one payment)
User ↔ Review: One-to-Many (Users can write multiple reviews)
Property ↔ Review: One-to-Many (Properties can have multiple reviews)
User ↔ Message: One-to-Many (Users can send/receive multiple messages)

Database Design Highlights:

UUID Primary Keys for all entities (better for distributed systems)
Proper Foreign Key Constraints maintaining referential integrity
ENUM Types for controlled values (roles, payment methods, booking status)
Timestamp Tracking for audit trails
Check Constraints for data validation (rating 1-5)

The diagram provides a clear visual representation that can be used for database implementation, documentation, or further system design discussions. Each entity box shows all attributes with proper key indicators, making it easy to understand the database structure at a glance.

