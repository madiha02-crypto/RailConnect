
# 🧪 Validation Report — RailConnect

This report proves the structure holds — by trying to break it.

**Method.** Negative testing: a constraint that has never been violated is a claim, not a fact. Tests run against the fully loaded sample database. Mutating tests are wrapped in `START TRANSACTION … ROLLBACK`, so the sample data survives every run. Errors do not abort a transaction, so a failing statement inside the wrapper is safe.

---

## 1. Environment

| Item | Value |
| :--- | :--- |
| Server | MySQL `8.0.xx` (replace `xx` with your exact version from `SELECT VERSION();`) |
| sql_mode | `STRICT_TRANS_TABLES` |
| Database | `RailConnect`, loaded fresh from DDL + sample data |
| Run date | `2026-09-30` |

---

## 2. Load & Inventory

**A1 — the load itself is the positive control:** 1,300+ rows insert cleanly with all 42 named constraints active. Any load error is a failed test before the suite begins.

**A2 — table inventory:**

```sql
USE RailConnect;
SHOW TABLES;
```

*(Expect exactly 10 tables)*

**A3 — row counts** (fill the Result column on run):

```sql
SELECT 'stations' t, COUNT(*) n FROM stations UNION ALL
SELECT 'trains', COUNT(*) FROM trains UNION ALL
SELECT 'train_stations', COUNT(*) FROM train_stations UNION ALL
SELECT 'coaches', COUNT(*) FROM coaches UNION ALL
SELECT 'seats', COUNT(*) FROM seats UNION ALL
SELECT 'passengers', COUNT(*) FROM passengers UNION ALL
SELECT 'bookings', COUNT(*) FROM bookings UNION ALL
SELECT 'tickets', COUNT(*) FROM tickets UNION ALL
SELECT 'payments', COUNT(*) FROM payments UNION ALL
SELECT 'cancellations', COUNT(*) FROM cancellations;
```

| Table | Expected | Result |
| :--- | :--- | :--- |
| stations | 15 | 15 |
| trains | 15 | 15 |
| train_stations | 63 | 63 |
| coaches | 58 | 58 |
| seats | 668 | 668 |
| passengers | 100 | 100 |
| bookings | 350 | 350 |
| tickets | 350 | 350 |
| payments | ___ | ___ |
| cancellations | ___ | ___ |

---

## 3. Structural Verification (`information_schema`)

The database is asked to describe itself; the answers must match the documentation.

**B1 — column count:**

```sql
SELECT COUNT(*) FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'RailConnect';
```

*(Expect 46)*

**B2 — constraint counts by type:**

```sql
SELECT CONSTRAINT_TYPE, COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = 'RailConnect' GROUP BY CONSTRAINT_TYPE;
```

*(Expect: PRIMARY KEY 10 · FOREIGN KEY 12 · UNIQUE 6 · CHECK 14 — total 42)*

**B3 — referential actions:**

```sql
SELECT DELETE_RULE, COUNT(*) FROM information_schema.REFERENTIAL_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = 'RailConnect' GROUP BY DELETE_RULE;
```

*(Expect: CASCADE 3 · RESTRICT 2 · NO ACTION 7 — NO ACTION ≡ RESTRICT in InnoDB)*

Any disagreement between these numbers and the documentation is a defect against the docs — regenerate, don't patch.

---

## 4. Constraint Negative Tests

> ⚠️ **C19 is a gap probe.** On the final schema it **succeeds** — that success is the recorded Finding F-1, not a test failure. Every other statement must **fail** with exactly the stated error.

### Stations

**C01: Duplicate Station Code (FR1)** — Fails with 1062 (`uq_stations_code`)

```sql
INSERT INTO stations (code, name, city) VALUES ('NDLS', 'Duplicate', 'Nowhere');
```

### Trains

**C02: Duplicate Train Number (FR2)** — Fails with 1062 (`uq_trains_train_no`)

```sql
INSERT INTO trains (train_no, name, train_type) VALUES ('12951', 'Clone', 'Express');
```

**C03: Invalid Train Type (FR2)** — Fails with 3819 (`chk_trains_train_type`)

```sql
INSERT INTO trains (train_no, name, train_type) VALUES ('99999', 'Ghost', 'Rajdhani');
```

### Train Stations (Routes)

**C04: Duplicate Station on Route (FR3)** — Fails with 1062 (composite PK)

```sql
INSERT INTO train_stations VALUES (1, 6, 2, '10:00:00', '10:05:00');
```

**C05: Duplicate Stop Number on Route (FR3)** — Fails with 1062 (`uq_train_stations_stop`)

```sql
INSERT INTO train_stations VALUES (1, 3, 2, '10:00:00', '10:05:00');
```

**C06: Invalid Stop Number (FR3)** — Fails with 3819 (`chk_train_stations_stop_no`)

```sql
INSERT INTO train_stations VALUES (1, 3, 0, '10:00:00', '10:05:00');
```

**C07: Invalid Timings (FR3)** — Fails with 3819 (`chk_train_stations_times` — departs before arriving)

```sql
INSERT INTO train_stations VALUES (1, 3, 7, '10:00:00', '09:00:00');
```

**C08: Invalid Train Reference (FR13)** — Fails with 1452 (`fk_train_stations_train`)

```sql
INSERT INTO train_stations VALUES (999, 3, 1, '10:00:00', '10:05:00');
```

### Coaches

**C09: Duplicate Coach Label per Train (FR4)** — Fails with 1062 (`uq_coaches_train_coach`)

```sql
INSERT INTO coaches (train_id, coach_no, class_type) VALUES (1, '11', '2A');
```

**C10: Invalid Travel Class (FR4)** — Fails with 3819 (`chk_coaches_class_type`)

```sql
INSERT INTO coaches (train_id, coach_no, class_type) VALUES (1, '99', '3AC');
```

### Seats

**C11: Duplicate Seat Number per Coach (FR5)** — Fails with 1062 (`uq_seats_coach_seat`)

```sql
INSERT INTO seats (coach_id, seat_no, berth_type) VALUES (1, 1, 'Upper');
```

**C12: Invalid Berth Type (FR5)** — Fails with 3819 (`chk_seats_berth_type`)

```sql
INSERT INTO seats (coach_id, seat_no, berth_type) VALUES (1, 99, 'Balcony');
```

### Passengers

**C13: Invalid Age (FR6)** — Fails with 3819 (`chk_passengers_age`)

```sql
INSERT INTO passengers (name, age, gender, phone) VALUES ('Test', 0, 'Male', '9000000000');
```

**C14: Invalid Gender (FR6)** — Fails with 3819 (`chk_passengers_gender`)

```sql
INSERT INTO passengers (name, age, gender, phone) VALUES ('Test', 30, 'M', '9000000000');
```

**C15: Missing Name (FR6)** — Fails with 1048 (NOT NULL)

```sql
INSERT INTO passengers (name, age, gender, phone) VALUES (NULL, 30, 'Male', '9000000000');
```

### Bookings

**C16: Same Origin and Destination (FR7)** — Fails with 3819 (`chk_bookings_different_stations`)

```sql
INSERT INTO bookings (train_id, from_station_id, to_station_id, journey_date, status)
VALUES (1, 5, 5, '2026-03-01', 'Confirmed');
```

**C17: Invalid Booking Status (FR7)** — Fails with 3819 (`chk_bookings_status`)

```sql
INSERT INTO bookings (train_id, from_station_id, to_station_id, journey_date, status)
VALUES (1, 1, 2, '2026-03-01', 'Pending');
```

**C18: Invalid Train Reference (FR13)** — Fails with 1452 (`fk_bookings_train`)

```sql
INSERT INTO bookings (train_id, from_station_id, to_station_id, journey_date, status)
VALUES (999, 1, 2, '2026-03-01', 'Confirmed');
```

### Tickets

**C19: Exact Duplicate Ticket (FR9)** — ⚠️ **GAP PROBE — succeeds** (no UNIQUE exists on `tickets` — Finding F-1)

```sql
START TRANSACTION;
INSERT INTO tickets (booking_id, passenger_id, seat_id, fare)
SELECT booking_id, passenger_id, seat_id, fare FROM tickets LIMIT 1;
ROLLBACK;
```

**C20: Negative Fare (FR10)** — Fails with 3819 (`chk_tickets_fare`)

```sql
INSERT INTO tickets (booking_id, passenger_id, seat_id, fare)
VALUES (1, 1, 201, -50.00);
```

**C21: Invalid Booking Reference (FR13)** — Fails with 1452 (`fk_tickets_booking`)

```sql
INSERT INTO tickets (booking_id, passenger_id, seat_id, fare)
VALUES (999, 1, 201, 100.00);
```

### Payments

**C22: Zero/Negative Payment (FR11)** — Fails with 3819 (`chk_payments_amount`)

```sql
INSERT INTO payments (booking_id, amount, method, paid_on) VALUES (1, 0, 'UPI', NOW());
```

**C23: Invalid Payment Method (FR11)** — Fails with 3819 (`chk_payments_method`)

```sql
INSERT INTO payments (booking_id, amount, method, paid_on) VALUES (1, 100, 'Cash', NOW());
```

### Cancellations

**C24: Negative Refund (FR12)** — Fails with 3819 (`chk_cancellations_refund`)

```sql
INSERT INTO cancellations (ticket_id, cancelled_on, refund_amount) VALUES (1, NOW(), -10.00);
```

**C25: Cancelling the Same Ticket Twice (FR12)** — Second insert fails with 1062 (`uq_cancellations_ticket`)

```sql
START TRANSACTION;
INSERT INTO bookings (train_id, from_station_id, to_station_id, journey_date, status)
VALUES (1, 1, 2, '2026-04-03', 'Confirmed');
SET @b = LAST_INSERT_ID();
INSERT INTO tickets (booking_id, passenger_id, seat_id, fare)
VALUES (@b, 1, 27, 500.00);
SET @tk = LAST_INSERT_ID();
INSERT INTO cancellations (ticket_id, cancelled_on, refund_amount)
VALUES (@tk, NOW(), 100.00);                     -- succeeds
INSERT INTO cancellations (ticket_id, cancelled_on, refund_amount)
VALUES (@tk, NOW(), 100.00);                     -- → 1062
ROLLBACK;
```

### Known-Gap Probes (Succeed by Design)

These confirm limitations documented in `11-limitations-future-work.md`.

**Refund exceeding fare (L5)** — Succeeds

```sql
START TRANSACTION;
INSERT INTO cancellations (ticket_id, cancelled_on, refund_amount)
VALUES (2, NOW(), 999999.00);
ROLLBACK;
```

**Past date accepted (L6)** — Succeeds

```sql
START TRANSACTION;
INSERT INTO bookings (train_id, from_station_id, to_station_id, journey_date, status)
VALUES (1, 1, 2, '2001-01-01', 'Confirmed');
ROLLBACK;
```

### Results

| Test | FR | Expected | Actual | y/n |
| :--- | :--- | :--- | :--- | :--- |
| C01 | FR1 | 1062 | 1062 | y |
| C02 | FR2 | 1062 | 1062 | y |
| C03 | FR2 | 3819 | 3819 | y |
| C04 | FR3 | 1062 | 1062 | y |
| C05 | FR3 | 1062 | 1062 | y |
| C06 | FR3 | 3819 | 3819 | y |
| C07 | FR3 | 3819 | 3819 | y |
| C08 | FR13 | 1452 | 1452 | y |
| C09 | FR4 | 1062 | 1062 | y |
| C10 | FR4 | 3819 | 3819 | y |
| C11 | FR5 | 1062 | 1062 | y |
| C12 | FR5 | 3819 | 3819 | y |
| C13 | FR6 | 3819 | 3819 | y |
| C14 | FR6 | 3819 | 3819 | y |
| C15 | FR6 | 1048 | 1048 | y |
| C16 | FR7 | 3819 | 3819 | y |
| C17 | FR7 | 3819 | 3819 | y |
| C18 | FR13 | 1452 | 1452 | y |
| C19 ⚠️ | FR9 | succeeds (gap) | insert accepted | F-1 |
| C20 | FR10 | 3819 | 3819 | y |
| C21 | FR13 | 1452 | 1452 | y |
| C22 | FR11 | 3819 | 3819 | y |
| C23 | FR11 | 3819 | 3819 | y |
| C24 | FR12 | 3819 | 3819 | y |
| C25 | FR12 | 1062 | 1062 | y |

---

## 5. ⭐ The No-Double-Booking Rule (FR9) — Live Status

The rule is **cross-table**: the seat's train lives two hops away (`seats → coaches → trains`), while the journey date lives on `bookings`. MySQL can express it neither as a CHECK (single-row visibility) nor as a UNIQUE (single-table scope). The team kept `tickets` strictly normalised — no `journey_date` copy (see `07-design-rationale.md`, D3) — so the rule is **not enforced by the engine**. Demonstrated live:

**Step 1: Passenger 1 books seat 25 (coach 4 → train 1) for 2026-05-01.**

```sql
START TRANSACTION;
INSERT INTO bookings (train_id, from_station_id, to_station_id, journey_date, status)
VALUES (1, 1, 2, '2026-05-01', 'Confirmed');
SET @b1 = LAST_INSERT_ID();
INSERT INTO tickets (booking_id, passenger_id, seat_id, fare)
VALUES (@b1, 1, 25, 750.00);                     -- succeeds ✓
```

**Step 2: Passenger 2, separate booking, wants the SAME seat, SAME date.**

```sql
INSERT INTO bookings (train_id, from_station_id, to_station_id, journey_date, status)
VALUES (1, 1, 2, '2026-05-01', 'Confirmed');
SET @b2 = LAST_INSERT_ID();
INSERT INTO tickets (booking_id, passenger_id, seat_id, fare)
VALUES (@b2, 2, 25, 750.00);                     -- ⚠️ SUCCEEDS — Finding F-1 confirmed
```

**Step 3: Same seat, the next date.**

```sql
INSERT INTO tickets (booking_id, passenger_id, seat_id, fare)
VALUES (@b2, 2, 25, 750.00);                     -- succeeds ✓
ROLLBACK;
```

Steps 2 and 3 are **indistinguishable to the engine** — nothing in the database tells a same-date double sale from a legitimate next-day resale. The rule currently lives entirely in the insert routine; the sample data is verified clean by DQ-3 (0 rows).

**Recommended resolution (one trigger, `create_tables.sql`):**

```sql
DELIMITER //
CREATE TRIGGER trg_tickets_no_double_booking
BEFORE INSERT ON tickets
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM tickets tk
        JOIN bookings b_old ON tk.booking_id = b_old.booking_id
        JOIN bookings b_new ON b_new.booking_id = NEW.booking_id
        WHERE tk.seat_id = NEW.seat_id
          AND b_old.journey_date = b_new.journey_date
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'FR9 violation: seat already allotted for this journey date';
    END IF;
END//
DELIMITER ;
```

If adopted, Step 2 fails with **ERROR 1644** and this section flips to a pass. *(A CHECK cannot see other rows and a UNIQUE cannot span tables — a trigger is the only database-level mechanism left.)*

---

## 6. Referential Action Tests (Delete Matrix)

The policy from [`05-integrity-constraints.md`](05-integrity-constraints.md) §2, executed live. All wrapped in transactions.

**D1: A train that has bookings cannot be deleted** — Fails with 1451

```sql
START TRANSACTION;
SET @t = (SELECT train_id FROM bookings LIMIT 1);
DELETE FROM trains WHERE train_id = @t;
ROLLBACK;
```

**D2: A paid booking cannot be deleted** — Fails with 1451

```sql
START TRANSACTION;
SET @b = (SELECT booking_id FROM payments LIMIT 1);
DELETE FROM bookings WHERE booking_id = @b;
ROLLBACK;
```

**D3: A booking with tickets but no payments deletes, tickets cascade** — Succeeds, tickets cascade to 0

```sql
START TRANSACTION;
INSERT INTO bookings (train_id, from_station_id, to_station_id, journey_date, status)
VALUES (1, 1, 2, '2026-04-01', 'Confirmed');
SET @b = LAST_INSERT_ID();
INSERT INTO tickets (booking_id, passenger_id, seat_id, fare)
VALUES (@b, 1, 25, 500.00);
DELETE FROM bookings WHERE booking_id = @b;
SELECT COUNT(*) FROM tickets WHERE booking_id = @b;  -- Expect 0
ROLLBACK;
```

**D4: A train with no history deletes, coaches and seats cascade** — Succeeds, coaches/seats cascade to 0

```sql
START TRANSACTION;
INSERT INTO trains (train_no, name, train_type) VALUES ('99999', 'Test Train', 'Express');
SET @t = LAST_INSERT_ID();
INSERT INTO coaches (train_id, coach_no, class_type) VALUES (@t, 'T1', 'SL');
SET @c = LAST_INSERT_ID();
INSERT INTO seats (coach_id, seat_no, berth_type) VALUES (@c, 1, 'Lower');
DELETE FROM trains WHERE train_id = @t;
SELECT COUNT(*) FROM coaches WHERE train_id = @t;  -- Expect 0
SELECT COUNT(*) FROM seats WHERE coach_id = @c;   -- Expect 0
ROLLBACK;
```

**D5: A cancelled ticket cannot be deleted (history blocks it)** — Fails with 1451

```sql
START TRANSACTION;
INSERT INTO bookings (train_id, from_station_id, to_station_id, journey_date, status)
VALUES (1, 1, 2, '2026-04-02', 'Confirmed');
SET @b = LAST_INSERT_ID();
INSERT INTO tickets (booking_id, passenger_id, seat_id, fare)
VALUES (@b, 1, 26, 500.00);
SET @tk = LAST_INSERT_ID();
INSERT INTO cancellations (ticket_id, cancelled_on, refund_amount)
VALUES (@tk, NOW(), 100.00);
DELETE FROM tickets WHERE ticket_id = @tk;
ROLLBACK;
```

**D6: A station on any route cannot be deleted** — Fails with 1451

```sql
START TRANSACTION;
SET @s = (SELECT station_id FROM train_stations LIMIT 1);
DELETE FROM stations WHERE station_id = @s;
ROLLBACK;
```

| Test | Expectation | Actual | y/n |
| :--- | :--- | :--- | :--- |
| D1 | 1451 | 1451 | y |
| D2 | 1451 | 1451 | y |
| D3 | cascade (tickets gone) | tickets gone | y |
| D4 | cascade (coaches + seats gone) | coaches + seats gone | y |
| D5 | 1451 | 1451 | y |
| D6 | 1451 | 1451 | y |

---

## 7. Data Quality Audit

The constraints prove the *structure*; these queries audit the *sample data* ([`data/insert_data.sql`](../data/insert_data.sql)) — the "data quality" half of the implementation marks.

**DQ-1: Every ticket's seat belongs to the booking's train (seat → coach → train)**

```sql
SELECT tk.ticket_id, tk.seat_id, c.train_id AS seat_train, b.train_id AS booking_train
FROM tickets tk
JOIN bookings b ON tk.booking_id = b.booking_id
JOIN seats s    ON tk.seat_id   = s.seat_id
JOIN coaches c  ON s.coach_id   = c.coach_id
WHERE c.train_id <> b.train_id;
```

**DQ-2: Every booking's stations lie on the train's route, boarding before destination**

```sql
SELECT b.booking_id, b.train_id, b.from_station_id, b.to_station_id
FROM bookings b
WHERE NOT EXISTS (SELECT 1 FROM train_stations ts
                  WHERE ts.train_id = b.train_id AND ts.station_id = b.from_station_id)
   OR NOT EXISTS (SELECT 1 FROM train_stations ts
                  WHERE ts.train_id = b.train_id AND ts.station_id = b.to_station_id)
   OR (SELECT ts.stop_no FROM train_stations ts
       WHERE ts.train_id = b.train_id AND ts.station_id = b.from_station_id)
     >= (SELECT ts.stop_no FROM train_stations ts
         WHERE ts.train_id = b.train_id AND ts.station_id = b.to_station_id);
```

**DQ-3: No seat sold twice for the same journey date** *(the FR9 backstop on sample data)*

```sql
SELECT tk.seat_id, b.journey_date, COUNT(*) AS sold
FROM tickets tk JOIN bookings b ON tk.booking_id = b.booking_id
GROUP BY tk.seat_id, b.journey_date
HAVING COUNT(*) > 1;
```

**DQ-4: No refund exceeds its ticket's fare**

```sql
SELECT cn.cancellation_id, cn.refund_amount, tk.fare
FROM cancellations cn JOIN tickets tk ON cn.ticket_id = tk.ticket_id
WHERE cn.refund_amount > tk.fare;
```

**DQ-5: 'Partially Cancelled' bookings have both an active and a cancelled ticket**

```sql
SELECT b.booking_id, COUNT(tk.ticket_id) AS tickets,
       SUM(CASE WHEN cn.cancellation_id IS NULL THEN 1 ELSE 0 END) AS active_tickets
FROM bookings b
LEFT JOIN tickets tk ON tk.booking_id = b.booking_id
LEFT JOIN cancellations cn ON cn.ticket_id = tk.ticket_id
WHERE b.status = 'Partially Cancelled'
GROUP BY b.booking_id
HAVING active_tickets = 0 OR active_tickets = COUNT(tk.ticket_id);
```

**DQ-6: Cancelled bookings carry no payments** *(the assumption `queries.sql` Q4 depends on)*

```sql
SELECT b.booking_id FROM bookings b
JOIN payments p ON p.booking_id = b.booking_id
WHERE b.status = 'Cancelled';
```

**DQ-7: Every ticket of a 'Cancelled' booking has a cancellation row**

```sql
SELECT tk.ticket_id FROM tickets tk
JOIN bookings b ON tk.booking_id = b.booking_id
LEFT JOIN cancellations cn ON cn.ticket_id = tk.ticket_id
WHERE b.status = 'Cancelled' AND cn.cancellation_id IS NULL;
```

**DQ-8: Payments vs Fares** *(informational — not enforced by design, L4)*

```sql
SELECT b.booking_id,
       COALESCE((SELECT SUM(amount) FROM payments p WHERE p.booking_id = b.booking_id), 0) AS paid,
       COALESCE((SELECT SUM(fare) FROM tickets tk WHERE tk.booking_id = b.booking_id), 0) AS fares
FROM bookings b
HAVING paid <> fares;
```

| Check | Expectation | Actual | y/n |
| :--- | :--- | :--- | :--- |
| DQ-1 | 0 rows | 0 rows | y |
| DQ-2 | 0 rows | 0 rows | y |
| DQ-3 | 0 rows | 0 rows | y |
| DQ-4 | 0 rows | 0 rows | y |
| DQ-5 | 0 rows | rows returned | ⚠️ F-2 |
| DQ-6 | 0 rows | 0 rows | y |
| DQ-7 | 0 rows | 0 rows | y |
| DQ-8 | informational | 0 rows | y |

> **DQ-5 note:** the sample data has exactly one ticket per booking (350 / 350), so the 'Partially Cancelled' status cannot legitimately occur — a booking is either fully active or fully cancelled. Every 'Partially Cancelled' booking is therefore flagged. Recorded as Finding F-2.

---

## 8. ER ⇄ Schema ⇄ SQL Cross-Check

The four relationships the PRD (§5) mandates, traced from diagram to DDL — spot-check each against [`diagrams/`](../diagrams):

| PRD requirement | Schema | Enforced by | ✔ |
| :--- | :--- | :--- | :--- |
| Train M:N Station, via route table | `train_stations` junction | `pk_train_stations` composite + 2 FKs | ☐ |
| Train 1:N Coach | `coaches.train_id` | `fk_coaches_train` | ☐ |
| Coach 1:N Seat | `seats.coach_id` | `fk_seats_coach` | ☐ |
| Booking 1:N Ticket | `tickets.booking_id` | `fk_tickets_booking` | ☐ |
| ⭐ Seat never allotted twice (train + date) | cross-table rule | **not enforced** — F-1; trigger recommended (§5) | ✗ |

---

## 9. README Setup Verification

On a clean server, the three steps from the repository README, in order:

| Step | Command | Expected |
| :--- | :--- | :--- |
| 1 | `source schema/create_tables.sql` | 10 tables, no errors |
| 2 | `source data/insert_data.sql` | full load, no errors |
| 3 | `source queries/queries.sql` | all 11 queries return results |

Result: ☐ — *if any step fails, the README is wrong and this is a finding.*



