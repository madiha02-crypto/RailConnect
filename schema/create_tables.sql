
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

