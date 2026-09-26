# stations

* Schema: `stations(station_id, code, name, city)`

# trains

* Schema: `trains(train_id, train_no, name, train_type)`

# train_station

* Schema: `train_station(train_id, station_id, stop_no, arrival_time, departure_time)`

# coaches

* Schema: `coaches(coach_id, train_id, coach_no, class_type)`

# seats

* Schema: `seats(seat_id, coach_id, seat_no, berth_type)`

# passengers

* Schema: `passengers(passenger_id, name, age, gender, phone)`

# bookings

* Schema: `bookings(booking_id, train_id, from_station_id, to_station_id, journey_date, status)`

# tickets

* Schema: `tickets(ticket_id, booking_id, passenger_id, seat_id, journey_date, fare)`

# payments

* Schema: `payments(payment_id, booking_id, amount, method, paid_on)`

# cancellations

* Schema: `cancellations(cancellation_id, ticket_id, cancelled_on, refund_amount)`
