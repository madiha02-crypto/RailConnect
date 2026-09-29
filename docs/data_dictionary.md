## Data Dictionary — RailConnect

Source of truth: schema/create_tables.sql. Every column, key and named constraint below is documented exactly as declared in the DDL

## Schema at a Glance

Item	                    Value

Tables	                    10

Columns	                    47

Primary keys	            10 (1 composite — train_station)

Foreign keys	            12

UNIQUE constraints	        7

CHECK constraints	        14

Named constraints (total)	43

Nullable columns	        0 — every column is NOT NULL

Storage engine	            InnoDB


#	Table , Columns	, Role

1	stations	    4	    Master data

2	trains	        4	    Master data

3	train_station	5	    Route junction (M:N)

4	coaches	        4	    Train inventory

5	seats	        4	    Train inventory

6	passengers	    5	    Master data

7	bookings	    6	    Operations — the hub

8	tickets	        6	    Operations

9	payments	    5	    Financial history

10	cancellations	4	    Financial history

## Table Reference

## 1) stations
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `station_id` | INT | PK, AUTO_INCREMENT | Surrogate identifier |
| `code` | VARCHAR(10) | UNIQUE (uq_stations_code) | Short station code (e.g. SBC) |
| `name` | VARCHAR(100) | — | Full station name |
| `city` | VARCHAR(100) | — | City the station lies |
## 2) trains
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `train_id` | INT | PK, AUTO_INCREMENT | Surrogate identifier |
| `train_no` | VARCHAR(20) | UNIQUE (uq_trains_train_no) | Public-facing train number |
| `name` | VARCHAR(100) | — | Train name (e.g. Karnataka Express) |
| `train_type` | VARCHAR(30) | CHECK (chk_trains_train_type) | Category — allowed values in Constraints Catalog|
## 3) train_station
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `train_id` | INT | PK (composite), FK → trains | The train on this route |
| `station_id` | INT | PK (composite), FK → stations | The station it halts at |
| `stop_no` | INT | UNIQUE with train_id (uq_train_station_stop), CHECK (chk_train_station_stop_no) | Position in the route, 1…n |
| `arrival_time` | TIME | CHECK (chk_train_station_times) | Arrival at this stop |
| `departure_time` | TIME | CHECK (chk_train_station_times) | Departure from this stop |
## 4)coaches
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `coach_id` | INT | PK, AUTO_INCREMENT | Surrogate identifier |
| `train_id` | INT | FK → trains (CASCADE), UNIQUE with coach_no (uq_coaches_train_coach) | Owning train |
| `coach_no` | VARCHAR(20) | UNIQUE with train_id | Coach label (e.g. B1, S4) |
| `class_type` | VARCHAR(10) | CHECK (chk_coaches_class_type) | Travel class — allowed values in Constraints Catalog |
## 5) seats
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `seat_id` | INT | PK, AUTO_INCREMENT | Surrogate identifier |
| `coach_id` | INT | FK → coaches (CASCADE), UNIQUE with seat_no (uq_seats_coach_seat) | Owning coach |
| `seat_no` | INT | CHECK (chk_seats_seat_no) | Seat number within the coach |
| `berth_type` | VARCHAR(20) | CHECK (chk_seats_berth_type) | Berth position — allowed values in Constraints Catalog |
## 6) passengers
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `passenger_id` | INT | PK, AUTO_INCREMENT | Surrogate identifier |
| `name` | VARCHAR(100) | — | Passenger's full name |
| `age` | INT | CHECK (chk_passengers_age) | Age in years (1–120) |
| `gender` | VARCHAR(10) | CHECK (chk_passengers_gender) | Allowed values in Constraints Catalog |
| `phone` | VARCHAR(15) | — | Contact number |
## 7) booking
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `booking_id` | INT | PK, AUTO_INCREMENT | Surrogate identifier |
| `train_id` | INT | FK → trains | Train travelled on |
| `from_station_id` | INT | FK → stations | Boarding station |
| `to_station_id` | INT | FK → stations | Destination station |
| `journey_date` | DATE | — | Date of travel |
| `status` | VARCHAR(30) | CHECK (chk_bookings_status) | Lifecycle — allowed values in Constraints Catalog|
## 8) tickets
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `ticket_id` | INT | PK, AUTO_INCREMENT | Surrogate identifier |
| `booking_id` | INT | FK → bookings (CASCADE) | The reservation this ticket belongs to |
| `passenger_id` | INT | FK → passengers | Who travels |
| `seat_id` | INT | FK → seats, UNIQUE with journey_date  | The allotted seat |
| `journey_date` | DATE | UNIQUE with seat_id (uq_tickets_seat_journey) | Date of travel (mirrors bookings.journey_date) |
| `fare` | DECIMAL(10,2) | CHECK (chk_tickets_fare) | Fare charged for this seat |
## 9) payments
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `payment_id` | INT | PK, AUTO_INCREMENT | Surrogate identifier |
| `booking_id` | INT | FK → bookings (RESTRICT) | The booking being paid for |
| `amount` | DECIMAL(10,2) | CHECK (chk_payments_amount) | Amount paid (strictly > 0) |
| `method` | VARCHAR(20) | CHECK (chk_payments_method) | Payment channel — allowed values in Constraints Catalog |
| `paid_on` | DATETIME | — | Payment timestamp |
## 10) cancellations
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `cancellation_id` | INT | PK, AUTO_INCREMENT | Surrogate identifier |
| `ticket_id` | INT | UNIQUE (uq_cancellations_ticket), FK → tickets (RESTRICT) | The cancelled ticket |
| `cancelled_on` | DATETIME | — | Cancellation timestamp |
| `refund_amount` | DECIMAL(10,2) | CHECK (chk_cancellations_refund) | Refund issued (≥ 0) |

## Constraint Catalog
All 12 foreign keys, their referential actions and the policy behind them are documented in 05-integrity-constraints.md.

| Domain | Column | Allowed values |
| :--- | :--- | :--- |
| Train type | `trains.train_type` | Superfast · Express · Passenger · Mail · Vande Bharat |
| Coach class | `coaches.class_type` | 1A · 2A · 3A · SL · CC · 2S |
| Berth type | `seats.berth_type` | Lower · Middle · Upper · Side Lower · Side Upper · Window |
| Gender | `passengers.gender` | Male · Female · Other |
| Booking status | `bookings.status` | Confirmed · Partially Cancelled · Cancelled |
| Payment method | `payments.method` | UPI · Credit Card · Debit Card · Net Banking |


| Constraint | Rule |
| :--- | :--- |
| `chk_train_station_stop_no` | `stop_no > 0` |
| `chk_train_station_times` | `departure_time >= arrival_time` (equality allowed — first/last stops) |
| `chk_seats_seat_no` | `seat_no > 0` |
| `chk_passengers_age` | `age BETWEEN 1 AND 120` |
| `chk_bookings_different_stations` | `from_station_id <> to_station_id` |
| `chk_tickets_fare` | `fare >= 0.00` |
| `chk_payments_amount` | `amount > 0.00` |
| `chk_cancellations_refund` | `refund_amount >= 0.00` |

