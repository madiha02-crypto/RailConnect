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

| ID	 | Requirement |
| :--- | :--- |
| FR12 |	The system shall process cancellations of tickets, recording the cancellation timestamp and a refund amount — a ticket can be cancelled at most once, and refunds can never be negative. |

## Cross-cutting

| ID | Requirement |
| :--- | :--- |
| FR13 | The system shall enforce referential integrity: no row may reference a parent row that does not exist, across all twelve foreign-key relationships. |
| FR14 | The system shall protect financial history: a booking that has been paid, and a ticket that has been cancelled, can never be deleted. |


## 2) Assumptions

| ID | Assumption |
| :--- | :--- |
| A1 | A booking covers exactly one train, one journey date, and one origin–destination pair 
| A2 | A train's route and timings are the same every running day — timetables are date-independent | 
| A3 | Seats are allotted at booking time; there is no waitlist or RAC | 
| A4 | A booking's lifecycle is exactly Confirmed, Partially Cancelled, or Cancelled | 
| A5 | A phone number is not a unique identifier — family members commonly share one | 
| A6 | Zero-fare tickets are legitimate (child or complimentary); payments always move real money | 
| A7 | A refund may be zero (cancellation charges consume the fare) but never negative |
| A8 | Stop times are same-day clock times; multi-day chronology is not modelled |

