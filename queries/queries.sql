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

-- ============================================================
-- Q5. What is the cancellation rate?
--     Conditional aggregation using CASE
-- ============================================================
--
-- Cancellation rate = cancelled bookings / total bookings.
-- We treat 'Cancelled' and 'Partially Cancelled' separately.
-- Using CASE inside SUM is the conditional aggregation the
-- PRD specifically asks for.
-- ============================================================
 
SELECT
    COUNT(booking_id)                                           AS total_bookings,
 
    SUM(CASE WHEN status = 'Cancelled'           THEN 1 ELSE 0 END)
                                                                AS fully_cancelled,
 
    SUM(CASE WHEN status = 'Partially Cancelled' THEN 1 ELSE 0 END)
                                                                AS partially_cancelled,
 
    SUM(CASE WHEN status = 'Confirmed'           THEN 1 ELSE 0 END)
                                                                AS confirmed,
 
    ROUND(
        SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END)
        / COUNT(booking_id) * 100,
        2
    )                                                           AS full_cancellation_rate_pct,
 
    ROUND(
        SUM(CASE WHEN status IN ('Cancelled', 'Partially Cancelled') THEN 1 ELSE 0 END)
        / COUNT(booking_id) * 100,
        2
    )                                                           AS any_cancellation_rate_pct
 
FROM
    bookings;
 
 
-- ============================================================
-- Q6. What is the average fare by route?
--     AVG, GROUP BY route
-- ============================================================
--
-- Route = (from_station, to_station) pair.
-- Fare comes from tickets; we join up through bookings to get
-- the route, then average the fare per route.
-- ============================================================
 
SELECT
    s_from.name                         AS from_station,
    s_from.city                         AS from_city,
    s_to.name                           AS to_station,
    s_to.city                           AS to_city,
    COUNT(tk.ticket_id)                 AS tickets_sold,
    ROUND(AVG(tk.fare), 2)              AS avg_fare
FROM
    tickets  tk
    JOIN bookings b  ON tk.booking_id       = b.booking_id
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
    avg_fare DESC;
 
 
-- ============================================================
-- Q7. Which passengers have multiple bookings?
--     GROUP BY, HAVING COUNT > 1
-- ============================================================
--
-- We trace passengers → tickets → bookings to count how many
-- distinct bookings each passenger appears in.
-- HAVING filters to only those with more than one booking.
-- ============================================================
 
SELECT
    p.passenger_id,
    p.name                              AS passenger_name,
    p.age,
    p.gender,
    COUNT(DISTINCT tk.booking_id)       AS total_bookings
FROM
    passengers p
    JOIN tickets tk ON p.passenger_id = tk.passenger_id
GROUP BY
    p.passenger_id,
    p.name,
    p.age,
    p.gender
HAVING
    COUNT(DISTINCT tk.booking_id) > 1
ORDER BY
    total_bookings DESC;

-- ============================================================
-- Q8. Which coach class generates the most revenue,
--     and what is its share of total revenue?
--     Window function, derived table, ROUND
-- ============================================================
--
-- Q4 breaks revenue by train. This goes deeper: by coach
-- class across the entire network. We need to know not just
-- which class earns most, but what percentage of total
-- revenue it contributes — so a window function computes
-- the grand total alongside each row without a separate query.
--
-- Path: tickets (fare + seat_id)
--         → seats (seat_id → coach_id)
--         → coaches (coach_id → class_type)
-- We exclude cancelled bookings (no payment was made).
-- ============================================================
 
SELECT
    c.class_type,
    COUNT(tk.ticket_id)                         AS tickets_sold,
    ROUND(SUM(tk.fare), 2)                      AS class_revenue,
    ROUND(AVG(tk.fare), 2)                      AS avg_fare_per_ticket,
    ROUND(
        SUM(tk.fare)
        / SUM(SUM(tk.fare)) OVER () * 100,
        2
    )                                           AS revenue_share_pct
FROM
    tickets  tk
    JOIN seats   s  ON tk.seat_id  = s.seat_id
    JOIN coaches c  ON s.coach_id  = c.coach_id
    JOIN bookings b ON tk.booking_id = b.booking_id
WHERE
    b.status <> 'Cancelled'
GROUP BY
    c.class_type
ORDER BY
    class_revenue DESC;
 
 
-- ============================================================
-- Q9. For each train, on which journey date was revenue
--     the highest? (Peak revenue date per train)
--     CTE + ROW_NUMBER() window function
-- ============================================================
--
-- None of Q1–Q7 look at the time dimension of revenue.
-- This identifies each train's single best-performing date —
-- useful for understanding demand peaks and scheduling.
--
-- Approach:
--   Step 1 (CTE daily_revenue): sum payments per train per date.
--   Step 2 (CTE ranked): assign ROW_NUMBER() within each train,
--           ordered by revenue descending.
--   Step 3: filter to rank = 1 to get only the peak date.
-- ============================================================
 
WITH daily_revenue AS (
    SELECT
        t.train_id,
        t.train_no,
        t.name                          AS train_name,
        b.journey_date,
        SUM(p.amount)                   AS day_revenue,
        COUNT(DISTINCT b.booking_id)    AS bookings_on_day
    FROM
        trains   t
        JOIN bookings  b ON t.train_id   = b.train_id
        JOIN payments  p ON b.booking_id = p.booking_id
    GROUP BY
        t.train_id,
        t.train_no,
        t.name,
        b.journey_date
),
ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY train_id
            ORDER BY day_revenue DESC
        )                               AS rnk
    FROM
        daily_revenue
)
SELECT
    train_id,
    train_no,
    train_name,
    journey_date                        AS peak_date,
    ROUND(day_revenue, 2)               AS peak_revenue,
    bookings_on_day
FROM
    ranked
WHERE
    rnk = 1
ORDER BY
    peak_revenue DESC;
 
============================================================
-- Q10. What is the refund efficiency by train?
--      i.e., what percentage of collected revenue was
--      paid back as refunds due to cancellations?
--      Multi-table aggregation, COALESCE, derived tables
-- ============================================================
--
-- No existing query connects payments and cancellations
-- together at the train level. This is operationally critical:
-- a train with high revenue but also high refund outflow is
-- a net risk.
--
-- collected_revenue : SUM of payments for that train's bookings
-- total_refunds     : SUM of refund_amount from cancellations
--                     linked back through tickets → bookings → train
-- refund_rate_pct   : total_refunds / collected_revenue × 100
--
-- We use two separate aggregation subqueries joined on train_id
-- so that the revenue and refund sums don't cross-multiply.
-- ============================================================
 
SELECT
    t.train_id,
    t.train_no,
    t.name                                      AS train_name,
    ROUND(COALESCE(rev.collected_revenue, 0), 2) AS collected_revenue,
    ROUND(COALESCE(ref.total_refunds,     0), 2) AS total_refunds,
    ROUND(
        COALESCE(ref.total_refunds, 0)
        / NULLIF(COALESCE(rev.collected_revenue, 0), 0) * 100,
        2
    )                                           AS refund_rate_pct
FROM
    trains t
    -- Revenue side
    LEFT JOIN (
        SELECT
            b.train_id,
            SUM(p.amount)   AS collected_revenue
        FROM
            bookings b
            JOIN payments p ON b.booking_id = p.booking_id
        GROUP BY
            b.train_id
    ) rev ON t.train_id = rev.train_id
    -- Refund side
    LEFT JOIN (
        SELECT
            b.train_id,
            SUM(cn.refund_amount)   AS total_refunds
        FROM
            cancellations cn
            JOIN tickets  tk ON cn.ticket_id  = tk.ticket_id
            JOIN bookings b  ON tk.booking_id = b.booking_id
        GROUP BY
            b.train_id
    ) ref ON t.train_id = ref.train_id
ORDER BY
    refund_rate_pct DESC;
 
 
-- ============================================================
-- Q11. Which stations are the busiest, measured by total
--      passenger footfall (departures + arrivals combined)?
--      UNION ALL, aggregation over combined sets
-- ============================================================
--
-- Q1 only counts bookings per route pair. This is different:
-- it measures how many passengers pass through each station
-- either as a departure point or an arrival point — total
-- footfall, the way a station manager would think about it.
--
-- We use UNION ALL to treat every booking's from_station
-- and to_station as separate footfall events, then count
-- them together per station. Each side also counts separately
-- so we can see the departure/arrival split.
-- ============================================================
 
SELECT
    s.station_id,
    s.name                                  AS station_name,
    s.city,
    SUM(CASE WHEN f.direction = 'departure' THEN f.cnt ELSE 0 END)
                                            AS departures,
    SUM(CASE WHEN f.direction = 'arrival'   THEN f.cnt ELSE 0 END)
                                            AS arrivals,
    SUM(f.cnt)                              AS total_footfall
FROM
    stations s
    JOIN (
        -- Departing passengers
        SELECT
            from_station_id     AS station_id,
            'departure'         AS direction,
            COUNT(*)            AS cnt
        FROM   bookings
        WHERE  status <> 'Cancelled'
        GROUP BY from_station_id
 
        UNION ALL
 
        -- Arriving passengers
        SELECT
            to_station_id       AS station_id,
            'arrival'           AS direction,
            COUNT(*)            AS cnt
        FROM   bookings
        WHERE  status <> 'Cancelled'
        GROUP BY to_station_id
    ) f ON s.station_id = f.station_id
GROUP BY
    s.station_id,
    s.name,
    s.city
ORDER BY
    total_footfall DESC;
