# Query Optimization Report

**Objective:** Analyze and optimize the performance of a complex query joining `Booking`, `User`, `Property`, and `Payment` tables.



## Initial Query (Full Join)

```sql
SELECT
    b.booking_id, b.start_date, b.end_date, b.status,
    u.user_id, u.first_name, u.last_name, u.email,
    p.property_id, p.name AS property_name, p.pricepernight,
    pay.payment_id, pay.amount, pay.payment_date, pay.status AS payment_status
FROM Booking b
JOIN User u ON b.user_id = u.user_id
JOIN Property p ON b.property_id = p.property_id
LEFT JOIN Payment pay ON pay.booking_id = b.booking_id;
```

### EXPLAIN Output (Simulated)

| id | select_type | table   | type | possible_keys           | key               | rows | Extra                 |
|----|-------------|---------|------|--------------------------|--------------------|------|------------------------|
| 1  | SIMPLE      | b       | ALL  | NULL                     | NULL               | 1000 |                        |
| 1  | SIMPLE      | u       | ALL  | PRIMARY                  | NULL               | 1000 | Using where            |
| 1  | SIMPLE      | p       | ALL  | PRIMARY                  | NULL               | 1000 | Using where            |
| 1  | SIMPLE      | pay     | ALL  | booking_id               | NULL               | 1000 | Using where; Using join buffer |

### Inefficiencies

- **Table scans (`ALL`)** on all 4 tables.
- No indexes used (`key = NULL`).
- High `rows` values — large intermediate joins.
- `Using join buffer` on `Payment` due to lack of usable index.

---

## Optimized Query

```sql
SELECT
    b.booking_id, b.start_date, b.end_date, b.status,
    CONCAT(u.first_name, ' ', u.last_name) AS guest_name,
    u.email, p.name AS property_name, p.pricepernight,
    pay.amount, pay.status AS payment_status
FROM Booking b
JOIN User u ON b.user_id = u.user_id
JOIN Property p ON b.property_id = p.property_id
LEFT JOIN Payment pay ON pay.booking_id = b.booking_id;
```

### Indexes Added

```sql
CREATE INDEX idx_booking_user ON Booking (user_id);
CREATE INDEX idx_booking_property ON Booking (property_id);
CREATE INDEX idx_payment_booking ON Payment (booking_id);
```

### EXPLAIN Output (Expected)

| id | select_type | table   | type  | possible_keys           | key                  | rows | Extra                 |
|----|-------------|---------|-------|--------------------------|-----------------------|------|------------------------|
| 1  | SIMPLE      | b       | index | PRIMARY                  | idx_booking_property  | 50   | Using index            |
| 1  | SIMPLE      | u       | ref   | PRIMARY                  | PRIMARY               | 1    |                        |
| 1  | SIMPLE      | p       | ref   | PRIMARY                  | PRIMARY               | 1    |                        |
| 1  | SIMPLE      | pay     | ref   | booking_id               | idx_payment_booking   | 1    |                        |

### Improvements

- Join conditions use indexes.
- Fewer rows examined.
- Join buffer eliminated.
- Reduced I/O and faster execution.



## Summary

| Metric              | Before Optimization | After Optimization |
|---------------------|---------------------|--------------------|
| Index Usage         | ❌ None              | ✅ 3 indexes used  |
| Join Buffer         | ❌ Yes (Payment)     | ✅ Eliminated      |
| Table Scan          | ✅ Full              | ❌ Reduced         |
| Execution Speed     | 🐢 Slower            | 🚀 Faster          |
| I/O Cost            | 🔺 High              | 🔻 Low             |



