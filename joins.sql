select dem.employee_id, age, occupation
from employee_demographics as dem
inner join employee_salary as sal
on dem.employee_id = sal.employee_id;


select *
from employee_demographics as dem
right join employee_salary as sal
on dem.employee_id = sal.employee_id;


select *
from employee_demographics as dem
left join employee_salary as sal
on dem.employee_id = sal.employee_id;


select *
from employee_demographics as dem
inner join employee_salary as sal
on dem.employee_id = sal.employee_id
inner join parks_departments as pd
on sal.dept_id = pd.department_id
;


select dem.first_name, dem.last_name,
sal.occupation, sal.salary, pd.department_name
from employee_demographics as dem
inner join employee_salary as sal
on dem.employee_id = sal.employee_id
inner join parks_departments as pd
on sal.dept_id = pd.department_id
;


