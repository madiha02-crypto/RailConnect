-- ============================================================
-- RAILCONNECT
-- SAMPLE DATA — insert_data.sql  (scaled: ~350 bookings)
-- Run AFTER schema/create_tables.sql
-- MySQL 8.0+
-- ============================================================
 
USE RailConnect;
 
-- ============================================================
-- 1. STATIONS  (15 stations across India)
-- ============================================================
 
INSERT INTO stations (station_id, code, name, city) VALUES
(1, 'NDLS', 'New Delhi', 'New Delhi'),
(2, 'MMCT', 'Mumbai Central', 'Mumbai'),
(3, 'MAS', 'Chennai Central', 'Chennai'),
(4, 'HWH', 'Howrah Junction', 'Kolkata'),
(5, 'SBC', 'KSR Bengaluru', 'Bengaluru'),
(6, 'ADI', 'Ahmedabad Junction', 'Ahmedabad'),
(7, 'PUNE', 'Pune Junction', 'Pune'),
(8, 'JP', 'Jaipur Junction', 'Jaipur'),
(9, 'LKO', 'Lucknow Junction', 'Lucknow'),
(10, 'HYB', 'Hyderabad Deccan', 'Hyderabad'),
(11, 'BPL', 'Bhopal Junction', 'Bhopal'),
(12, 'NGP', 'Nagpur Junction', 'Nagpur'),
(13, 'BZA', 'Vijayawada Junction', 'Vijayawada'),
(14, 'CSTM', 'Chhatrapati Shivaji T', 'Mumbai'),
(15, 'GWL', 'Gwalior Junction', 'Gwalior');
 
-- ============================================================
-- 2. TRAINS  (15 trains, mixed types)
-- ============================================================
 
INSERT INTO trains (train_id, train_no, name, train_type) VALUES
(1, '12951', 'Mumbai Rajdhani', 'Superfast'),
(2, '12627', 'Karnataka Express', 'Express'),
(3, '12301', 'Howrah Rajdhani', 'Superfast'),
(4, '22691', 'Rajdhani Express', 'Superfast'),
(5, '11057', 'CSMT Amritsar Express', 'Express'),
(6, '16591', 'Hampi Express', 'Passenger'),
(7, '12649', 'Sampark Kranti Express', 'Express'),
(8, '12723', 'Telangana Express', 'Express'),
(9, '12002', 'Bhopal Shatabdi', 'Superfast'),
(10, '11071', 'Kamayani Express', 'Express'),
(11, '12025', 'Pune Shatabdi', 'Superfast'),
(12, '16032', 'Andhra Pradesh Express', 'Express'),
(13, '12615', 'Grand Trunk Express', 'Superfast'),
(14, '19019', 'Dehradun Express', 'Mail'),
(15, '11077', 'Jhelum Express', 'Passenger');

