# stations

* Schema: `stations(station_id, code, name, city)`
* Primary Key (PK): `station_id`
* Candidate Key (CK): `code` UNIQUE
* Integrity Constraints:
  * `station_id` NOT NULL
  * `code` NOT NULL
  * `name` NOT NULL
  * `city` NOT NULL

# trains

* Schema: `trains(train_id, train_no, name, train_type)`
* Primary Key (PK): `train_id`
* Candidate Key (CK): `train_no`
* Integrity Constraints: `train_type` IN `('Superfast', 'Express', 'Passenger', 'Mail', 'Vande Bharat')`

# train_station

* Schema: `train_station(train_id, station_id, stop_no, arrival_time, departure_time)`
* Primary Key (PK): `(train_id, station_id)`
* Candidate Key (CK): `(train_id, stop_no)`
* Foreign Keys (FK):
  * `train_id` references `train(train_id)`
  * `station_id` references `station(station_id)`
* Integrity Constraints:
  * `stop_no` > 0
  * `departure_time` >= `arrival_time`

# coaches

* Schema: `coaches(coach_id, train_id, coach_no, class_type)`
* Primary Key (PK): `coach_id`
* Candidate Key (CK): `(train_id, coach_no)`
* Foreign Key (FK): `train_id` references `trains(train_id)` ON DELETE CASCADE
* Integrity Constraints: `class_type` IN `('1A', '2A', '3A', 'SL', 'CC', '2S')`

# seats

* Schema: `seats(seat_id, coach_id, seat_no, berth_type)`
* Primary Key (PK): `seat_id`
* Candidate Key (CK): `(coach_id, seat_no)`
* Foreign Key (FK): `coach_id` references `coaches(coach_id)` ON DELETE CASCADE
* Integrity Constraints:
  * `berth_type` IN `('Lower', 'Middle', 'Upper', 'Side Lower', 'Side Upper', 'Window')`
  * `seat_no` > 0

# passengers

* Schema: `passengers(passenger_id, name, age, gender, phone)`
* Primary Key (PK): `passenger_id`
* Integrity Constraints:
  * `age` BETWEEN 1 AND 120
  * `gender` IN `('Male', 'Female', 'Other')`
  * `phone` VARCHAR(15) NOT NULL

# bookings

* Schema: `bookings(booking_id, train_id, from_station_id, to_station_id, journey_date, status)`
* Primary Key (PK): `booking_id`
* Foreign Keys (FK):
  * `train_id` references `trains(train_id)`
  * `from_station_id` references `stations(station_id)`
  * `to_station_id` references `stations(station_id)`
* Integrity Constraints:
  * `from_station_id` != `to_station_id`
  * `status` IN `('Confirmed', 'Partially Cancelled', 'Cancelled')`

# tickets

* Schema: `tickets(ticket_id, booking_id, passenger_id, seat_id, journey_date, fare)`
* Primary Key (PK): `ticket_id`
* Candidate Key (CK): `(seat_id, journey_date)` UNIQUE
* Foreign Keys (FK):
  * `booking_id` references `bookings(booking_id)` ON DELETE CASCADE
  * `passenger_id` references `passengers(passenger_id)`
  * `seat_id` references `seats(seat_id)`
* Integrity Constraints: `fare` >= 0.00

# payments

* Schema: `payments(payment_id, booking_id, amount, method, paid_on)`
* Primary Key (PK): `payment_id`
* Foreign Key (FK): `booking_id` references `bookings(booking_id)` ON DELETE RESTRICT
* Integrity Constraints:
  * `amount` > 0.00
  * `method` IN `('UPI', 'Credit Card', 'Debit Card', 'Net Banking')`

# cancellations

* Schema: `cancellations(cancellation_id, ticket_id, cancelled_on, refund_amount)`
* Primary Key (PK): `cancellation_id`
* Candidate Key (CK): `ticket_id` UNIQUE
* Foreign Key (FK): `ticket_id` references `tickets(ticket_id)` ON DELETE RESTRICT
* Integrity Constraints: `refund_amount` >= 0.00
