-- Student Performance Analytics Database
-- Queries. Run schema.sql, then data.sql, then this file.

USE student_performance_db;

-- =====================================================
-- SECTION 1: JOINS AND FILTERING
-- =====================================================

-- Q1: List all students with their department name
-- INNER JOIN keeps only rows where dept_id matches in both tables.
-- ORDER BY sorts by department first, then by name inside each department.
SELECT s.roll_no, s.name, d.dept_name
FROM STUDENT s
INNER JOIN DEPARTMENT d ON s.dept_id = d.dept_id
ORDER BY d.dept_name, s.name;

-- Q2: Show every mark of one student
-- Three tables are chained: STUDENT -> MARKS -> SUBJECT.
-- MARKS only has ids, so we join SUBJECT to get the subject name.
-- WHERE picks one student using the unique roll number.
SELECT s.name, sub.subject_name, m.marks_obtained
FROM STUDENT s
JOIN MARKS   m   ON s.student_id = m.student_id
JOIN SUBJECT sub ON m.subject_id = sub.subject_id
WHERE s.roll_no = '0111CS231001'
ORDER BY sub.subject_name;

-- =====================================================
-- SECTION 2: AGGREGATES (GROUP BY)
-- =====================================================

-- Q3: Total and average marks of each student
-- GROUP BY collapses all marks rows of a student into one row.
-- SUM and AVG are calculated per group. ROUND limits decimals.
-- Every non-aggregated column in SELECT must appear in GROUP BY.
SELECT s.roll_no, s.name,
       SUM(m.marks_obtained)           AS total_marks,
       ROUND(AVG(m.marks_obtained), 2) AS average_marks
FROM STUDENT s
JOIN MARKS m ON s.student_id = m.student_id
GROUP BY s.student_id, s.roll_no, s.name
ORDER BY total_marks DESC;

-- Q4: Highest, lowest and average marks in each subject
-- Same idea, but grouped by subject instead of student.
-- COUNT(*) tells how many students have a mark in that subject.
SELECT sub.subject_name,
       MAX(m.marks_obtained)           AS highest,
       MIN(m.marks_obtained)           AS lowest,
       ROUND(AVG(m.marks_obtained), 2) AS average,
       COUNT(*)                        AS students_appeared
FROM SUBJECT sub
JOIN MARKS m ON sub.subject_id = m.subject_id
GROUP BY sub.subject_id, sub.subject_name;

-- Q5: Number of students in each department
-- LEFT JOIN keeps departments even if they have no students (count 0).
-- COUNT(s.student_id) counts only real students. COUNT(*) would count
-- the empty department row as 1, which is wrong.
SELECT d.dept_name, COUNT(s.student_id) AS student_count
FROM DEPARTMENT d
LEFT JOIN STUDENT s ON d.dept_id = s.dept_id
GROUP BY d.dept_id, d.dept_name;

-- =====================================================
-- SECTION 3: HAVING AND CONDITIONS
-- =====================================================

-- Q6: Departments whose average marks are above 65
-- WHERE filters rows BEFORE grouping. HAVING filters groups AFTER grouping.
-- We need a condition on AVG(), so it must go in HAVING.
-- (Threshold 65 is used so the filter removes IT. Try 60 to see all four.)
SELECT d.dept_name, ROUND(AVG(m.marks_obtained), 2) AS avg_marks
FROM DEPARTMENT d
JOIN STUDENT s ON d.dept_id = s.dept_id
JOIN MARKS   m ON s.student_id = m.student_id
GROUP BY d.dept_id, d.dept_name
HAVING AVG(m.marks_obtained) > 65;

-- Q7: Students who failed (below 40) in at least one subject
-- WHERE keeps only failing marks rows.
-- DISTINCT stops a student with two failed subjects appearing twice.
SELECT DISTINCT s.roll_no, s.name
FROM STUDENT s
JOIN MARKS m ON s.student_id = m.student_id
WHERE m.marks_obtained < 40;

-- Q8: Students who passed every subject
-- A student passed everything only if their LOWEST mark is at least 40.
-- So we group per student and test MIN() in HAVING.
SELECT s.roll_no, s.name, MIN(m.marks_obtained) AS lowest_mark
FROM STUDENT s
JOIN MARKS m ON s.student_id = m.student_id
GROUP BY s.student_id, s.roll_no, s.name
HAVING MIN(m.marks_obtained) >= 40;

-- =====================================================
-- SECTION 4: SUBQUERIES AND LEFT JOIN
-- =====================================================

-- Q9: Students whose average is above the overall average
-- The inner query (SELECT AVG(...) FROM MARKS) returns one number:
-- the average of all marks in the table. The outer query compares
-- each student's average against it.
SELECT s.roll_no, s.name, ROUND(AVG(m.marks_obtained), 2) AS avg_marks
FROM STUDENT s
JOIN MARKS m ON s.student_id = m.student_id
GROUP BY s.student_id, s.roll_no, s.name
HAVING AVG(m.marks_obtained) > (SELECT AVG(marks_obtained) FROM MARKS)
ORDER BY avg_marks DESC;

-- Q10: Students with no marks entered
-- LEFT JOIN keeps every student. If a student has no marks row,
-- all MARKS columns come back as NULL. Filtering on NULL finds them.
SELECT s.roll_no, s.name
FROM STUDENT s
LEFT JOIN MARKS m ON s.student_id = m.student_id
WHERE m.student_id IS NULL;

-- =====================================================
-- SECTION 5: WINDOW FUNCTIONS (MySQL 8.0)
-- =====================================================

-- Q11: Rank list of all students by total marks
-- Step 1 (CTE): calculate each student's total with GROUP BY.
-- Step 2: rank those totals. RANK() leaves gaps after a tie (1,2,2,4).
-- DENSE_RANK() does not (1,2,2,3).
-- Note: "rank" and "dense_rank" are reserved words, so use other aliases.
WITH student_totals AS (
    SELECT s.student_id, s.roll_no, s.name,
           SUM(m.marks_obtained) AS total_marks
    FROM STUDENT s
    JOIN MARKS m ON s.student_id = m.student_id
    GROUP BY s.student_id, s.roll_no, s.name
)
SELECT RANK()       OVER (ORDER BY total_marks DESC) AS student_rank,
       DENSE_RANK() OVER (ORDER BY total_marks DESC) AS dense_position,
       name, total_marks
FROM student_totals;

-- Q12: Top 2 students in each department
-- PARTITION BY restarts the ranking inside each department.
-- A window function cannot be used in WHERE of the same SELECT,
-- so we rank inside a CTE and filter in the outer query.
WITH student_totals AS (
    SELECT s.student_id, s.name, s.dept_id,
           SUM(m.marks_obtained) AS total_marks
    FROM STUDENT s
    JOIN MARKS m ON s.student_id = m.student_id
    GROUP BY s.student_id, s.name, s.dept_id
),
ranked AS (
    SELECT d.dept_name, st.name, st.total_marks,
           DENSE_RANK() OVER (PARTITION BY st.dept_id
                              ORDER BY st.total_marks DESC) AS dept_rank
    FROM student_totals st
    JOIN DEPARTMENT d ON st.dept_id = d.dept_id
)
SELECT dept_name, name, total_marks, dept_rank
FROM ranked
WHERE dept_rank <= 2
ORDER BY dept_name, dept_rank;

-- =====================================================
-- SECTION 6: VIEW, PROCEDURE, INDEX
-- =====================================================

-- Q13: Using the view (it hides the 3-table join and the CASE logic)
SELECT * FROM vw_result_sheet WHERE roll_no = '0111CS231001';

-- Q14: How many marks fall in each grade
SELECT grade, COUNT(*) AS total_entries
FROM vw_result_sheet
GROUP BY grade
ORDER BY grade;

-- Stored procedure: full result of one student
-- DELIMITER changes the statement ending to // so MySQL does not
-- stop at the first ; inside the procedure body.
DROP PROCEDURE IF EXISTS get_student_result;

DELIMITER //
CREATE PROCEDURE get_student_result(IN p_roll_no VARCHAR(50))
BEGIN
    -- subject-wise marks and grades
    SELECT subject_name, credits, marks_obtained, grade
    FROM vw_result_sheet
    WHERE roll_no = p_roll_no;

    -- overall total and percentage (each subject is out of 100)
    SELECT SUM(marks_obtained)           AS total_marks,
           ROUND(AVG(marks_obtained), 2) AS percentage
    FROM vw_result_sheet
    WHERE roll_no = p_roll_no;
END //
DELIMITER ;

CALL get_student_result('0111CS231001');

-- Index check: see which indexes exist and whether a query uses them
SHOW INDEX FROM MARKS;
EXPLAIN SELECT * FROM STUDENT WHERE name = 'Aarav Sharma';
EXPLAIN SELECT MAX(marks_obtained) FROM MARKS WHERE subject_id = 1;