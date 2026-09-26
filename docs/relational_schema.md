# stations

* Schema: `stations(station_id, code, name, city)`
* Primary Key (PK): `station_id`
* Candidate Key (CK): `code` UNIQUE

# trains

* Schema: `trains(train_id, train_no, name, train_type)`
* Primary Key (PK): `train_id`
* Candidate Key (CK): `train_no`

# train_station

* Schema: `train_station(train_id, station_id, stop_no, arrival_time, departure_time)`
* Primary Key (PK): `(train_id, station_id)`
* Candidate Key (CK): `(train_id, stop_no)`

# coaches

* Schema: `coaches(coach_id, train_id, coach_no, class_type)`
* Primary Key (PK): `coach_id`
* Candidate Key (CK): `(train_id, coach_no)`

# seats

* Schema: `seats(seat_id, coach_id, seat_no, berth_type)`
* Primary Key (PK): `seat_id`
* Candidate Key (CK): `(coach_id, seat_no)`

# passengers

* Schema: `passengers(passenger_id, name, age, gender, phone)`
* Primary Key (PK): `passenger_id`

# bookings

* Schema: `bookings(booking_id, train_id, from_station_id, to_station_id, journey_date, status)`
* Primary Key (PK): `booking_id`

# tickets

* Schema: `tickets(ticket_id, booking_id, passenger_id, seat_id, journey_date, fare)`
* Primary Key (PK): `ticket_id`
* Candidate Key (CK): `(seat_id, journey_date)` UNIQUE

# payments

* Schema: `payments(payment_id, booking_id, amount, method, paid_on)`
* Primary Key (PK): `payment_id`

# cancellations

* Schema: `cancellations(cancellation_id, ticket_id, cancelled_on, refund_amount)`
* Primary Key (PK): `cancellation_id`
* Candidate Key (CK): `ticket_id` UNIQUE
