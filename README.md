## RailConnect
## Railway Reservation & Scheduling Database

[![MySQL](https://img.shields.io/badge/MySQL-8.0.16%2B-4479A1?logo=mysql&logoColor=white)](https://dev.mysql.com/doc/)



A fully normalised relational database managing trains, routes, coaches, seats, passengers, bookings, payments and cancellations — with the guarantee that a seat is never sold twice for the same train on the same day.

Team 6 · DBMS Course Project

## Overview
Railway reservation is one of the most constraint-heavy data problems in everyday life: a single seat on a single train on a given date can be sold only once, while each train stops at multiple stations along its route.

RailConnect models this complete domain as a relational database, enforces integrity at the database level, and demonstrates its usefulness through meaningful SQL queries.

## The booking lifecycle:

Passenger makes a booking 
       ↓   
BOOKING  (train + route + journey date)
        ↓   
TICKET   (passenger + allotted seat + fare)
        ↓   
PAYMENT  ──→  (optionally)  CANCELLATION + refund

## Team
| S.No | Name | USN | Role |
| :--- | :--- | :--- | :--- |
| 1 | Syed Kaifuddin | AU25UG-061 | Sample Data & SQL Queries  |
| 2 | Yashwant Gowda | AU25UG-084 | SQL Implementation & Constraints |
| 3 | Lakshya R | AU25UG-029 | Requirements & ER Diagram  | 
| 4 | Madiha Shaik S | AU25UG-078 | GitHub & Integration Lead | 
| 5 | Mohammed Shafi | AU25UG-036 | Relational Schema, Keys & Normalisation |
| 6 | Naman Choudhary | AU25UG-040 | Documentation & Validation |

✨ Key Features
- 10 interlinked tables covering the complete reservation lifecycle
- No double booking — a database-level constraint ensures a seat can never be allotted twice for the same train and journey date
- Normalised up to 3NF — functional dependencies documented, with a step-by-step normalisation walkthrough
- Full integrity enforcement — PRIMARY KEY, FOREIGN KEY, NOT NULL, UNIQUE, CHECK, DEFAULT and referential actions (ON DELETE / ON UPDATE)
- 10 analytical queries answering real business questions, with documented interpretations
- Validated design — ER diagram, relational schema and SQL implementation cross-checked; constraints verified with negative test cases

## Tech Stack
| Category | Tool / Technology |
| :--- | :--- |
| Database | MySQL 8.0 |
| Language | SQL (DDL + DML) |
| Version Control | Git & GitHub |
| Diagrams | draw.io |

## Repository Structure
* `schema/`: DDL statements to create the database, tables, and constraints.
* `data/`: DML statements to insert the sample data.
* `queries/`: SQL queries for the business questions.
* `diagrams/`: ER diagram and relational schema diagram.
* `docs/`: Project report and detailed documentation.


## Database Schema
| Table | Purpose |
| :--- | :--- |
| `stations` | Railway stations |
| `trains` | Trains operated |
| `train_stations` | Route: ordered stops of each train (M:N junction table) |
| `coaches` | Coaches attached to each train |
| `seats` | Seats within each coach |
| `passengers` | Travellers |
| `bookings` | Reservations for a journey date |
| `tickets` | Seat allotted to a passenger in a booking |
| `payments` | Payments made for bookings |
| `cancellations` | Cancelled tickets and refunds |


## Setup Instructions
Prerequisites
MySQL 8.0 (or later) installed and running
Any SQL client (MySQL Workbench, DBeaver, or the MySQL command line)
Steps

1. Clone the repository

git clone <https://github.com/madiha02-crypto/RailConnect.git>cd 


2. Create the database and tables

source schema/create_tables.sql;

3. Load the sample data

source data/insert_data.sql;

4. Run the business queries

source queries/queries.sql;

##  Business Questions Answered
#	Question	                         
What are the most popular routes?

Which trains are booked most often?

What is the seat occupancy for each train?

What is the revenue by train?

What is the cancellation rate?

What is the average fare by route?

Which passengers have multiple bookings?

Which coach class generates the most revenue, and what is its share of total revenue?

For each train, on which journey date was revenue the highest?

What is the refund efficiency by train?

Which stations are the busiest, measured by total passenger footfall (departures + arrivals combined)?


## Design & Requirements
01-problem-statement.md - The problem, its scope, and what RailConnect does and deliberately doesn't do

02-requirements-assumptions.md - Numbered functional requirements and assumptions

03-er-diagram.md- The ER diagram, with every relationship's cardinality and participation constraint

04-relational-schema.md	- The ER → relational mapping: every table with PKs, FKs, candidate keys and unique constraints

05-integrity-constraints.md	- Every constraint — NOT NULL, UNIQUE, CHECK, DEFAULT, ON DELETE / ON UPDATE — where applied and why

06-normalisation.md	- Functional dependencies and the full 1NF → 2NF → 3NF working


## Reference
07-data-dictionary.md - All 10 tables, column by column: data type, constraint, meaning

## Validation & Analysis
08-queries-and-results.md	- All 10 business queries with the SQL, results and business interpretation

09-validation-report.md	- ER ⇄ schema ⇄ SQL cross-check matrix, plus negative constraint tests with expected errors

10-limitations-future-work.md

