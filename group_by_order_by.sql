select gender 
from employee_demographics
group by gender;

select gender, avg(age), max(age), min(age), count(age)
from employee_demographics
group by gender;



select occupation, salary
from employee_salary
group by occupation, salary;


select *
from employee_demographics
Order by gender, age desc;

