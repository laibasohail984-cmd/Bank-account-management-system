/*
BANK MANAGEMENT SYSTEM - DBMS LAB QUERY FILE
Database: bank_management
Purpose: Show DBMS lab operations to the instructor.

IMPORTANT:
1. This file is a collection of examples; it is NOT the database backup.
2. Read each query before running it.
3. Queries marked "DEMO ONLY" or commented with -- are examples and are not executed.
4. Do not run DROP DATABASE, DROP TABLE, or DELETE on your project tables.
5. Table/column names are based on the current Bank Management System schema.
*/

USE bank_management;


/* =========================================================
   1. DRL / BASIC SELECT QUERIES
   ========================================================= */

-- Show all customers
SELECT * FROM customers;

-- Show all branches
SELECT * FROM branches;

-- Show all accounts
SELECT * FROM accounts;

-- Show all transactions
SELECT * FROM transactions;

-- Select specific columns and use aliases
SELECT full_name AS customer_name, branch_id AS assigned_branch
FROM customers;

-- DISTINCT: show unique branch IDs used by customers
SELECT DISTINCT branch_id
FROM customers;

-- WHERE: filter rows
SELECT * FROM accounts
WHERE balance > 0;

-- Comparison and logical operators: AND, OR, NOT
SELECT * FROM accounts
WHERE balance >= 0 AND status = 'Active';

SELECT * FROM accounts
WHERE status = 'Active' OR status = 'Frozen';

SELECT * FROM accounts
WHERE NOT status = 'Closed';

-- BETWEEN
SELECT * FROM accounts
WHERE balance BETWEEN 1000 AND 100000;

-- IN
SELECT * FROM accounts
WHERE status IN ('Active', 'Frozen');

-- LIKE
SELECT * FROM customers
WHERE full_name LIKE 'A%';

-- IS NULL / IS NOT NULL
SELECT * FROM customers
WHERE branch_id IS NULL;

SELECT * FROM customers
WHERE branch_id IS NOT NULL;

-- ORDER BY
SELECT * FROM accounts
ORDER BY balance DESC;

-- LIMIT
SELECT * FROM customers
LIMIT 5;


/* =========================================================
   2. AGGREGATE FUNCTIONS, GROUP BY, HAVING
   ========================================================= */

-- COUNT, SUM, AVG, MIN, MAX
SELECT COUNT(*) AS total_accounts
FROM accounts;

SELECT SUM(balance) AS total_balance
FROM accounts;

SELECT AVG(balance) AS average_balance,
       MIN(balance) AS minimum_balance,
       MAX(balance) AS maximum_balance
FROM accounts;

-- GROUP BY
SELECT account_type, COUNT(*) AS number_of_accounts
FROM accounts
GROUP BY account_type;

-- HAVING: filter groups after aggregation
SELECT account_type, COUNT(*) AS number_of_accounts
FROM accounts
GROUP BY account_type
HAVING COUNT(*) > 1;


/* =========================================================
   3. JOINS
   ========================================================= */

-- INNER JOIN: only matching customers and branches
SELECT c.full_name AS customer_name, b.branch_name
FROM customers AS c
INNER JOIN branches AS b ON c.branch_id = b.id;

-- LEFT JOIN: all customers, including customers without a matching branch
SELECT c.full_name AS customer_name, b.branch_name
FROM customers AS c
LEFT JOIN branches AS b ON c.branch_id = b.id;

-- RIGHT JOIN: all branches, including branches without matching customers
SELECT c.full_name AS customer_name, b.branch_name
FROM customers AS c
RIGHT JOIN branches AS b ON c.branch_id = b.id;

-- FULL OUTER JOIN workaround for MariaDB/MySQL
SELECT c.full_name AS customer_name, b.branch_name
FROM customers AS c
LEFT JOIN branches AS b ON c.branch_id = b.id
UNION
SELECT c.full_name AS customer_name, b.branch_name
FROM customers AS c
RIGHT JOIN branches AS b ON c.branch_id = b.id;

-- CROSS JOIN: every customer paired with every branch
SELECT c.full_name AS customer_name, b.branch_name
FROM customers AS c
CROSS JOIN branches AS b;

-- SELF JOIN: pairs of different customers assigned to the same branch
SELECT c1.full_name AS customer_1,
       c2.full_name AS customer_2,
       c1.branch_id
FROM customers AS c1
JOIN customers AS c2
  ON c1.branch_id = c2.branch_id
 AND c1.id < c2.id;


/* =========================================================
   4. SUBQUERIES
   ========================================================= */

-- Single-row subquery: accounts with balance above the average
SELECT *
FROM accounts
WHERE balance > (SELECT AVG(balance) FROM accounts);

-- Multi-row subquery with IN
SELECT *
FROM customers
WHERE branch_id IN (
    SELECT id
    FROM branches
);

-- EXISTS: branches that have at least one customer
SELECT b.*
FROM branches AS b
WHERE EXISTS (
    SELECT 1
    FROM customers AS c
    WHERE c.branch_id = b.id
);

-- NOT EXISTS: branches with no matching customers
SELECT b.*
FROM branches AS b
WHERE NOT EXISTS (
    SELECT 1
    FROM customers AS c
    WHERE c.branch_id = b.id
);

-- ANY: accounts with balance greater than at least one transaction amount
SELECT *
FROM accounts
WHERE balance > ANY (
    SELECT amount
    FROM transactions
);

-- ALL: accounts with balance greater than every transaction amount
SELECT *
FROM accounts
WHERE balance > ALL (
    SELECT amount
    FROM transactions
);

-- Correlated subquery: branches that have customers
SELECT b.id, b.branch_name
FROM branches AS b
WHERE EXISTS (
    SELECT 1
    FROM customers AS c
    WHERE c.branch_id = b.id
);


/* =========================================================
   5. SET OPERATORS: UNION AND UNION ALL
   ========================================================= */

-- UNION removes duplicate values
SELECT branch_id AS related_branch
FROM customers
WHERE branch_id IS NOT NULL
UNION
SELECT id AS related_branch
FROM branches;

-- UNION ALL keeps duplicate values
SELECT branch_id AS related_branch
FROM customers
WHERE branch_id IS NOT NULL
UNION ALL
SELECT id AS related_branch
FROM branches;


/* =========================================================
   6. DDL: CREATE DATABASE / TABLE, ALTER, INDEX
   ========================================================= */

-- The project database already exists; do not recreate it.
-- CREATE DATABASE bank_management;

-- DEMO ONLY: create a separate practice table
-- Run only if you want a small DDL demonstration.
-- CREATE TABLE lab_demo (
--     id INT AUTO_INCREMENT PRIMARY KEY,
--     student_name VARCHAR(100) NOT NULL,
--     email VARCHAR(150) UNIQUE,
--     age INT DEFAULT 18,
--     CHECK (age >= 0)
-- );

-- DEMO ONLY: add a column to the practice table
-- ALTER TABLE lab_demo ADD COLUMN city VARCHAR(100);

-- DEMO ONLY: modify a column in the practice table
-- ALTER TABLE lab_demo MODIFY COLUMN city VARCHAR(150);

-- DEMO ONLY: drop a column from the practice table
-- ALTER TABLE lab_demo DROP COLUMN city;

-- DEMO ONLY: create and drop an index on the practice table
-- CREATE INDEX idx_lab_demo_name ON lab_demo (student_name);
-- DROP INDEX idx_lab_demo_name ON lab_demo;

-- IMPORTANT: these are destructive examples; do not run on project tables.
-- DROP TABLE lab_demo;
-- DROP DATABASE bank_management;


/* =========================================================
   7. CONSTRAINTS
   ========================================================= */

-- Existing project tables already have primary keys, unique keys,
-- foreign keys, defaults and CHECK constraints.
-- Do not add duplicate constraints to the project tables.

-- DEMO ONLY: example table showing constraints
-- CREATE TABLE lab_constraints_demo (
--     id INT PRIMARY KEY,
--     username VARCHAR(50) NOT NULL UNIQUE,
--     age INT DEFAULT 18 CHECK (age >= 0)
-- );

-- Common constraint meanings:
-- PRIMARY KEY: uniquely identifies each row
-- FOREIGN KEY: links a column to a key in another table
-- NOT NULL: value is required
-- UNIQUE: duplicate values are not allowed
-- DEFAULT: value used when no value is supplied
-- CHECK: validates a condition


/* =========================================================
   8. DML: INSERT, UPDATE, DELETE
   ========================================================= */

-- DML commands change data. The examples below are commented out
-- so they cannot accidentally change your project data.

-- DEMO ONLY: use the lab_demo table, not customers/accounts.
-- INSERT INTO lab_demo (student_name, email, age)
-- VALUES ('Demo Student', 'demo@example.com', 20);

-- UPDATE example (demo table only)
-- UPDATE lab_demo
-- SET age = 21
-- WHERE email = 'demo@example.com';

-- DELETE example (demo table only)
-- DELETE FROM lab_demo
-- WHERE email = 'demo@example.com';

-- Insert a NULL value example (demo table only; email allows NULL)
-- INSERT INTO lab_demo (student_name, email, age)
-- VALUES ('Another Demo', NULL, DEFAULT);


/* =========================================================
   9. TRANSACTIONS: COMMIT AND ROLLBACK
   ========================================================= */

-- Transaction example for safe practice on a dedicated demo table only.
-- START TRANSACTION;
-- INSERT INTO lab_demo (student_name, email, age)
-- VALUES ('Transaction Demo', 'transaction@example.com', 22);
-- ROLLBACK;  -- cancels the change
--
-- For a practice transaction you want to keep, use COMMIT instead
-- of ROLLBACK. Do not experiment on live project account balances.


/* =========================================================
   10. CREATE TABLE AS SELECT (SELECT INTO equivalent)
   ========================================================= */

-- MariaDB/MySQL equivalent of SELECT INTO a new table:
-- DEMO ONLY: creates a new table containing query results.
-- CREATE TABLE lab_accounts_copy AS
-- SELECT id, account_type, balance, status
-- FROM accounts;

-- If you create this demo copy, remove it only when you are sure
-- it is not needed:
-- DROP TABLE lab_accounts_copy;


/* =========================================================
   END OF DBMS LAB QUERY FILE
   ========================================================= */
