Select * 
From employee_salary 
where first_name = 'Leslie';


Select * 
From employee_salary 
where salary <=50000 ;


select * 
from employee_demographics
where gender != 'female';

select * 
from employee_demographics
where birth_date > '1985-01-01'
or not gender = 'male';


select * from employee_demographics
where (first_name = 'leslie' and age = 44) or age >55;



select * from employee_demographics
where first_name like 'a_%';