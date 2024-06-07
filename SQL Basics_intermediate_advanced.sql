# SQL Beginners

-- SELECT STATEMENT 

SELECT * FROM employee_demographics;

SELECT first_name, last_name, birth_date
FROM employee_demographics;

SELECT first_name, last_name, birth_date,
age,
(age + 10) * 10 as new_age
FROM employee_demographics;
-- PEMDAS - parentheses,exponents,multiplication,division,addition,subraction

SELECT 
-- distinct is to remove duplicates and show unique code
distinct gender
FROM employee_demographics;

-- WHERE STATEMENT

select *
from employee_salary
where first_name = 'leslie'
;

select *
from employee_salary
where salary > 50000
;
-- in comparision operator we can use >, >=, <, <=, != or <>
-- ex for not equal

select *
from employee_demographics
where gender <> 'female'
;

-- logical operators are AND, OR, NOT

select *
from employee_demographics
where birth_date > '1985-01-01'
AND gender = 'male'
;

select *
from employee_demographics
where birth_date > '1985-01-01'
OR gender = 'male'
;

select *
from employee_demographics
where birth_date > '1985-01-01'
OR NOT gender = 'male'
;

-- using PEMDAS

select *
from employee_demographics
where (first_name = 'leslie' AND age = 44) OR age > 55 # this is called isolated conditions
;

-- LIKE Statement
-- wildcards in LIKE STATEMENT are %(percentage) and _(underscore)

select *
from employee_demographics
WHERE first_name LIKE 'jer%' -- try this (%er%, a%)
;

select *
from employee_demographics
WHERE first_name LIKE 'a__' -- try this (a___, a___%)
;

select *
from employee_demographics
WHERE birth_date LIKE '1989%'
;

-- GROUP BY
-- AVG(age), MAX(age), MIN(age), COUNT(age) this is aggragate functions

select gender, AVG(age), MAX(age), MIN(age), COUNT(age)
from employee_demographics
GROUP BY gender;

-- ORDER BY
-- ASC DESC

select *
from employee_demographics
ORDER BY gender, age DESC;

-- HAVING vs WHERE
-- Aggregated functions works after GROUP BY
-- to use aggregated functions you need to use HAVING clause

select gender, AVG(age)
from employee_demographics
GROUP BY gender
HAVING AVG(age) > 40;

-- using both WHERE and HAVING

select occupation, AVG(salary)
from employee_salary
WHERE occupation LIKE '%manager%'
GROUP BY occupation
HAVING AVG(salary) > 75000;

-- LIMIT

SELECT *
FROM employee_demographics
order by age asc
LIMIT 3;

-- ALIASING keywords AS

SELECT gender, AVG(age) AS avg_age
from employee_demographics
group by gender
having AVG(age) > 40;

# END of SQL Beginners -----------------------------------------------------

# SQL Intermediate

-- JOINS

SELECT *
FROM employee_demographics;

SELECT *
FROM employee_salary;

-- INNER JOIN

SELECT *
FROM employee_demographics AS demo
INNER JOIN employee_salary AS sal
	ON demo.employee_id = sal.employee_id;

-- OUTER JOIN # left join, right join

SELECT *
FROM employee_demographics AS demo
LEFT JOIN employee_salary AS sal
	ON demo.employee_id = sal.employee_id;

SELECT *
FROM employee_demographics AS demo
RIGHT JOIN employee_salary AS sal
	ON demo.employee_id = sal.employee_id;

-- SELF JOIN

	# for example assign the santa for employee within the table

SELECT emp1.employee_id,
emp1.first_name AS santa_name,
emp2.first_name AS emp_name
FROM employee_salary AS emp1
JOIN employee_salary AS emp2
	ON emp1.employee_id + 1 = emp2.employee_id
;

-- Joining multiple table together
	# take parks_departments table for reference

select *
from parks_departments;

SELECT *
FROM employee_demographics AS demo			# table1
INNER JOIN employee_salary AS sal			# table2
	ON demo.employee_id = sal.employee_id
INNER JOIN parks_departments AS pd			# table3
	ON sal.dept_id = pd.department_id
;

-- UNIONS

SELECT first_name, last_name, 'Old Men' AS Label
from employee_demographics
where age > 40 AND gender = 'male'
UNION
SELECT first_name, last_name, 'Old Women' AS Label
from employee_demographics
where age > 40 AND gender = 'female'
UNION
SELECT first_name, last_name, 'Highly paid employee' AS Label
from employee_salary
where salary > 70000
order by first_name
;

-- String functions
	# LENGTH, UPPER, LOWER, TRIM(LTRIM, RTRIM)
    # LEFT, RIGHT, SUBSTRING, REPLACE, LOCATE
    # CONCAT

SELECT first_name, length(first_name)	# please try other functions like (UPPER, LOWER)
FROM employee_demographics;

SELECT trim('            Remove the space          ')	# please try other functions like (LTRIM, RTRIM)
FROM employee_demographics;

SELECT first_name,
left(first_name,4),
right(first_name,4),
SUBSTRING(first_name,3,2)
FROM employee_demographics;

SELECT first_name,
REPLACE(first_name, 'e','l')
FROM employee_demographics;

SELECT first_name,
LOCATE('LE', first_name)
FROM employee_demographics;

SELECT first_name, last_name,
CONCAT(first_name,' ',last_name) AS fullname
FROM employee_demographics;

-- CASE statement is act like if else condition

 # example 1
SELECT first_name, last_name, age,
CASE
	WHEN age < 30 THEN 'Young'
    WHEN age BETWEEN 31 AND 50 THEN 'Old'
    WHEN age >=50 THEN 'ON DEATH DOOR'
END AS Age_bar
FROM employee_demographics;

	# example 2
		-- Pay Increase and Bonus
		-- < 50000 = 5%
		-- > 50000 = 7%
		-- Finance dept = 10% Bonus
select first_name, last_name, salary,
CASE
	WHEN salary < 50000 THEN salary * 1.05
    When salary > 50000 then salary * 1.07
    when dept_id = 6 then salary * 1.10
END AS new_salary,
CASE
    when dept_id = 6 then salary * .10
END AS Bonus
from employee_salary;

-- Subqueries

	# Subqueries with WHERE statement
SELECT *
FROM employee_demographics
WHERE employee_id IN (
						select employee_id
                        from employee_salary
                        where dept_id = 1
);

	# Subqueries with SELECT statement

SELECT first_name, salary,
(
select AVG(salary)
from employee_salary
)
FROM employee_salary;

	# Subqueries with FROM statement

SELECT AVG(max_age)
FROM
(select gender, 
AVG(age) AS avg_age, 
MAX(age) AS max_age, 
MIN(age) AS min_age, 
COUNT(age)
from employee_demographics
group by gender) AS agg_table
;

-- Window Functions

	# For avg with window functions

SELECT dem.first_name, dem.last_name, gender,
AVG(salary) OVER(PARTITION BY gender)
FROM employee_demographics as dem
JOIN employee_salary as sal
	ON dem.employee_id = sal.employee_id;
	
	# For SUM with window functions

SELECT dem.first_name, dem.last_name, gender, salary,
SUM(salary) OVER(PARTITION BY gender ORDER BY dem.employee_id) AS Rolling_total
FROM employee_demographics as dem
JOIN employee_salary as sal
	ON dem.employee_id = sal.employee_id;
    
    # For ROW_NUMBER with window functions

SELECT dem.first_name, dem.last_name, gender, salary,
ROW_NUMBER() OVER(PARTITION BY GENDER order by gender desc)
FROM employee_demographics as dem
JOIN employee_salary as sal
	ON dem.employee_id = sal.employee_id;
    
    # For RANK & DENSE_RANK with window functions

SELECT dem.first_name, dem.last_name, gender, salary,
ROW_NUMBER() OVER(PARTITION BY GENDER order by gender desc) AS row_num,
RANK() OVER(PARTITION BY GENDER order by salary desc) as rank_num,
DENSE_RANK() OVER(PARTITION BY GENDER order by salary desc) as dense_rank_NUM
FROM employee_demographics as dem
JOIN employee_salary as sal
	ON dem.employee_id = sal.employee_id;

# END of SQL Intermediate -----------------------------------------------------

# SQL Advanced

-- CTEs -- Common Table Expression
-- keywords as WITH

	# example 1
WITH CTE_example AS
(
SELECT gender, AVG(salary) avg_sal, MAX(salary) max_sal, MIN(salary) min_sal, COUNT(salary) count_sal
from employee_demographics as dem
JOIN employee_salary as sal
	ON dem.employee_id = sal.employee_id
group by gender
)
SELECT avg(avg_sal)
from CTE_example
;

	# example 2

WITH CTE_example1 AS
(
SELECT employee_id, gender, birth_date
from employee_demographics
where birth_date > '1985-01-01'
),
CTE_example2 AS
(
SELECT employee_id, salary
from employee_salary
where salary > 50000
)
SELECT * 
FROM CTE_example1
JOIN CTE_example2
	on CTE_example1.employee_id = CTE_example2.employee_id
;

-- Temporary Tables

CREATE temporary TABLE salary_over_50k
select * 
from employee_salary
where salary >= 50000;

SELECT * from salary_over_50k;

-- Stored Procedures
	# to store the SQL queries and use it over and over again
    
DELIMITER $$
CREATE PROCEDURE sample_storage()
BEGIN
	SELECT *
    FROM employee_salary
    WHERE salary >= 50000;
END $$
DELIMITER ;

CALL sample_storage();

	#example 2
DELIMITER $$
CREATE PROCEDURE sample_storage2(in_employee_id INT)
BEGIN
	SELECT salary
    FROM employee_salary
    WHERE employee_id = in_employee_id;
END $$
DELIMITER ;

CALL sample_storage2(5);

	#example 3
DELIMITER $$
CREATE PROCEDURE sample_storage3(in_employee_id INT)
BEGIN
	SELECT *
    FROM employee_salary
    WHERE employee_id = in_employee_id;
END $$
DELIMITER ;

CALL sample_storage3(9);

-- Triggers

SELECT * FROM employee_salary;
SELECT * FROM employee_demographics;

DELIMITER $$
CREATE TRIGGER employee_insert
	AFTER INSERT ON employee_salary
	FOR EACH ROW
BEGIN
	INSERT INTO employee_demographics (employee_id, first_name, last_name)
    VALUES (new.employee_id, new.first_name, new.last_name);
END $$
DELIMITER ;

INSERT INTO employee_salary (employee_id, first_name, last_name, occupation, salary, dept_id)
VALUES (13, 'Jean-Ralphio', 'Saperstein', 'Entertainment 720 CEO', 1000000, null);

-- Events

select * from employee_demographics;

DELIMITER $$
CREATE EVENT delete_retirees
ON SCHEDULE EVERY 30 second
DO
BEGIN
	DELETE
    FROM employee_demographics
    WHERE age >=60;
END $$
DELIMITER ;

SHOW VARIABLES LIKE 'EVENT%';

# END of SQL Advanced Queries -----------------------------------------------------











