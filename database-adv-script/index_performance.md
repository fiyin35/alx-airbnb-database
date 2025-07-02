# Index Performance Analysis
This document outlines the performance impact of adding indexes to the database.

How to Measure Performance
To measure the performance before and after adding indexes, use the EXPLAIN ANALYZE command in PostgreSQL on the queries in performance.sql. For example:

EXPLAIN ANALYZE
SELECT
    b.booking_id,
    b.start_date,
    b.end_date,
    u.first_name,
    u.last_name,
    p.name AS property_name,
    py.amount
FROM
    bookings b
JOIN
    users u ON b.user_id = u.user_id
JOIN
    properties p ON b.property_id = p.property_id
JOIN
    payments py ON b.booking_id = py.booking_id;

Analysis
Adding indexes on foreign key columns (user_id, property_id, booking_id) significantly improves the performance of JOIN operations. The database can use the indexes to quickly look up matching rows in the joined tables, avoiding costly full-table scans.