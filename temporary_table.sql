----------   Temporary tables



create temporary table temp_table
(
first_name varchar(50),
last_name varchar(50),
favourite_movie varchar(150)
);


select * 
from temp_table;


insert into temp_table
values('alex', 'siroski', 'lord of the rings');

select * 
from temp_table;


select *
from employee_salary;


create temporary table salary_over_50k
select *
from employee_salary
where salary>=50000;

select *
from salary_over_50k;