## Design Rationale — RailConnect

## 1. Decision Index

| # | Decision | Rejected alternative — and why |
| :--- | :--- | :--- |
| D1 | Surrogate AUTO_INCREMENT PKs; business identifiers behind UNIQUE | Natural keys — unstable (trains get renumbered), wider joins, cascading rewrites |
| D2 | `train_station` junction table carrying `stop_no` and `times` | Route stored as a station list on `trains` — violates 1NF, cannot hold per-stop times |
| D4 | Fare stored per ticket | Fare on the booking — passengers in one booking may differ in class and concessions |
| D5 | Payments and cancellations as separate event tables | Money columns on `bookings`, a cancelled-flag on `tickets` — cannot represent unpaid, partial, at-most-once, or surviving history |
| D6 | Stored three-state booking status | Status derived from `tickets` at query time — aggregation on every read; status is an operational fact, not a computation |
| D7 | Referential action chosen per relationship | Uniform CASCADE — silently destroys history; uniform RESTRICT — owned data becomes undeletable |
| D8 | Bookings reference stations directly | Composite FK into `train_station` — couples bookings to route data; the cost is recorded as L9 |
| D9 | `DECIMAL(10,2)` money; `DATE` / `TIME` / `DATETIME` each where they belong | `FLOAT`/`DOUBLE` — binary fractions cannot represent paise exactly |
| D10 | CHECK-based vocabularies | `ENUM` — MySQL-specific, and the brief allows three RDBMSs; lookup tables — six joins for frozen lists |

## 2. Keys & Identity

## D1 — Surrogate primary keys, business identifiers behind UNIQUE

Every table is keyed by a surrogate AUTO_INCREMENT integer; the identifiers humans actually use — stations.code, trains.train_no — sit behind UNIQUE constraints instead of serving as keys.

Why not natural keys: public identifiers are unstable (Indian Railways renumbers trains; station codes get revised), they are wide (VARCHAR keys propagate through every foreign key and every join), and changing one would cascade rewrites through dependent tables. A surrogate never changes, so joins stay narrow and references stay valid forever.

The one exception proves the rule: train_station uses the natural composite PK (train_id, station_id) — the only table without a surrogate. A stop has no identity apart from its train and its station; a surrogate stop_id would need a UNIQUE on the pair anyway, buying nothing.

## D2 — The route as a junction table

A train stops at many stations; a station serves many trains — a textbook M:N, resolved by train_station, which carries the relationship's own data: stop_no, arrival_time, departure_time.

Why not a station list on trains: a comma-separated route is atomic-value abuse (1NF violation) and cannot hold a time per stop.

## 3. The Booking Model

## D3 — journey_date on tickets: 

The problem. FR9 — no seat allotted twice for the same train and journey date 

The option considered:

Copy journey_date onto tickets and declare UNIQUE (seat_id, journey_date) — chosen.

Why option 4. By A7, seat_id alone already determines the train — so (seat_id, journey_date) pins down exactly one seat on one train on one date, which is precisely the unit FR9 talks about

## D4 — Fare belongs to the ticket

fare lives on tickets, frozen at booking time (A5). Why not on the booking: passengers within one booking may sit in different classes (a seat's class comes from its coach) or qualify for different concessions (age-based) — a single booking-level fare is only correct if every passenger pays the same, which the domain does not promise. Per-ticket fare also makes the revenue-by-class and average-fare analyses (09-queries-and-results.md) direct aggregations over one column.

## D5 — Booking status is stored, not derive

bookings.status holds the three-state lifecycle (A4) rather than being computed from the tickets on demand.

Why not derived: every filter in the query set (Q3, Q5, Q8, Q11) would need a per-row subquery aggregating tickets and cancellations before it could ask "is this booking cancelled?" — and the answer still would not be an operational fact. Status changes when a clerk acts; storing it makes the action the update, and makes the analytics one WHERE clause.

## 4. Integrity Policy

## D6 — Referential actions per relationship, never by default

Three CASCADEs (coach→train, seat→coach, ticket→booking) and nine RESTRICTs (everything else), plus no ON UPDATE anywhere — surrogate keys never change, so there is nothing to cascade (D1).

Why not one action everywhere: uniform CASCADE would let a single DELETE FROM trains reach through coaches and seats toward ticket history — destruction by domino. Uniform RESTRICT would make owned data (a train's coaches, a booking's tickets) practically undeletable, inviting orphaned rows through manual maintenance.

## D7 — Bookings reference stations directly

bookings carries from_station_id / to_station_id as simple foreign keys into stations — not into the route.

The alternative that was considered: a composite foreign key — FOREIGN KEY (train_id, from_station_id) REFERENCES train_station(train_id, station_id) (and likewise for the destination) — would additionally enforce that the train actually stops at both booked stations. It was not taken: it couples every booking insert to the route data being present and correct first, and complicates the sample-data load order.

## 5. Types & Domains

## D8 — Exact money, honest time

DECIMAL(10,2) for every monetary column. Why never FLOAT: binary fractions cannot represent ten paise exactly; rounding drift across thousands of rows is an audit finding, not a rounding error

## D10 — CHECK vocabularies, portable and frozen

The six business vocabularies (train type, class, berth, gender, status, method) are CHECK constraints with IN (...) lists.

Why not ENUM: the brief permits MySQL, PostgreSQL or SQL Server — ENUM is MySQL-specific, while CHECK ... IN ports to all three.

## 6. Minor Decisions


Decision	Reasoning	Links to
phone is NOT NULL but not UNIQUE	family members commonly share a number; uniqueness would block booking for a child	A8
fare ≥ 0 but amount > 0	a zero fare is legitimate (complimentary/child); a payment always moves real money	A9
refund_amount stored, not derived	the refund depends on when the cancellation happened (charges) — not derivable from stored data	—
DROP DATABASE IF EXISTS at the top of the DDL	makes the script an idempotent reset button — re-runnable demos, reproducible validation runs	10-validation-report.md
7. Keeping This File True
The DDL is the source of truth. If schema/create_tables.sql ever changes, the affected D-numbers are reviewed with it — a decision that no longer matches the schema is worse than no decision at all. Every D above is also a prepared viva answer: why surrogate keys, why the date is in two tables, why cancellations are separate, why CHECK and not ENUM — the questions are predictable, and now so are the answers.