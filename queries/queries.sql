-- ============================================================
-- RAILCONNECT
-- SQL QUERIES — queries.sql
-- Business Questions Q1–Q7 (PRD Section 6)
-- MySQL 8.0+
-- Run AFTER create_tables.sql and insert_data.sql
-- ============================================================

USE RailConnect;


-- ============================================================
-- Q1. What are the most popular routes?
--     GROUP BY source–destination pair, COUNT
-- ============================================================
--
-- A "route" is a unique (from_station, to_station) pair.
-- We count the number of bookings per pair and rank them.
-- We join stations twice (aliased) to get readable city names.
-- ============================================================

SELECT
    s_from.name                         AS from_station,
    s_from.city                         AS from_city,
    s_to.name                           AS to_station,
    s_to.city                           AS to_city,
    COUNT(b.booking_id)                 AS total_bookings
FROM
    bookings b
    JOIN stations s_from ON b.from_station_id = s_from.station_id
    JOIN stations s_to   ON b.to_station_id   = s_to.station_id
GROUP BY
    b.from_station_id,
    b.to_station_id,
    s_from.name,
    s_from.city,
    s_to.name,
    s_to.city
ORDER BY
    total_bookings DESC;


-- ============================================================
-- Q2. Which trains are booked most often?
--     JOIN, COUNT, ORDER BY
-- ============================================================
--
-- We count bookings per train and order by most bookings.
-- Joining trains gives us the train name and number.
-- ============================================================

SELECT
    t.train_id,
    t.train_no,
    t.name                              AS train_name,
    t.train_type,
    COUNT(b.booking_id)                 AS total_bookings
FROM
    trains t
    JOIN bookings b ON t.train_id = b.train_id
GROUP BY
    t.train_id,
    t.train_no,
    t.name,
    t.train_type
ORDER BY
    total_bookings DESC;


-- ============================================================
-- Q3. What is the seat occupancy for each train?
--     Ratio of booked seats to total seats
-- ============================================================
--
-- "Total seats" = all seats across all coaches of a train.
-- "Booked seats" = tickets with status Confirmed or
--   Partially Cancelled (i.e., at least one ticket issued).
--   We exclude fully Cancelled bookings (seat freed).
--
-- We use a subquery to count booked seats per train,
-- then divide by total seats (coaches JOIN seats) to get
-- the occupancy ratio.
-- ============================================================
 
SELECT
    t.train_id,
    t.train_no,
    t.name                                          AS train_name,
    COUNT(DISTINCT s.seat_id)                       AS total_seats,
    COUNT(DISTINCT tk.ticket_id)                    AS booked_seats,
    ROUND(
        COUNT(DISTINCT tk.ticket_id)
        / COUNT(DISTINCT s.seat_id) * 100,
        2
    )                                               AS occupancy_pct
FROM
    trains t
    JOIN coaches c  ON t.train_id  = c.train_id
    JOIN seats   s  ON c.coach_id  = s.coach_id
    LEFT JOIN tickets tk
        ON  s.seat_id = tk.seat_id
        -- Only count tickets from non-cancelled bookings
        AND tk.booking_id IN (
            SELECT booking_id
            FROM   bookings
            WHERE  status <> 'Cancelled'
        )
GROUP BY
    t.train_id,
    t.train_no,
    t.name
ORDER BY
    occupancy_pct DESC;
 
 
-- ============================================================
-- Q4. What is the revenue by train?
--     SUM over payments, GROUP BY
-- ============================================================
--
-- Revenue = sum of payments linked to a train's bookings.
-- We trace: trains → bookings → payments.
-- Cancelled bookings have no payment row, so they naturally
-- contribute 0 (LEFT JOIN returns NULL, SUM ignores NULL).
-- ============================================================
 
SELECT
    t.train_id,
    t.train_no,
    t.name                              AS train_name,
    COUNT(DISTINCT p.payment_id)        AS total_payments,
    COALESCE(SUM(p.amount), 0.00)       AS total_revenue
FROM
    trains t
    JOIN    bookings b  ON t.train_id   = b.train_id
    LEFT JOIN payments p ON b.booking_id = p.booking_id
GROUP BY
    t.train_id,
    t.train_no,
    t.name
ORDER BY
    total_revenue DESC;
