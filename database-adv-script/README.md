# A query that uses an INNER JOIN to retrieve all bookings and the respective users who made those bookings.

These queries demonstrate the three main types of JOINs:
INNER JOIN - Returns only records that have matching values in both tables. In this case, only bookings that have corresponding users will be returned.
LEFT JOIN - Returns all records from the left table (properties) and matching records from the right table (reviews). Properties without reviews will still appear with NULL values for review columns.
FULL OUTER JOIN - Returns all records from both tables, showing unmatched records from either side with NULL values where no match exists. This means you'll see users without bookings and any orphaned bookings without users.

The assumed table structure includes:
users (user_id, first_name, last_name, email)
bookings (booking_id, user_id, booking_date, check_in_date, check_out_date, total_amount)
properties (property_id, property_name, location, price_per_night)
reviews (review_id, property_id, rating, comment, review_date)