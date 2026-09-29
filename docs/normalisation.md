# Normalisation

### 1. `stations`
* **Relation Schema:** `stations(station_id, code, name, city)`
* **Candidate Keys:** `station_id`, `code`
* **Functional Dependencies:**
  * FD₁: `station_id` → `code`, `name`, `city`
  * FD₂: `code` → `station_id`, `name`, `city`
* **Verification:**
  * The determinant in FD₁ (`station_id`) is a candidate key / superkey.
  * The determinant in FD₂ (`code`) is a candidate key / superkey.
* **Conclusion:** Satisfies 3NF.

---

### 2. `trains`
* **Relation Schema:** `trains(train_id, train_no, name, train_type)`
* **Candidate Keys:** `train_id`, `train_no`
* **Functional Dependencies:**
  * FD₁: `train_id` → `train_no`, `name`, `train_type`
  * FD₂: `train_no` → `train_id`, `name`, `train_type`
* **Verification:**
  * The determinants in both FD₁ (`train_id`) and FD₂ (`train_no`) are superkeys.
* **Conclusion:** Satisfies 3NF.

---

### 3. `train_stations`
* **Relation Schema:** `train_stations(train_id, station_id, stop_no, arrival_time, departure_time)`
* **Candidate Keys:** `(train_id, station_id)`, `(train_id, stop_no)`
* **Functional Dependencies:**
  * FD₁: (`train_id`, `station_id`) → `stop_no`, `arrival_time`, `departure_time`
  * FD₂: (`train_id`, `stop_no`) → `station_id`, `arrival_time`, `departure_time`
* **Verification:**
  * Both left-hand determinants are composite candidate keys.
* **Conclusion:** Satisfies 3NF.

---

### 4. `coaches`
* **Relation Schema:** `coaches(coach_id, train_id, coach_no, class_type)`
* **Candidate Keys:** `coach_id`, `(train_id, coach_no)`
* **Functional Dependencies:**
  * FD₁: `coach_id` → `train_id`, `coach_no`, `class_type`
  * FD₂: (`train_id`, `coach_no`) → `coach_id`, `class_type`
* **Verification:**
  * In FD₁, `coach_id` is a superkey.
  * In FD₂, `(train_id, coach_no)` is a composite candidate key.
* **Conclusion:** Satisfies 3NF.

---

### 5. `seats`
* **Relation Schema:** `seats(seat_id, coach_id, seat_no, berth_type)`
* **Candidate Keys:** `seat_id`, `(coach_id, seat_no)`
* **Functional Dependencies:**
  * FD₁: `seat_id` → `coach_id`, `seat_no`, `berth_type`
  * FD₂: (`coach_id`, `seat_no`) → `seat_id`, `berth_type`
* **Verification:**
  * The determinant in FD₁ is a superkey.
  * The determinant in FD₂ is a candidate key.
* **Conclusion:** Satisfies 3NF.

---

### 6. `passengers`
* **Relation Schema:** `passengers(passenger_id, name, age, gender, phone)`
* **Candidate Key:** `passenger_id`
* **Functional Dependencies:**
  * FD₁: `passenger_id` → `name`, `age`, `gender`, `phone`
* **Verification:**
  * `passenger_id` is the primary key and superkey.
* **Conclusion:** Satisfies 3NF.

---

### 7. `bookings`
* **Relation Schema:** `bookings(booking_id, train_id, from_station_id, to_station_id, journey_date, status)`
* **Candidate Key:** `booking_id`
* **Functional Dependencies:**
  * FD₁: `booking_id` → `train_id`, `from_station_id`, `to_station_id`, `journey_date`, `status`
* **Verification:**
  * `booking_id` is the sole candidate key.
* **Conclusion:** Satisfies 3NF.

---

### 8. `tickets`
* **Relation Schema:** `tickets(ticket_id, booking_id, passenger_id, seat_id, fare)`
* **Candidate Key:** `ticket_id`
* **Functional Dependencies:**
  * FD₁: `ticket_id` → `booking_id`, `passenger_id`, `seat_id`, `fare`
* **Verification:**
  * `ticket_id` is the primary/superkey.
* **Conclusion:** Satisfies 3NF.

---

### 9. `payments`
* **Relation Schema:** `payments(payment_id, booking_id, amount, method, paid_on)`
* **Candidate Key:** `payment_id`
* **Functional Dependencies:**
  * FD₁: `payment_id` → `booking_id`, `amount`, `method`, `paid_on`
* **Verification:**
  * `payment_id` is a superkey.
* **Conclusion:** Satisfies 3NF.

---

### 10. `cancellations`
* **Relation Schema:** `cancellations(cancellation_id, ticket_id, cancelled_on, refund_amount)`
* **Candidate Keys:** `cancellation_id`, `ticket_id`
* **Functional Dependencies:**
  * FD₁: `cancellation_id` → `ticket_id`, `cancelled_on`, `refund_amount`
  * FD₂: `ticket_id` → `cancellation_id`, `cancelled_on`, `refund_amount`
* **Verification:**
  * Both determinants are superkeys; hence no non-prime attribute determines another non-prime attribute.
* **Conclusion:** Satisfies 3NF.