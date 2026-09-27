# Business Questions

The database answers the following practical business questions:

1. **What are the most popular routes?** (Using GROUP BY source-destination pair, COUNT)
2. **Which trains are booked most often?** (Using JOIN, COUNT, ORDER BY)[cite: 1]
3. **What is the seat occupancy for each train?** (Ratio of booked seats to total seats)
4. **What is the revenue by train?** (Using SUM over payments, GROUP BY)
5. **What is the cancellation rate?** (Using conditional aggregation with CASE)
6. **What is the average fare by route?** (Using AVG, GROUP BY route)
7. **Which passengers have multiple bookings?** (Using GROUP BY, HAVING COUNT > 1)


