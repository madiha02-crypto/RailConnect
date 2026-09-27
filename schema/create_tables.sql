
-- ============================================================
-- RAILCONNECT
-- SQL DATABASE IMPLEMENTATION
-- Member 4: Database Implementation + Constraints
-- MySQL 8.0+
-- ============================================================

-- ============================================================
-- 1. CREATE DATABASE
-- ============================================================

DROP DATABASE IF EXISTS RailConnect;

CREATE DATABASE RailConnect;

USE RailConnect;


-- ============================================================
-- 2. STATIONS
-- stations(station_id, code, name, city)
-- PK: station_id
-- CK: code UNIQUE
-- ============================================================

CREATE TABLE stations (
    station_id INT NOT NULL AUTO_INCREMENT,
    code VARCHAR(10) NOT NULL,
    name VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,

    PRIMARY KEY (station_id),

    CONSTRAINT uq_stations_code
        UNIQUE (code)
) ENGINE = InnoDB;


-- ============================================================
-- 3. TRAINS
-- trains(train_id, train_no, name, train_type)
-- PK: train_id
-- CK: train_no UNIQUE
-- ============================================================

CREATE TABLE trains (
    train_id INT NOT NULL AUTO_INCREMENT,
    train_no VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    train_type VARCHAR(30) NOT NULL,

    PRIMARY KEY (train_id),

    CONSTRAINT uq_trains_train_no
        UNIQUE (train_no),

    CONSTRAINT chk_trains_train_type
        CHECK (
            train_type IN (
                'Superfast',
                'Express',
                'Passenger',
                'Mail',
                'Vande Bharat'
            )
        )
) ENGINE = InnoDB;

-- ============================================================
-- 4. TRAIN_STATION
-- train_station(
--     train_id,
--     station_id,
--     stop_no,
--     arrival_time,
--     departure_time
-- )
--
-- PK: (train_id, station_id)
-- CK: (train_id, stop_no)
-- ============================================================

CREATE TABLE train_station (
    train_id INT NOT NULL,
    station_id INT NOT NULL,
    stop_no INT NOT NULL,
    arrival_time TIME NOT NULL,
    departure_time TIME NOT NULL,

    PRIMARY KEY (train_id, station_id),

    CONSTRAINT uq_train_station_stop
        UNIQUE (train_id, stop_no),

    CONSTRAINT fk_train_station_train
        FOREIGN KEY (train_id)
        REFERENCES trains(train_id),

    CONSTRAINT fk_train_station_station
        FOREIGN KEY (station_id)
        REFERENCES stations(station_id),

    CONSTRAINT chk_train_station_stop_no
        CHECK (stop_no > 0),

    CONSTRAINT chk_train_station_times
        CHECK (departure_time >= arrival_time)
) ENGINE = InnoDB;
-- ============================================================
-- 5. COACHES
-- coaches(coach_id, train_id, coach_no, class_type)
-- PK: coach_id
-- CK: (train_id, coach_no)
-- FK: train_id -> trains(train_id)
-- ON DELETE CASCADE
-- ============================================================

CREATE TABLE coaches (
    coach_id INT NOT NULL AUTO_INCREMENT,
    train_id INT NOT NULL,
    coach_no VARCHAR(20) NOT NULL,
    class_type VARCHAR(10) NOT NULL,

    PRIMARY KEY (coach_id),

    CONSTRAINT uq_coaches_train_coach
        UNIQUE (train_id, coach_no),

    CONSTRAINT fk_coaches_train
        FOREIGN KEY (train_id)
        REFERENCES trains(train_id)
        ON DELETE CASCADE,

    CONSTRAINT chk_coaches_class_type
        CHECK (
            class_type IN (
                '1A',
                '2A',
                '3A',
                'SL',
                'CC',
                '2S'
            )
        )
) ENGINE = InnoDB;


-- ============================================================
-- 6. SEATS
-- seats(seat_id, coach_id, seat_no, berth_type)
-- PK: seat_id
-- CK: (coach_id, seat_no)
-- FK: coach_id -> coaches(coach_id)
-- ON DELETE CASCADE
-- ============================================================

CREATE TABLE seats (
    seat_id INT NOT NULL AUTO_INCREMENT,
    coach_id INT NOT NULL,
    seat_no INT NOT NULL,
    berth_type VARCHAR(20) NOT NULL,

    PRIMARY KEY (seat_id),

    CONSTRAINT uq_seats_coach_seat
        UNIQUE (coach_id, seat_no),

    CONSTRAINT fk_seats_coach
        FOREIGN KEY (coach_id)
        REFERENCES coaches(coach_id)
        ON DELETE CASCADE,

    CONSTRAINT chk_seats_berth_type
        CHECK (
            berth_type IN (
                'Lower',
                'Middle',
                'Upper',
                'Side Lower',
                'Side Upper',
                'Window'
            )
        ),

    CONSTRAINT chk_seats_seat_no
        CHECK (seat_no > 0)
) ENGINE = InnoDB;
-- ============================================================
-- 7. PASSENGERS
-- passengers(passenger_id, name, age, gender, phone)
-- PK: passenger_id
-- ============================================================

CREATE TABLE passengers (
    passenger_id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    age INT NOT NULL,
    gender VARCHAR(10) NOT NULL,
    phone VARCHAR(15) NOT NULL,

    PRIMARY KEY (passenger_id),

    CONSTRAINT chk_passengers_age
        CHECK (age BETWEEN 1 AND 120),

    CONSTRAINT chk_passengers_gender
        CHECK (
            gender IN (
                'Male',
                'Female',
                'Other'
            )
        )
) ENGINE = InnoDB;


-- ============================================================
-- 8. BOOKINGS
-- bookings(
--     booking_id,
--     train_id,
--     from_station_id,
--     to_station_id,
--     journey_date,
--     status
-- )
-- PK: booking_id
-- ============================================================

CREATE TABLE bookings (
    booking_id INT NOT NULL AUTO_INCREMENT,
    train_id INT NOT NULL,
    from_station_id INT NOT NULL,
    to_station_id INT NOT NULL,
    journey_date DATE NOT NULL,
    status VARCHAR(30) NOT NULL,

    PRIMARY KEY (booking_id),

    CONSTRAINT fk_bookings_train
        FOREIGN KEY (train_id)
        REFERENCES trains(train_id),

    CONSTRAINT fk_bookings_from_station
        FOREIGN KEY (from_station_id)
        REFERENCES stations(station_id),

    CONSTRAINT fk_bookings_to_station
        FOREIGN KEY (to_station_id)
        REFERENCES stations(station_id),

    CONSTRAINT chk_bookings_different_stations
        CHECK (from_station_id <> to_station_id),

    CONSTRAINT chk_bookings_status
        CHECK (
            status IN (
                'Confirmed',
                'Partially Cancelled',
                'Cancelled'
            )
        )
) ENGINE = InnoDB;
-- ============================================================
-- 9. TICKETS
-- tickets(
--     ticket_id,
--     booking_id,
--     passenger_id,
--     seat_id,
--     journey_date,
--     fare
-- )
--
-- PK: ticket_id
-- CK: (seat_id, journey_date)
-- ============================================================

CREATE TABLE tickets (
    ticket_id INT NOT NULL AUTO_INCREMENT,
    booking_id INT NOT NULL,
    passenger_id INT NOT NULL,
    seat_id INT NOT NULL,
    journey_date DATE NOT NULL,
    fare DECIMAL(10,2) NOT NULL,

    PRIMARY KEY (ticket_id),

    CONSTRAINT uq_tickets_seat_journey
        UNIQUE (seat_id, journey_date),

    CONSTRAINT fk_tickets_booking
        FOREIGN KEY (booking_id)
        REFERENCES bookings(booking_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_tickets_passenger
        FOREIGN KEY (passenger_id)
        REFERENCES passengers(passenger_id),

    CONSTRAINT fk_tickets_seat
        FOREIGN KEY (seat_id)
        REFERENCES seats(seat_id),

    CONSTRAINT chk_tickets_fare
        CHECK (fare >= 0.00)
) ENGINE = InnoDB;


-- ============================================================
-- 10. PAYMENTS
-- payments(payment_id, booking_id, amount, method, paid_on)
-- PK: payment_id
-- FK: booking_id -> bookings(booking_id)
-- ON DELETE RESTRICT
-- ============================================================

CREATE TABLE payments (
    payment_id INT NOT NULL AUTO_INCREMENT,
    booking_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    method VARCHAR(20) NOT NULL,
    paid_on DATETIME NOT NULL,

    PRIMARY KEY (payment_id),

    CONSTRAINT fk_payments_booking
        FOREIGN KEY (booking_id)
        REFERENCES bookings(booking_id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_payments_amount
        CHECK (amount > 0.00),

    CONSTRAINT chk_payments_method
        CHECK (
            method IN (
                'UPI',
                'Credit Card',
                'Debit Card',
                'Net Banking'
            )
        )
) ENGINE = InnoDB;
-- ============================================================
-- 11. CANCELLATIONS
-- cancellations(
--     cancellation_id,
--     ticket_id,
--     cancelled_on,
--     refund_amount
-- )
-- PK: cancellation_id
-- CK: ticket_id UNIQUE
-- FK: ticket_id -> tickets(ticket_id)
-- ON DELETE RESTRICT
-- ============================================================

CREATE TABLE cancellations (
    cancellation_id INT NOT NULL AUTO_INCREMENT,
    ticket_id INT NOT NULL,
    cancelled_on DATETIME NOT NULL,
    refund_amount DECIMAL(10,2) NOT NULL,

    PRIMARY KEY (cancellation_id),

    CONSTRAINT uq_cancellations_ticket
        UNIQUE (ticket_id),

    CONSTRAINT fk_cancellations_ticket
        FOREIGN KEY (ticket_id)
        REFERENCES tickets(ticket_id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_cancellations_refund
        CHECK (refund_amount >= 0.00)
) ENGINE = InnoDB;

SHOW TABLES;
