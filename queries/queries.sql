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


