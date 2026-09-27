
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

