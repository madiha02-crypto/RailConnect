# Normalisation

### 1. `stations`
* **Relation Schema:** `stations(station_id, code, name, city)`
* **Candidate Keys:** `station_id`, `code`
* **Functional Dependencies:**
  * $FD_1: \text{station\_id} \rightarrow \text{code}, \text{name}, \text{city}$
  * $FD_2: \text{code} \rightarrow \text{station\_id}, \text{name}, \text{city}$
* **Verification:**
  * The determinant in $FD_1$ (`station_id`) is a candidate key / superkey.
  * The determinant in $FD_2$ (`code`) is a candidate key / superkey.
* **Conclusion:** Satisfies 3NF.

---

### 2. `trains`
* **Relation Schema:** `trains(train_id, train_no, name, train_type)`
* **Candidate Keys:** `train_id`, `train_no`
* **Functional Dependencies:**
  * $FD_1: \text{train\_id} \rightarrow \text{train\_no}, \text{name}, \text{train\_type}$
  * $FD_2: \text{train\_no} \rightarrow \text{train\_id}, \text{name}, \text{train\_type}$
* **Verification:**
  * The determinants in both $FD_1$ (`train_id`) and $FD_2$ (`train_no`) are superkeys.
* **Conclusion:** Satisfies 3NF.

---

### 3. `train_stations`
* **Relation Schema:** `train_stations(train_id, station_id, stop_no, arrival_time, departure_time)`
* **Candidate Keys:** `(train_id, station_id)`, `(train_id, stop_no)`
* **Functional Dependencies:**
  * $FD_1: (\text{train\_id}, \text{station\_id}) \rightarrow \text{stop\_no}, \text{arrival\_time}, \text{departure\_time}$
  * $FD_2: (\text{train\_id}, \text{stop\_no}) \rightarrow \text{station\_id}, \text{arrival\_time}, \text{departure\_time}$
* **Verification:**
  * Both left-hand determinants are composite candidate keys.
* **Conclusion:** Satisfies 3NF.

---

### 4. `coaches`
* **Relation Schema:** `coaches(coach_id, train_id, coach_no, class_type)`
* **Candidate Keys:** `coach_id`, `(train_id, coach_no)`
* **Functional Dependencies:**
  * $FD_1: \text{coach\_id} \rightarrow \text{train\_id}, \text{coach\_no}, \text{class\_type}$
  * $FD_2: (\text{train\_id}, \text{coach\_no}) \rightarrow \text{coach\_id}, \text{class\_type}$
* **Verification:**
  * In $FD_1$, `coach_id` is a superkey.
  * In $FD_2$, `(train_id, coach_no)` is a composite candidate key.
* **Conclusion:** Satisfies 3NF.

---

### 5. `seats`
* **Relation Schema:** `seats(seat_id, coach_id, seat_no, berth_type)`
* **Candidate Keys:** `seat_id`, `(coach_id, seat_no)`
* **Functional Dependencies:**
  * $FD_1: \text{seat\_id} \rightarrow \text{coach\_id}, \text{seat\_no}, \text{berth\_type}$
  * $FD_2: (\text{coach\_id}, \text{seat\_no}) \rightarrow \text{seat\_id}, \text{berth\_type}$
* **Verification:**
  * The determinant in $FD_1$ is a superkey.
  * The determinant in $FD_2$ is a candidate key.
* **Conclusion:** Satisfies 3NF.

---

### 6. `passengers`
* **Relation Schema:** `passengers(passenger_id, name, age, gender, phone)`
* **Candidate Key:** `passenger_id`
* **Functional Dependencies:**
  * $FD_1: \text{passenger\_id} \rightarrow \text{name}, \text{age}, \text{gender}, \text{phone}$
* **Verification:**
  * `passenger_id` is the primary key and superkey.
* **Conclusion:** Satisfies 3NF.

---

### 7. `bookings`
* **Relation Schema:** `bookings(booking_id, train_id, from_station_id, to_station_id, journey_date, status)`
* **Candidate Key:** `booking_id`
* **Functional Dependencies:**
  * $FD_1: \text{booking\_id} \rightarrow \text{train\_id}, \text{from\_station\_id}, \text{to\_station\_id}, \text{journey\_date}, \text{status}$
* **Verification:**
  * `booking_id` is the sole candidate key.
* **Conclusion:** Satisfies 3NF.

---

### 8. `tickets`
* **Relation Schema:** `tickets(ticket_id, booking_id, passenger_id, seat_id, fare)`
* **Candidate Key:** `ticket_id`
* **Functional Dependencies:**
  * $FD_1: \text{ticket\_id} \rightarrow \text{booking\_id}, \text{passenger\_id}, \text{seat\_id}, \text{fare}$
* **Verification:**
  * `ticket_id` is the primary/superkey.
* **Conclusion:** Satisfies 3NF.

---

### 9. `payments`
* **Relation Schema:** `payments(payment_id, booking_id, amount, method, paid_on)`
* **Candidate Key:** `payment_id`
* **Functional Dependencies:**
  * $FD_1: \text{payment\_id} \rightarrow \text{booking\_id}, \text{amount}, \text{method}, \text{paid\_on}$
* **Verification:**
  * `payment_id` is a superkey.
* **Conclusion:** Satisfies 3NF.

---

### 10. `cancellations`
* **Relation Schema:** `cancellations(cancellation_id, ticket_id, cancelled_on, refund_amount)`
* **Candidate Keys:** `cancellation_id`, `ticket_id`
* **Functional Dependencies:**
  * $FD_1: \text{cancellation\_id} \rightarrow \text{ticket\_id}, \text{cancelled\_on}, \text{refund\_amount}$
  * $FD_2: \text{ticket\_id} \rightarrow \text{cancellation\_id}, \text{cancelled\_on}, \text{refund\_amount}$