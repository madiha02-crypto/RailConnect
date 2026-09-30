## Problem Statement — RailConnect

## The Problem

Railway reservation is one of the most constraint-heavy data problems in everyday life. Indian Railways alone runs thousands of trains across more than 7,000 stations, carrying millions of passengers a day — and behind every ticket lies a data problem where a single mistake is immediately visible to a real passenger. Four properties make it genuinely hard:

A seat is unique in space and time.
The same physical berth on the same train on the same date can be sold to exactly one passenger. Once seat 34 in coach S4 of the Karnataka Express is allotted for 15 March, that combination is gone — for every other booking, every other passenger, every other session. The rule must hold always, not usually.

Routes are many-to-many.
A train halts at many stations; a station serves many trains. Every halt has its own position in the route and its own arrival and departure times. A route is not a simple list of stations — it is an ordered, timed, shared structure.

Inventory is hierarchical; 
bookings are not.A train contains coaches, coaches contain berths — but a booking cuts across the hierarchy: one train, one origin and destination, one journey date, and often several passengers, each needing their own berth, their own fare, their own ticket.

Money leaves a trail.Bookings are paid for; tickets are sometimes cancelled and refunded. These records are audit history — they must be accurate when written, and impossible to silently destroy afterwards.

## What RailConnect Is
RailConnect is a relational database for railway reservation and scheduling — deliberately the database and nothing else. There is no application layer in this project; the schema itself is the deliverable, and every guarantee it makes is enforced by the engine rather than by calling code.

It manages ten interlinked tables covering the complete reservation lifecycle. While many rules are enforced at the database level using 42 named constraints, the core problem of preventing double-booking across different tables (tickets and bookings) relies on Application-level logic, ensuring the database remains perfectly normalized

## Out of Scope

| Excluded | Why |
| :--- | :--- |
| Application layer / UI | The database is the deliverable; any future client inherits its integrity for free |
| Waitlist / RAC | Bookings are Confirmed, Partially Cancelled or Cancelled — no queued demand modelling |
| User accounts & authentication | Passengers are travellers in the data, not logins in a system |
| Dynamic pricing | The fare is fixed and recorded per ticket at booking time |
| Multi-leg journeys | One booking = one train, one journey date, one origin–destination pair |
| Production-scale data | Sample data is sized to make every business query meaningful, not to mirror national volume |

## Scope — Core Functions

The database supports six core functions

| # | Core function | Implemented by |
| :--- | :--- | :--- |
| F1 | Maintain stations and trains, including each train's stop sequence and timings | `stations`, `trains`, `train_station` |
| F2 | Model coaches and seats for every train | `coaches`, `seats` |
| F3 | Register passengers and record bookings for a journey date | `passengers`, `bookings` |
| F4 | Issue tickets with seat allocation for each passenger in a booking | `tickets` |
| F5 | Record payments for bookings | `payments` |
| F6 | Process cancellations and refunds | `cancellations` |

## What the Project Must Deliver

| Deliverable | Where it lives |
| :--- | :--- |
| Requirements & assumptions | `02-requirements-assumptions.md` |
| Conceptual design — ER diagram | `03-er-diagram.md` + `diagrams/` |
| Logical design — relational schema & keys | `04-relational-schema.md` |
| Integrity constraints | `05-integrity-constraints.md` |
| Normalisation to 3NF with functional dependencies | `06-normalisation.md` |
| Physical implementation — DDL | `schema/create_tables.sql` |
| Sample data | `data/insert_data.sql` |
| Business queries & results | `queries/queries.sql` + `09-queries-and-results.md` |
| Design rationale | `07-design-rationale.md` |
| Validation & testing | `10-validation-report.md` |