s## Limitations & Future Work — RailConnect

01-problem-statement.md draws the project's boundary in one line per exclusion. This file owns the full ledger, in three parts: limitations — weaknesses of the system we did build; exclusions — the boundaries we deliberately chose, expanded with reasoning and upgrade paths; and future work — those upgrade paths, prioritized.

## Limitations of the Delivered System

| ID | Limitation | Why it exists, and what it costs |
| :--- | :--- | :--- |
| L2 | Booking creation is not atomic | A complete booking spans three tables (`bookings` → `tickets` → `payments`). The database enforces every table's rules but cannot force a client to finish the sequence — a crash after the first insert leaves a reservation with no tickets. |
| L3 | Seat allocation is segment-blind | The star constraint means one seat serves exactly one passenger for an entire date. Real railways resell the same berth for a later segment of the route — passenger A rides stations 1–3, passenger B rides 3–5 on the same berth. RailConnect deliberately trades that capacity optimization for a rule that is trivially provable; segment reuse needs overlap logic a UNIQUE index cannot express. |
| L4 | Payments are not reconciled to fares | Nothing enforces that a booking's payments sum to its tickets' fares. Partial payments and overpayments are representable — a CHECK cannot aggregate across rows. |
| L5 | Refunds are not capped | `chk_cancellations_refund` only requires `refund_amount >= 0`. A refund exceeding the original fare is representable, because a CHECK cannot compare a column against a row in another table. |
| L6 | Past journey dates are accepted | `journey_date >= today` cannot be expressed declaratively: MySQL forbids non-deterministic functions such as `CURDATE()` inside CHECK constraints. |
| L7 | Route chronology is only partially validated | `chk_train_station_times` compares arrival against departure at the same stop, but nothing orders stops against each other — stop 4 arriving before stop 3 departs is representable. The TIME type also carries no day component, so on multi-day routes, 08:00 on day one is indistinguishable from 08:00 on day two. |
| L8 | Hard MySQL 8.0.16 floor | Below that version, CHECK constraints are parsed and then silently ignored — the DDL loads "successfully" while all 14 `chk_*` rules do nothing. A deployment limitation, not just a footnote (see the warning in `05-integrity-constraints.md`, Section 5). |


## Deliberate Exclusions 

| ID | Exclusion | Why excluded | Upgrade path |
| :--- | :--- | :--- | :--- |
| E1 | Application layer / UI | The database is the deliverable; any future client inherits its integrity for free — that is the point of pushing rules into the schema | Build any client on top; nothing in the schema needs to change |
| E2 | Waitlist / RAC | Booking status is a closed three-state lifecycle; queued demand is closer to a scheduling problem than a data-integrity one | `waitlist` table keyed on `(train_id, journey_date, waitlist_no)` with UNIQUE on the key; a trigger promotes the head of the queue when a cancellation frees a seat |
| E3 | User accounts & authentication | Passengers are travellers in the data, not logins on the system | `users` + `roles` tables, with GRANT-based privileges separating clerk, analyst and admin |
| E4 | Dynamic pricing | A fixed fare recorded per ticket keeps the financial history self-contained and auditable | `fare_rules` table (class × route × demand band); fare computed and frozen onto the ticket at booking time |
| E5 | Multi-leg journeys | One booking = one train, one date, one origin–destination pair keeps every constraint expressible | `journeys` and `legs` tables; the booking references a journey instead of a train |
| E6 | Production-scale data | Sample data is sized so every business query returns a meaningful answer, not to mirror national volume | Generator scripts + partitioning (see FW11) |

## Future Work — Prioritized

| Priority | ID | Enhancement | What it delivers | Closes |
| :--- | :--- | :--- | :--- | :--- |
| P1 | FW1 | `sp_create_booking` stored procedure | Booking + tickets + payment inserted inside one transaction — the client makes a single CALL and can no longer be interrupted halfway | L2 |
| P1 | FW2 | `trg_ticket_date_match` BEFORE INSERT trigger | Rejects a ticket whose `journey_date` differs from its booking's | L1 |
| P1 | FW3 | `trg_future_journey` BEFORE INSERT trigger | Rejects journey dates in the past — the trigger can call `CURDATE()`, which a CHECK cannot | L6 |
| P1 | FW4 | `trg_refund_cap` BEFORE INSERT trigger | Rejects a refund larger than the referenced ticket's fare | L5 |
| P2 | FW5 | `v_available_seats` view | Free seats per train per date — turns the star rule inside-out into the query a booking screen actually needs | — |
| P2 | FW6 | Payment reconciliation check | Flags bookings where `SUM(payments)` ≠ `SUM(ticket fares)` | L4 |
| P2 | FW7 | Waitlist modelling | The E2 design, implemented | E2 |
| P3 | FW8 | Segment-aware allocation | Same berth sold for non-overlapping route segments — requires overlap logic (PostgreSQL's EXCLUDE constraint, or generated-column workarounds on MySQL) | L3 |
| P3 | FW9 | Targeted indexes | Composite index on `bookings` (`train_id`, `journey_date`) for the hot availability lookup; index on `payments.paid_on` for the revenue analytics in `09-queries-and-results.md` | — |
| P3 | FW10 | Role-based access | GRANT separation: booking clerk (DML on operational tables), analyst (SELECT only), admin | E3 |
| P3 | FW11 | Partition `tickets` by year | Keeps the largest, fastest-growing table manageable at real volume | E6 |
| P3 | FW12 | Multi-leg journeys | The E5 design, implemented | E5 |