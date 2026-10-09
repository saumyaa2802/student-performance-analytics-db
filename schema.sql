-- Student Performance Analytics Database
-- Run this file first, then data.sql, then queries.sql

CREATE DATABASE IF NOT EXISTS  student_performance_db;
USE student_performance_db;

-- Drop in reverse order of dependency so the file can be re-run
DROP view if exists vw_result_sheet;
DROP TABLE IF EXISTS MARKS;
DROP TABLE IF EXISTS SUBJECT ;
DROP TABLE IF EXISTS STUDENT;
DROP TABLE IF EXISTS DEPARTMENT;

-- CERATE TABLE FOR DEPARTMENT

CREATE TABLE DEPARTMENT (
 dept_id INT  AUTO_INCREMENT PRIMARY KEY,
 dept_name VARCHAR(50) NOT NULL UNIQUE

);

-- STUDENT
CREATE TABLE STUDENT (
 student_id INT AUTO_INCREMENT PRIMARY KEY,
 roll_no VARCHAR(50) NOT NULL UNIQUE ,
 name VARCHAR(100) NOT NULL,
 email VARCHAR(100) NOT NULL UNIQUE,
 dept_id INT NOT NULL,
 FOREIGN KEY(dept_id) REFERENCES DEPARTMENT(dept_id)
 ON DELETE RESTRICT ON UPDATE CASCADE
);

-- SUBJECTS

CREATE TABLE SUBJECT (
    subject_id INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    subject_name VARCHAR(100) NOT NULL,
    credits INT NOT NULL CHECK (credits BETWEEN 1 AND 6),
    dept_id INT NOT NULL,
    UNIQUE (subject_name , dept_id),
    FOREIGN KEY (dept_id)
        REFERENCES DEPARTMENT (dept_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- MARKS
CREATE TABLE MARKS(
marks_id INT  AUTO_INCREMENT PRIMARY KEY,
student_id INT NOT NULL,
subject_id INT NOT NULL,
marks_obtained INT NOT NULL CHECK( marks_obtained BETWEEN 0 AND 100),
UNIQUE ( subject_id, student_id),
FOREIGN KEY ( student_id) REFERENCES STUDENT(student_id)
 ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY (subject_id) REFERENCES SUBJECT(subject_id)
 ON DELETE RESTRICT ON UPDATE CASCADE
);

-- INDEXES
CREATE INDEX idx_student_name ON STUDENT(name);
CREATE INDEX idx_marks_subject_marks ON MARKS ( subject_id, marks_obtained);

-- views
CREATE VIEW vw_result_sheet AS 
SELECT s.roll_no,
		s.name,
        d.dept_name,
        sub.subject_name,
        sub.credits,
        m.marks_obtained,
        CASE 
            WHEN m.marks_obtained >= 90 THEN 'A+'
            WHEN m.marks_obtained >= 75 THEN 'A'
            WHEN m.marks_obtained >= 60 THEN 'B'
            WHEN m.marks_obtained >= 40 THEN 'C'
            ELSE 'FAIL'
         END AS grade   
FROM MARKS m
JOIN STUDENT    s   ON m.student_id = s.student_id
JOIN SUBJECT    sub ON m.subject_id = sub.subject_id
JOIN DEPARTMENT d   ON s.dept_id    = d.dept_id;



