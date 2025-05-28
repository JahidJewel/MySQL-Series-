select * 
from employee_demographics
order by age desc
limit 2, 1;



select gender, avg(age) as age
From employee_demographics
group by gender
having avg(age) > 40;