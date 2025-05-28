--------    String functions



select first_name, length(first_name)
from employee_demographics
order by 2;

select first_name, upper(first_name)
from employee_demographics
order by 1;


--------  Substring
select first_name, 
left(first_name,4),
right(first_name,4), 
substring(first_name, 3,2),
birth_date,
substring(birth_date, 6,2) as birth_month
from employee_demographics;




----------- Replace


select first_name, replace(first_name, 'A', 'J')
from employee_demographics;




--------- Locate


select locate('j', 'Jen');
select first_name, locate('A',first_name )
from employee_demographics;


---------- concate

select first_name, last_name,
concat(first_name, ' ' , last_name) as full_name
from employee_demographics;


