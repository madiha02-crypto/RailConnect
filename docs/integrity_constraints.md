## Integrity Constraints — RailConnect

## Coverage at a Glance

| Constraint type | In use | Count | Detail |
| :--- | :--- | :--- | :--- |
| PRIMARY KEY | ✅ | 10 | every table (one composite — train_station) |
| FOREIGN KEY | ✅ | 12 | §2 |
| NOT NULL | ✅ | 47 / 47 columns | §6 |
| UNIQUE | ✅ | 7 | §3, §4 |
| CHECK | ✅ | 14 | §5 |
| DEFAULT | ✅ | 2 | §7 |
| ON DELETE | ✅ | 12 | 3 CASCADE · 9 RESTRICT — Referential Integrity  |
| ON UPDATE | — | 0 | deliberately none — Referential Integrity  |

Named constraints in total: 43.

## Referential Integrity — the 12 Foreign Keys

| # | Constraint | Child → Parent | ON DELETE |
| :--- | :--- | :--- | :--- |
| 1 | `fk_train_station_train` | `train_station.train_id` → `trains.train_id` | RESTRICT |
| 2 | `fk_train_station_station` | `train_station.station_id` → `stations.station_id` | RESTRICT |
| 3 | `fk_coaches_train` | `coaches.train_id` → `trains.train_id` | CASCADE |
| 4 | `fk_seats_coach` | `seats.coach_id` → `coaches.coach_id` | CASCADE |
| 5 | `fk_bookings_train` | `bookings.train_id` → `trains.train_id` | RESTRICT |
| 6 | `fk_bookings_from_station` | `bookings.from_station_id` → `stations.station_id` | RESTRICT |
| 7 | `fk_bookings_to_station` | `bookings.to_station_id` → `stations.station_id` | RESTRICT |
| 8 | `fk_tickets_booking` | `tickets.booking_id` → `bookings.booking_id` | CASCADE |
| 9 | `fk_tickets_passenger` | `tickets.passenger_id` → `passengers.passenger_id` | RESTRICT |
| 10 | `fk_tickets_seat` | `tickets.seat_id` → `seats.seat_id` | RESTRICT |
| 11 | `fk_payments_booking` | `payments.booking_id` → `bookings.booking_id` | RESTRICT |
| 12 | `fk_cancellations_ticket` | `cancellations.ticket_id` → `tickets.ticket_id` | RESTRICT |

## The delete policy

CASCADE — owned data (3 of 12). A coach without its train, a seat without its coach, a ticket without its booking are meaningless rows. They are removed with their parent

RESTRICT — history (9 of 12). Master data and anything with operational or financial history blocks the deletion of its parent

## UNIQUE Constraints
| Constraint | Table | Guarantees |
| :--- | :--- | :--- |
| `uq_stations_code` | `stations` | Every station code is unique network-wide |
| `uq_trains_train_no` | `trains` | One train per public number |
| `uq_train_station_stop` | `train_station` | A route's stop sequence has no duplicates — `stop_no` is a trustworthy order |
| `uq_coaches_train_coach` | `coaches` | A coach label appears at most once per train (S4 may exist on many trains, but only once on each) |
| `uq_seats_coach_seat` | `seats` | A seat number appears at most once per coach |
| `uq_cancellations_ticket` | `cancellations` | A ticket can be cancelled at most once, ever |
| `uq_tickets_seat_journey` | `tickets` | A seat should not be allotted twice for the same journey date. Mechanism: `UNIQUE (seat_id, journey_date)` |

## CHECK Constraints

| Constraint | Blocks |
| :--- | :--- |
| `chk_train_station_stop_no` | stop numbers of 0 or below — a route starts at stop 1 |
| `chk_train_station_times` | a departure earlier than the arrival at the same stop |
| `chk_seats_seat_no` | seat numbers of 0 or below |
| `chk_passengers_age` | ages outside 1–120 (typos like 250) |
| `chk_bookings_different_stations` | a "journey" from a station to itself |
| `chk_tickets_fare` | negative fares |
| `chk_payments_amount` | zero or negative payments — a payment always moves real money |
| `chk_cancellations_refund` | negative refunds (a zero refund is legitimate — charges can consume the fare) |

## NOT NULL
All 47 columns are NOT NULL. 

## DEFAULT Values
| Column | Default | Meaning |
| :--- | :--- | :--- |
| `bookings.status` | `'Confirmed'` | a new booking is confirmed unless explicitly created otherwise |
| `payments.paid_on` | `CURRENT_TIMESTAMP` | a payment is stamped at the moment it is recorded |

(Defaults are column attributes, not named constraints — they do not count toward the 43.)
