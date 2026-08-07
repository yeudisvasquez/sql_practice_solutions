select first_name, last_name, birth_date 
from patients
where YEAR(birth_date) between 1970 and 1979
order by birth_date asc

select concat(Upper(last_name), ',', lower(first_name)) as full_name 
from patients
order by first_name desc

select province_id, SUM(height) as sum_height
from patients
group by province_id
having sum(height) >= 7000

select * from 
(select province_id, SUM(height) 
 as sum_height FROM patients 
 group by province_id) 
 where sum_height >= 7000;

select max(weight) - min(weight) as weight_delta
from patients 
where last_name = 'Maroni' 

select day(admission_date) as day_number, count(admission_date) as number_of_admissions
from admissions
group by day_number
order by number_of_admissions desc


select * from admissions
where patient_id = 542
group by patient_id
having max(admission_date)

select patient_id, attending_doctor_id, diagnosis 
from admissions
where patient_id % 2!=0
and attending_doctor_id in(1, 5, 19)
or (attending_doctor_id like '%2%' and len(patient_id)=3); 

select first_name, last_name, count(admission_date) as total_number_of_admissions
from doctors as d
join admissions as a
on a.attending_doctor_id = d.doctor_id
group by doctor_id

select first_name, last_name, COUnt(*) 
from doctors d, admissions a 
where a.attending_doctor_id = d.doctor_id
group by d.doctor_id

select doctor_id, concat(first_name,' ', last_name) as full_name, min(admission_date) as first_admission, max(admission_date) as last_admission
from doctors d 
join admissions a 
on a.attending_doctor_id = d.doctor_id
group by doctor_id

select province_name, count(patient_id) as patient_count
from patients p 
join province_names pn
on pn.province_id = p.province_id 
group by pn.province_id
order by patient_count DESC	

select concat(p.first_name,' ', p.last_name) as patient_name, a.diagnosis,
	concat(d.first_name,' ', d.last_name) as doctor_name
from patients p 
join admissions a on a.patient_id = p.patient_id
      join doctors d on d.doctor_id = a.attending_doctor_id
      
select first_name, last_name, count(*) as num_of_duplicates
from patients
group by first_name, last_name
having count(*) > 1

select concat(p.first_name, ' ', p.last_name) as patient_name, 
			round(height / 30.48, 1) as height, 
            round(weight * 2.205) as weight, birth_date,
case 
	when gender = 'M' then 'MALE'
    else 'FEMALE'
end AS gender_type
from patients p 

--this query is the same as the one below.
select p.patient_id, p.first_name, p.last_name
from patients p
where p.patient_id not in(select a.patient_id from admissions a)

--this query is the same as the one above but with different clause use
SELECT
  p.patient_id,
  first_name,
  last_name
from patients p
  left join admissions a on p.patient_id = a.patient_id
where a.patient_id is NULL

--single row using subquery, avg is combined with rounf to get 2 decimals
--on avg visits
select 
	max(number_of_visits) as max_visits,
    min(number_of_visits) as min_visits,
    round(avg(number_of_visits), 2) as average_visits
from (
  select admission_date, count(*) as number_of_visits
  from admissions
  group by admission_date)

--floor(weight/10)*10 groups the numbers into intervals of 10 by dividing them and then multiply by 10
select COUNt(patient_id) as patients_in_group, floor(weight/10)*10 as weight_group
from patients
group by weight_group
order by weight_group desc


select patient_id, weight, height,
case 
	when weight/power(height/100.0,2) >= 30 then '1'
	else '0'
end as isObese 
from patients

select p.patient_id, p.first_name, p.last_name, d.specialty
from patients p 
join admissions a on p.patient_id = a.patient_id
join doctors d on a.attending_doctor_id = d.doctor_id
where a.diagnosis = 'Epilepsy' and d.first_name = 'Lisa'

select distinct p.patient_id, concat((a.patient_id), len(p.last_name), year(p.birth_date))  as temp_password
from patients p 
join admissions a on a.patient_id = p.patient_id


select 
CASE
 	WHEN patient_id % 2 = 0 THEN 'YES' 
    ELSE 'NO'
END AS has_insurance,
sum(case
    when patient_id % 2 = 0 THEN 10
    else 50 
    end) as cost_after_insurance
from admissions
group by has_insurance

--Show the provinces that has more patients identified as 'M' than 'F'. Must only show full province_name
select pr.province_name 
from patients p 
join province_names pr on pr.province_id = p.province_id
group by pr.province_name 
having count(case when p.gender = 'M' then 1 end) > count(case when p.gender = 'F' then 1 end)

select * from patients
where patient_id % 2 = 1 
	and first_name like '__r%' 
	and gender = 'F' 
    and month(birth_date) in (02, 05, 12)
    and weight between 60 and 80
    and city = 'Kingston';
    
select 
	concat(
	round
    	((count(*) * 100.0 / (select count(*) from patients)), 2), '%'
        )
      	as male_percentage
	from patients
where gender = 'M'

--For each day display the total amount of admissions on that day. Display the amount changed from the previous date.
WITH daily_counts AS (
  SELECT
  	admission_date,
  	COUNT(patient_id) AS number_of_admissions
  FROM admissions
  group by admission_date
  order by admission_date
)
select 
	admission_date,
    number_of_admissions,
	number_of_admissions 
    	- LAG(number_of_admissions) OVER(order by admission_date) AS admission_count_change
FROM daily_counts

/*
Display every patient that has at least one admission and show 
their most recent admission along with the patient and doctor's 
full name.
*/
SELECT CONCAT(p.first_name, + " ", + p.last_name) AS patient_name,
	admission_date,
	CONCAT(d.first_name, + " ", + d.last_name) AS doctor_name
FROM patients p
JOIN admissions a ON p.patient_id = a.patient_id
JOIN doctors d ON a.attending_doctor_id = d.doctor_id
WHERE a.admission_date = ( --Sub query
  select MAX(a2.admission_date)
  FROM admissions a2
  WHERE a2.patient_id = p.patient_id
  );

--Sort the province names in ascending order in such a way that the province 'Ontario' is always on top.
SELECT province_name
FROM province_names
ORDER BY (
  CASE
  	WHEN province_name = 'Ontario' THEN 0 
  	ELSE 1
  END
  );

--We need a breakdown for the total amount of admissions each doctor has started each year. Show the doctor_id, doctor_full_name, specialty, year, total_admissions for that year.
SELECT 
    d.doctor_id, 
 	CONCAT(d.first_name, + " ", + d.last_name) AS doctor_name,
    d.specialty,
    YEAR(a.admission_date) AS selected_year,
    COUNT(a.patient_id) AS total_admissions
FROM doctors d
	LEFT JOIN admissions a ON d.doctor_id = a.attending_doctor_id
group by doctor_name, selected_year
order by doctor_id;
