## Problem Statement — RailConnect

## The Problem

Railway reservation is one of the most constraint-heavy data problems in everyday life. Indian Railways alone runs thousands of trains across more than 7,000 stations, carrying millions of passengers a day — and behind every ticket lies a data problem where a single mistake is immediately visible to a real passenger.

## What RailConnect Is
RailConnect is a relational database for railway reservation and scheduling . Insted of having an application layer , we used built in Mysql constraints to manage the system.

RailConnect manages ten interlinked tables covering the complete reservation lifecycle with 42 constraints enforcing rules at database level. 

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
| Conceptual design — ER diagram | `03-er-diagram.md` + `diagrams/` |
| Logical design — relational schema & keys | `04-relational-schema.md` |
| Integrity constraints | `05-integrity-constraints.md` |
| Normalisation to 3NF with functional dependencies | `06-normalisation.md` |
| Physical implementation — DDL | `schema/create_tables.sql` |
| Sample data | `data/insert_data.sql` |
| Business queries & results | `queries/queries.sql` + `queries-and-results.md` |
| Validation & testing | `validation-report.md` |