-- Student Performance Analytics Database
-- Sample data. Run schema.sql first, then this file.

USE student_performance_db;

-- 1. Departments (ids 1 to 4)
INSERT INTO DEPARTMENT (dept_name) VALUES
('CSE'),
('IT'),
('ECE'),
('Mechanical');

-- 2. Students (ids 1 to 18)
INSERT INTO STUDENT (roll_no, name, email, dept_id) VALUES
('0111CS231001', 'Aarav Sharma',    'aarav.sharma@example.com',    1),
('0111CS231002', 'Priya Verma',     'priya.verma@example.com',     1),
('0111CS231003', 'Rohan Gupta',     'rohan.gupta@example.com',     1),
('0111CS231004', 'Ananya Singh',    'ananya.singh@example.com',    1),
('0111CS231005', 'Kabir Jain',      'kabir.jain@example.com',      1),
('0111CS231006', 'Diya Patel',      'diya.patel@example.com',      1),
('0111IT231001', 'Vihaan Mehta',    'vihaan.mehta@example.com',    2),
('0111IT231002', 'Isha Tiwari',     'isha.tiwari@example.com',     2),
('0111IT231003', 'Arjun Yadav',     'arjun.yadav@example.com',     2),
('0111IT231004', 'Sneha Kulkarni',  'sneha.kulkarni@example.com',  2),
('0111IT231005', 'Rahul Mishra',    'rahul.mishra@example.com',    2),
('0111EC231001', 'Meera Joshi',     'meera.joshi@example.com',     3),
('0111EC231002', 'Karan Chauhan',   'karan.chauhan@example.com',   3),
('0111EC231003', 'Nisha Rathore',   'nisha.rathore@example.com',   3),
('0111EC231004', 'Aditya Pandey',   'aditya.pandey@example.com',   3),
('0111ME231001', 'Siddharth Rao',   'siddharth.rao@example.com',   4),
('0111ME231002', 'Pooja Dubey',     'pooja.dubey@example.com',     4),
('0111ME231003', 'Manish Soni',     'manish.soni@example.com',     4);

-- 3. Subjects (ids 1 to 6)
INSERT INTO SUBJECT (subject_name, credits, dept_id) VALUES
('Database Management Systems', 4, 1),
('Data Structures',             4, 1),
('Operating Systems',           3, 1),
('Computer Networks',           3, 2),
('Digital Electronics',         4, 3),
('Thermodynamics',              4, 4);

-- 4. Marks (student_id, subject_id, marks_obtained)
INSERT INTO MARKS (student_id, subject_id, marks_obtained) VALUES
-- Student 1
(1, 1, 92), (1, 2, 88), (1, 3, 85), (1, 4, 90),
-- Student 2
(2, 1, 78), (2, 2, 82), (2, 3, 74), (2, 5, 80),
-- Student 3
(3, 1, 56), (3, 2, 48), (3, 3, 62), (3, 4, 55),
-- Student 4
(4, 1, 95), (4, 2, 91), (4, 3, 89), (4, 5, 93),
-- Student 5 (fails in two subjects)
(5, 1, 35), (5, 2, 42), (5, 3, 38), (5, 6, 45),
-- Student 6 (ties with student 10)
(6, 1, 67), (6, 2, 71), (6, 3, 64), (6, 4, 69),
-- Student 7
(7, 2, 72), (7, 4, 81), (7, 5, 77), (7, 6, 68),
-- Student 8
(8, 2, 88), (8, 4, 76), (8, 5, 84), (8, 6, 79),
-- Student 9 (fails in one subject)
(9, 1, 45), (9, 4, 38), (9, 5, 52), (9, 6, 41),
-- Student 10 (ties with student 6)
(10, 1, 73), (10, 2, 66), (10, 4, 70), (10, 5, 62),
-- Student 11
(11, 2, 58), (11, 4, 61), (11, 5, 49), (11, 6, 55),
-- Student 12
(12, 1, 84), (12, 3, 79), (12, 5, 91), (12, 6, 86),
-- Student 13 (fails in one subject)
(13, 2, 39), (13, 3, 44), (13, 5, 51), (13, 6, 47),
-- Student 14
(14, 1, 69), (14, 3, 72), (14, 4, 80), (14, 5, 75),
-- Student 15
(15, 1, 60), (15, 2, 65), (15, 3, 58), (15, 6, 62),
-- Student 16
(16, 3, 50), (16, 4, 47), (16, 5, 55), (16, 6, 59),
-- Student 17 (only 3 subjects)
(17, 1, 82), (17, 2, 77), (17, 6, 90);
-- Student 18 has no marks on purpose (for the LEFT JOIN query)