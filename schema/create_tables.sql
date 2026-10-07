-- ============================================================
-- RAILCONNECT - DATABASE AND TABLE CREATION
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
-- ============================================================


CREATE TABLE stations (
    station_id INT NOT NULL AUTO_INCREMENT,
    code VARCHAR(10) NOT NULL,
    name VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,

    CONSTRAINT pk_stations
        PRIMARY KEY (station_id),

    CONSTRAINT uq_stations_code
        UNIQUE (code)
);


-- ============================================================
-- 3. TRAINS
-- ============================================================

CREATE TABLE trains (
    train_id INT NOT NULL AUTO_INCREMENT,
    train_no VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    train_type VARCHAR(30) NOT NULL,

    CONSTRAINT pk_trains
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
);


-- ============================================================
-- 4. TRAIN_STATIONS
-- ============================================================

CREATE TABLE train_stations (
    train_id INT NOT NULL,
    station_id INT NOT NULL,
    stop_no INT NOT NULL,
    arrival_time TIME NOT NULL,
    departure_time TIME NOT NULL,

    CONSTRAINT pk_train_stations
        PRIMARY KEY (train_id, station_id),

    CONSTRAINT uq_train_stations_stop
        UNIQUE (train_id, stop_no),

    CONSTRAINT fk_train_stations_train
        FOREIGN KEY (train_id)
        REFERENCES trains(train_id),

    CONSTRAINT fk_train_stations_station
        FOREIGN KEY (station_id)
        REFERENCES stations(station_id),

    CONSTRAINT chk_train_stations_stop_no
        CHECK (stop_no > 0),

    CONSTRAINT chk_train_stations_times
        CHECK (departure_time >= arrival_time)
);


-- ============================================================
-- 5. COACHES
-- ============================================================

CREATE TABLE coaches (
    coach_id INT NOT NULL AUTO_INCREMENT,
    train_id INT NOT NULL,
    coach_no VARCHAR(20) NOT NULL,
    class_type VARCHAR(10) NOT NULL,

    CONSTRAINT pk_coaches
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
);


-- ============================================================
-- 6. SEATS
-- ============================================================

CREATE TABLE seats (
    seat_id INT NOT NULL AUTO_INCREMENT,
    coach_id INT NOT NULL,
    seat_no INT NOT NULL,
    berth_type VARCHAR(20) NOT NULL,

    CONSTRAINT pk_seats
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
);


-- ============================================================
-- 7. PASSENGERS
-- ============================================================

CREATE TABLE passengers (
    passenger_id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    age INT NOT NULL,
    gender VARCHAR(10) NOT NULL,
    phone VARCHAR(15) NOT NULL,

    CONSTRAINT pk_passengers
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
);


-- ============================================================
-- 8. BOOKINGS
-- ============================================================

CREATE TABLE bookings (
    booking_id INT NOT NULL AUTO_INCREMENT,
    train_id INT NOT NULL,
    from_station_id INT NOT NULL,
    to_station_id INT NOT NULL,
    journey_date DATE NOT NULL,
    status VARCHAR(30) NOT NULL,

    CONSTRAINT pk_bookings
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
);


-- ============================================================
-- 9. TICKETS
-- ============================================================

CREATE TABLE tickets (
    ticket_id INT NOT NULL AUTO_INCREMENT,
    booking_id INT NOT NULL,
    passenger_id INT NOT NULL,
    seat_id INT NOT NULL,
    fare DECIMAL(10,2) NOT NULL,

    CONSTRAINT pk_tickets
        PRIMARY KEY (ticket_id),

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
);


-- ============================================================
-- 10. PAYMENTS
-- ============================================================

CREATE TABLE payments (
    payment_id INT NOT NULL AUTO_INCREMENT,
    booking_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    method VARCHAR(20) NOT NULL,
    paid_on DATETIME NOT NULL,

    CONSTRAINT pk_payments
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
);


-- ============================================================
-- 11. CANCELLATIONS
-- ============================================================

CREATE TABLE cancellations (
    cancellation_id INT NOT NULL AUTO_INCREMENT,
    ticket_id INT NOT NULL,
    cancelled_on DATETIME NOT NULL,
    refund_amount DECIMAL(10,2) NOT NULL,

    CONSTRAINT pk_cancellations
        PRIMARY KEY (cancellation_id),

    CONSTRAINT uq_cancellations_ticket
        UNIQUE (ticket_id),

    CONSTRAINT fk_cancellations_ticket
        FOREIGN KEY (ticket_id)
        REFERENCES tickets(ticket_id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_cancellations_refund
        CHECK (refund_amount >= 0.00)
);


-- ============================================================
-- 12. CHECK ALL TABLES
-- ============================================================

SHOW TABLES;


-- ============================================================
-- 13. CHECK TABLE STRUCTURES
-- ============================================================

DESCRIBE stations;
DESCRIBE trains;
DESCRIBE train_stations;
DESCRIBE coaches;
DESCRIBE seats;
DESCRIBE passengers;
DESCRIBE bookings;
DESCRIBE tickets;
DESCRIBE payments;
DESCRIBE cancellations;
