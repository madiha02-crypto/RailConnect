## Requirements & Assumptions — RailConnect

## 1) Functional Requirements

## F1 — Stations, trains & routes

| ID | Requirement |
| :--- | :--- |
| FR1 | The system shall store railway stations, each identified by a code unique across the network. |
| FR2 | The system shall store trains, each with a public train number unique across the network, and a type drawn from a fixed vocabulary (Superfast, Express, Passenger, Mail, Vande Bharat). |
| FR3 | The system shall store each train's route as an ordered sequence of stops with arrival and departure times — a station appearing at most once per route, stop numbers strictly positive and unique within the route, and no departure earlier than the arrival at the same stop. |

## F2 — Coach & seat inventory

| ID | Requirement |
| :--- | :--- |
| FR4 | The system shall model the coaches attached to each train, with coach labels unique within a train and a travel class drawn from a fixed vocabulary (1A, 2A, 3A, SL, CC, 2S). |
| FR5 | The system shall model the seats within each coach, with seat numbers strictly positive and unique within the coach, and a berth type drawn from a fixed vocabulary. |

## F3 — Passengers & bookings

| ID | Requirement |
| :--- | :--- |
| FR6 | The system shall register passengers with a name, an age within 1–120, and a gender from a fixed vocabulary. |
| FR7 | The system shall record bookings — each referencing one train, a boarding and a destination station that must differ, a journey date, and a status drawn from the three-state lifecycle (Confirmed, Partially Cancelled, Cancelled). |

## F4 — Tickets & seat allocation

| ID | Requirement |
| :--- | :--- |
| FR8 | The system shall issue one ticket per passenger within a booking, each ticket referencing its booking, its passenger, and an allotted seat, with a fare recorded at booking time. |
| FR9 | ⭐ The system shall never allot the same seat twice for the same train and journey date — the project's core business rule, enforced by the database engine itself. |
| FR10 | The system shall reject negative fares. |

## F5 — Payments

| ID | Requirement |
| :--- | :--- |
| FR11 | The system shall record payments against bookings — each with a strictly positive amount, a method from a fixed vocabulary (UPI, Credit Card, Debit Card, Net Banking), and a payment timestamp. |

## F6 — Cancellations & refunds

ID	Requirement
FR12	The system shall process cancellations of tickets, recording the cancellation timestamp and a refund amount — a ticket can be cancelled at most once, and refunds can never be negative.

## Cross-cutting

| ID | Requirement |
| :--- | :--- |
| FR13 | The system shall enforce referential integrity: no row may reference a parent row that does not exist, across all twelve foreign-key relationships. |
| FR14 | The system shall protect financial history: a booking that has been paid, and a ticket that has been cancelled, can never be deleted. |

## 2) Traceability — Requirement → Constraint

| FR | Enforced by |
| :--- | :--- |
| FR1 | `uq_stations_code` |
| FR2 | `uq_trains_train_no` · `chk_trains_train_type` |
| FR3 | PK (`train_id`, `station_id`) · `uq_train_station_stop` · `chk_train_station_stop_no` · `chk_train_station_times` |
| FR4 | `uq_coaches_train_coach` · `chk_coaches_class_type` |
| FR5 | `uq_seats_coach_seat` · `chk_seats_seat_no` · `chk_seats_berth_type` |
| FR6 | `chk_passengers_age` · `chk_passengers_gender` |
| FR7 | `fk_bookings_train` · `fk_bookings_from_station` · `fk_bookings_to_station` · `chk_bookings_different_stations` · `chk_bookings_status` |
| FR8 | `fk_tickets_booking` · `fk_tickets_passenger` · `fk_tickets_seat` |
| FR9 | ⭐ `uq_tickets_seat_journey` |
| FR10 | `chk_tickets_fare` |
| FR11 | `chk_payments_amount` · `chk_payments_method` · `fk_payments_booking` |
| FR12 | `uq_cancellations_ticket` · `chk_cancellations_refund` |
| FR13 | all twelve `fk_*` constraints |
| FR14 | `fk_payments_booking` (RESTRICT) · `fk_cancellations_ticket` (RESTRICT) |

## 3) Assumptions

| ID | Assumption | Consequence in the design |
| :--- | :--- | :--- |
| A1 | A booking covers exactly one train, one journey date, and one origin–destination pair | `bookings` shape; multi-leg journeys excluded (see 11, E5) |
| A2 | A train's route and timings are the same every running day — timetables are date-independent | `train_station` carries no date dimension; day-of-week scheduling is not modelled |
| A3 | Seats are allotted at booking time; there is no waitlist or RAC | the three-state status lifecycle; no queue tables |
| A4 | A booking's lifecycle is exactly Confirmed, Partially Cancelled, or Cancelled | `chk_bookings_status` vocabulary |
| A5 | Fare belongs to the ticket, not the booking — passengers in one booking may travel in different classes | fare lives on `tickets`, fixed at booking time |
| A6 | A ticket's journey date mirrors its booking's journey date | deliberate redundancy that makes FR9 expressible as a single-table UNIQUE (documented deviation, `06`) |
| A7 | A seat determines its train transitively (`seat` → `coach` → `train`) | the FR9 constraint needs only (`seat_id`, `journey_date`) — no `train` column in `tickets` |
| A8 | A phone number is not a unique identifier — family members commonly share one | `phone` is NOT NULL but deliberately not UNIQUE |
| A9 | Zero-fare tickets are legitimate (child or complimentary); payments always move real money | `chk_tickets_fare` allows 0, `chk_payments_amount` requires > 0 |
| A10 | A refund may be zero (cancellation charges consume the fare) but never negative | `chk_cancellations_refund` |
| A11 | Stop times are same-day clock times; multi-day chronology is not modelled | `TIME` columns; recorded as limitation L7 |
| A12 | All monetary amounts are in INR | |

## 4) Deviations from the PRD's Suggested Tables

| Change | Reasoning |
| :--- | :--- |
| `tickets` gained a `journey_date` column | required to enforce FR9 — the no-double-booking rule cannot be expressed as a UNIQUE across tables. Full reasoning is recorded as a design decision in `07-design-rationale.md` |
| `train_stations` renamed to `train_station` | naming consistency — every other table in the schema is singular |

No tables were added, removed, or restructured beyond these.


