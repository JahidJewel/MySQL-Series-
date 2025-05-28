---------- Case_Statement

select first_name, last_name,age, 
case
		
        when age<=30 then 'young'
        when age between 31 and 50 then 'middle age'
        when age >= 50 then 'Time to retire'
        
end as current_status
from employee_demographics;

------------ 5% bonus for salary less than 50000
-----------  7% bonus for salary more than or equal to 50000
------------  10% bonus for finance department


select first_name, last_name, salary,
case
	when salary <50000 then  salary + (salary *.05)  
    when salary >=50000 then salary + (salary*.07)
end as new_salary, 
case
	when dept_id = 6 then  (salary * .10)
end as bonus_salary
from employee_salary;


