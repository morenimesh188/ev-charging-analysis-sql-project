-- EV CHARGING INDIA PROJECT QUERRY SOLVING

USE ev_charging_india;

select * from users;
select count(*) from users;

select * from vehicles;
select count(*) from vehicles;

select * from charging_stations;
select count(*) from charging_stations;

select * from charging_sessions;
select count(*) from charging_sessions;

select * from payments;
select count(*) from payments;

select * from station_reviews;
select count(*) from station_reviews;


-- 1	Add a column named loyalty_points (INT, DEFAULT 0) to the users table.
alter table users 
add loyalty_points int default 0; 

-- 2	Rename the column loyalty_points to reward_points in the users table.
alter table users
rename column loyalty_points to reward_points;

-- 3	Change the data type of reward_points to DECIMAL(8,2) in the users table.
alter table users
modify column reward_points decimal(8,2);

-- 4	Add a column charging_efficiency_pct DECIMAL(5,2) to charging_sessions.
alter table charging_sessions
add charging_efficiency_pct decimal(5,2);

-- 5	Create a new table ev_brands (brand_id INT PK, brand_name VARCHAR(100), country VARCHAR(50)).
create table ev_brands (
brand_id int primary key,
brand_name varchar(100),
country varchar(50)
);

-- 6	Drop the ev_brands table you just created.	DROP TABLE	Easy.
drop table ev_brands;

-- 7	Add a UNIQUE constraint on vehicles.registration_number (it already exists — observe the error and explain it).	
show tables;
describe vehicles; -- the registration_number is already has a unique constraints.

-- 8	Add an index on charging_sessions.station_id to speed up station-based queries.
create index idx_station_id
on charging_sessions(station_id);
SHOW INDEX FROM charging_sessions;

-- 9	Insert a new user: yourself (or a fictional name) with city = your city, user_type = Commuter.
select * from users;
describe users;

INSERT INTO users
(full_name, email, phone, city, user_type, joined_date, reward_points)
VALUES
(
    'Nimesh More','morenimesh188@gmail.com',8928849995,'Mumbai','Casual_Driver','2022-08-17',0
);

-- 10	Insert a vehicle for the user you just created (use the user_id you inserted).
select *from vehicles;
select*from users;

insert into vehicles
(user_id,model,brand,battery_capacity_kwh,vehicle_age_years,registration_number,is_active) 
value ((select user_id
from users
where email='morenimesh188@gmail.com'),
'Tata Nexon EV','Tata Motors',40.5,3,'MH46AL1643',1);

-- 11	Update the charging_efficiency_pct column for all sessions: set it to (energy_consumed_kwh / battery_capacity_kwh) * 100. You will need to JOIN charging_sessions with vehicles
select * from charging_sessions;
select * from vehicles;

UPDATE charging_sessions cs
JOIN vehicles v
    ON cs.vehicle_id = v.vehicle_id
SET cs.charging_efficiency_pct =
    ROUND(
        (cs.energy_consumed_kwh / v.battery_capacity_kwh) * 100,
        2
    );

-- 12	Increase the price_per_kwh by 10% for all DC Fast and DC Rapid stations in Mumbai.
select * from charging_stations;

SET SQL_SAFE_UPDATES = 0;

UPDATE charging_stations
SET price_per_kwh = price_per_kwh * 1.10
WHERE charger_type IN ('DC Fast', 'DC Rapid')
  AND city = 'mumbai';

SET SQL_SAFE_UPDATES = 1;

-- 13	Mark all sessions where charging_cost_inr = 0 as having a refunded payment status (update payments table).
select*from payments;

set sql_safe_updates = 0;
UPDATE payments
SET payment_status = 'Refunded'
WHERE amount_inr = 0;
set sql_safe_updates = 1;

-- 14	Delete the test user and their vehicle that you inserted in tasks 9 and 10,

delete from vehicles
where user_id=(
select user_id
from users
where email = 'morenimesh188@gmail.com'
);
delete from users
where email ='morenimesh188@gmail.com';

-- 15	Insert 3 station reviews manually for any 3 session IDs of your choice (ratings: 5, 3, 1).
select*from station_reviews;
select * from charging_sessions;


INSERT INTO station_reviews
(session_id, user_id, station_id, rating, comment, reviewed_at)

SELECT session_id, user_id, station_id,
       5,
       'Excellent charging speed.',
       '2024-03-08 17:22:48'
FROM charging_sessions
WHERE session_id = 1

UNION ALL

SELECT session_id, user_id, station_id,
       3,
       'Slot was occupied for a long time.',
       '2024-03-08 18:22:48'
FROM charging_sessions
WHERE session_id = 2

UNION ALL

SELECT session_id, user_id, station_id,
       1,
       'No shelter available.',
       '2024-03-08 18:22:48'
FROM charging_sessions
WHERE session_id = 4;

-- 16	List all users from Bengaluru. Show full_name, email, user_type.alter.
select*from users;

select full_name,email,user_type,city
from users
where city = 'bengaluru';

-- 17	Show the top 10 most expensive charging sessions (highest charging_cost_inr). Display session_id, user_id, charging_cost_inr.
select*from charging_sessions;

select session_id,user_id,charging_cost_inr
from charging_sessions
order by charging_cost_inr desc
limit 10;

-- 18	Count how many users belong to each user_type. Show user_type and count.
select*from users;

select count(user_type)as count_of_user_type,user_type
from users
group by user_type;

-- 19 Find the average, minimum, and maximum energy_consumed_kwh across all sessions.
select*from charging_sessions;

select min(energy_consumed_kwh) as min_energy_consumed_kwh,
 avg(energy_consumed_kwh) as avg_energy_consumed_kwh,
 max(energy_consumed_kwh) as max_energy_consumed_kwh
 from charging_sessions;

-- 20	List all distinct charger types available in the charging_stations table.
select *from charging_stations;

select distinct(charger_type)
from charging_stations;

-- 21	Find all charging stations that are NOT operational (is_operational = 0). Show station_name, city, operator.
select *from charging_stations;

select station_name,city,operator,is_operational
from charging_stations
where is_operational = '0';

-- 22	Show total energy consumed and total revenue (charging_cost_inr) per city of the charging station. Sort by total revenue descending.
select *from charging_stations;
select *from charging_sessions;

select
cst.city as city,
max(cse.energy_consumed_kwh) as total_energy_consumed,
max(cse.charging_cost_inr) as total_revenue
from charging_sessions cse
join charging_stations cst
on cse.station_id=cst.station_id
group by city
order by total_revenue desc;

-- 23	List sessions that happened on a Saturday or Sunday.
select *from charging_sessions;

select * 
from charging_sessions
where day_of_week in ('Saturday','Sunday');

-- 24	Find all sessions where the battery was more than 80% charged at the end (soc_end_pct > 80) but started below 30% (soc_start_pct < 30).
select *from charging_sessions;

select *
from charging_sessions
where soc_start_pct < '30' 
and soc_end_pct > '80';

-- 25	Show how many sessions happened per time_of_day slot (Morning, Afternoon, Evening, Night). Order from most to least.
select *from charging_sessions;

select count(time_of_day) as cnt_time_of_day,time_of_day
from charging_sessions
group by time_of_day
order by cnt_time_of_day desc;

-- 26	Find cities where the average price_per_kwh across stations is greater than 5 INR.
select*from charging_stations;

select city,avg(price_per_kwh) as avg_price
from charging_stations
group by city
having avg_price > 5;

-- 27	List all operators that have more than 5 stations. Show operator name and station count.
select*from charging_stations;
 
select operator,count(station_name) as count
from charging_stations
group by operator
having count > 5;

-- 28	Show the number of sessions per vehicle model. (Hint: JOIN charging_sessions with vehicles.)
select*from charging_sessions;
select*from vehicles;

select v.model as v_model,
count(cse.session_id) as total_sessions
from charging_sessions cse
join vehicles v
on cse.vehicle_id = v.vehicle_id
group by v_model
order by total_sessions desc;

-- 29	Categorise each session as "Low Cost" (< ₹100), "Medium Cost" (₹100–₹500), or "High Cost" (> ₹500) using CASE WHEN. Show session_id, charging_cost_inr, and the category.
select*from charging_sessions;

select session_id,charging_cost_inr,
case 
when charging_cost_inr < 100 then ' low cost'
when charging_cost_inr between 100 and 500 then 'medium cost'
when charging_cost_inr < 500 then 'high cost'
end as category
from charging_sessions;

-- 30	Label each station's charger speed: "Slow" for AC Slow, "Moderate" for AC Fast, "Fast" for DC Fast, "Ultra-Fast" for DC Rapid.
select * from charging_stations;

select station_id,station_name,city,charger_type,
case
when charger_type = 'AC Slow' then 'slow'
when charger_type = 'AC Fast' then 'moderate'
when charger_type = 'DC Fast' then 'fast'
when charger_type = 'DC Rapid' then 'ultra fast'
end as charging_speed
from charging_stations;

-- 31	Show each session and a column called soc_gained = soc_end_pct - soc_start_pct. Categorise it as "Small Charge" (< 20%), "Medium Charge" (20–50%), "Full Charge" (> 50%).
select * from charging_sessions;

select session_id,soc_start_pct,soc_end_pct,
soc_end_pct - soc_start_pct AS soc_gained,
case 
when soc_end_pct - soc_start_pct < 20 then 'small charge'
when soc_end_pct - soc_start_pct between 20 and 50 then 'medium charge'
when soc_end_pct - soc_start_pct > 50 then 'full charge'
end as charge_category
from charging_sessions;

-- 32	Show all reviews. For rows where comment IS NULL, display "No comment provided" instead. Use IFNULL.
select*from station_reviews;

select session_id,user_id,station_id,rating,
ifnull(comment,'no comment provided') as comment
from station_reviews;

-- 33	For each payment, show amount_inr. If amount_inr is 0 (failed payment), display "Payment Pending" using COALESCE with NULLIF
select * from payments;

select payment_id,amount_inr,
coalesce(nullif(amount_inr,0),'payment pending') as payment_status
from payments;

-- 34	Classify users by loyalty: users who joined before 2023-01-01 are "Early Adopter", others are "Regular". Show full_name, joined_date, and the label
select * from users;

select full_name,joined_date,
case
when joined_date < '2023-01-01' then 'Early Adapter'
else 'regular'
end as loyalty_label
from users;

-- 35	Show each charging session along with the user's full_name and city. Use an INNER JOIN between charging_sessions and users.
select*from users;
select*from charging_sessions;

select cs.session_id,u.user_id,u.full_name,u.city
from users u
inner join charging_sessions cs
on u.user_id = cs.user_id;

-- 36	For each session, show the vehicle model and battery capacity along with the session's energy_consumed_kwh. JOIN charging_sessions with vehicles.
select*from charging_sessions;
select*from vehicles;

select cs.session_id,cs.user_id,v.vehicle_id,v.model,v.battery_capacity_kwh,cs.energy_consumed_kwh
from charging_sessions cs
inner join vehicles v
on cs.user_id = v.user_id;

-- 37	Show each session with the station name, area, and charger type. JOIN charging_sessions with charging_stations.
select*from charging_sessions;
select*from charging_stations;

select cse.session_id,cse.station_id,cst.station_name,cst.area,cst.charger_type
from charging_sessions cse
inner join charging_stations cst
on cse.station_id = cst.station_id
order by cse.session_id;

-- 38	Write a 3-table JOIN: show full_name (users), model (vehicles), station_name (charging_stations), and charging_cost_inr (charging_sessions) for every session.
select*from users;
select*from vehicles;
select*from charging_sessions;
select*from charging_stations;

select cse.session_id,u.full_name,v.model,cst.station_name,cse.charging_cost_inr
from charging_sessions cse
inner join users u
on cse.user_id = u.user_id
inner join vehicles v
on cse.vehicle_id = v.vehicle_id
inner join charging_stations cst
on cse.station_id = cst.station_id
order by cse.session_id;

-- 39	Show all users and the total number of sessions they have had. Include users who have had ZERO sessions. Use a LEFT JOIN
select*from users;
select*from charging_sessions;

select u.user_id,u.full_name,count(cs.session_id) as total_sessions
from users u
left join charging_sessions cs
on u.user_id = cs.user_id
group by u.user_id;

-- 40	Show all charging stations and their average rating from station_reviews. Include stations that have never been reviewed (show NULL or 0 for those).
select*from charging_stations;
select*from station_reviews;

select cs.station_id,cs.station_name,
coalesce(avg(cr.rating),0) as avg_rating
from charging_stations cs
left join station_reviews cr
on cs.station_id = cr.station_id
group by cs.station_id;

-- 41	Find all users who have NEVER left a review. Use a LEFT JOIN between users and station_reviews, and filter where review_id IS NULL.
select*from users;
select*from station_reviews;

select u.user_id,u.full_name,sr.review_id,sr.comment
from users u
left join station_reviews sr
on u.user_id = sr.user_id
where review_id is null;

-- 42	Show each payment along with the corresponding session's charging_cost_inr, and flag if the payment amount does not match the session cost.
select*from charging_sessions;
select*from payments;

select cs.session_id,p.payment_id,cs.charging_cost_inr as session_cost,p.amount_inr as session_payment,
case
when cs.charging_cost_inr <> p.amount_inr
then 'not matching'
else 'match'
end as comparison_payment_status
from charging_sessions cs
join payments p
on cs.session_id = p.session_id;

-- 43	Find all sessions where the charging_cost_inr is higher than the overall average charging cost.
select*from charging_sessions;

select *
from charging_sessions
where charging_cost_inr >
(select avg(charging_cost_inr) as avg_cost 
from charging_sessions);

-- 44	List users who have used a DC Fast or DC Rapid charger at least once. Use a subquery with IN.
select*from users;
select*from charging_sessions;
select*from charging_stations;

select*
from users
where user_id in(
select cse.user_id
from charging_sessions cse
join charging_stations cst
on cse.station_id = cst.station_id
where cst.charger_type in ('DC Fast','DC Rapid'));

-- 45	Find the station with the highest total revenue (sum of charging_cost_inr). Use a subquery to find the max, then filter
select*from charging_sessions;
select*from charging_stations;

SELECT 
    station_id,
    SUM(charging_cost_inr) AS total_revenue
FROM charging_sessions
GROUP BY station_id
HAVING SUM(charging_cost_inr) = (
    SELECT MAX(station_revenue)
    FROM (
        SELECT SUM(charging_cost_inr) AS station_revenue
        FROM charging_sessions
        GROUP BY station_id
    ) AS revenue_table
);

SELECT
    station_id,
    SUM(charging_cost_inr) AS total_revenue
FROM charging_sessions
GROUP BY station_id
ORDER BY total_revenue DESC
LIMIT 1;

-- 46	Show users whose total spending on charging is above the average total spending per user. Use a subquery in HAVING
select*from users;
select*from charging_sessions;

select user_id,sum(charging_cost_inr) as total_spendings ,
(select avg(total_spendingss)
from 
(select sum(charging_cost_inr) as total_spendingss
from charging_sessions
 group by user_id)AS avg_table
 ) as avg_total_spendings
from charging_sessions
group by user_id
having sum(charging_cost_inr) > (
select avg(total_spendingss)
from
 (select sum(charging_cost_inr) as total_spendingss
from charging_sessions
group by user_id) as total_spendings);

-- 47	List all vehicles that have NEVER been used in any charging session. Use a subquery with NOT IN.
select vehicle_id,model
from vehicles
where vehicle_id not in (
select vehicle_id from charging_sessions);

-- 48	For each city, find the station with the highest average rating. Use a correlated subquery or subquery in FROM.



select avg.city,avg.station_id,avg.station_name,avg.avg_rating
from
(select st.city,st.station_id,st.station_name,
avg(sr.rating) as avg_rating
from station_reviews sr
join charging_stations st
on sr.station_id = st.station_id
group by st.city,st.station_id,st.station_name) as avg
where 
avg.avg_rating = (select max(avg2.max_avg_rating)
from
 (select st2.city,st2.station_id,st2.station_name,
avg(sr2.rating) as max_avg_rating
from station_reviews sr2
join charging_stations st2
on sr2.station_id = st2.station_id
group by st2.city,st2.station_id,st2.station_name) as avg2
where avg2.city = avg.city
);

-- 49	Find users who have made at least one failed payment. Use EXISTS.
select*from payments;

select u.user_id,u.full_name
from users u
where exists(
SELECT 1
FROM charging_sessions cs
JOIN payments p
    ON cs.session_id = p.session_id
    where u.user_id = cs.user_id
    and p.amount_inr =0
    );
    
    -- 50	Write a CTE called high_spenders that lists users whose total charging_cost_inr > ₹2000. Then SELECT from it to show their full_name and city
    
    
with high_spenders as (select u.user_id,u.full_name,u.city,sum(cs.charging_cost_inr)
from users u
join charging_sessions cs
on u.user_id = cs.user_id
group by u.user_id,u.full_name,u.city
having sum(cs.charging_cost_inr)>2000)
select user_id,full_name,city
from high_spenders ;


-- 51	Create a CTE station_revenue that calculates total revenue and session count per station. Then JOIN it with charging_stations to show station_name, city, and the calculated metrics

with station_revenue as(select station_id,sum(charging_cost_inr) as total_revenue,count(session_id) as session_count
from charging_sessions
group by station_id)
select st.station_id,st.station_name,st.city,sr.total_revenue
from station_revenue sr
join charging_stations st
on sr.station_id = st.station_id;

-- 52	Use a CTE to find the monthly total energy consumed (GROUP BY YEAR and MONTH of charging_start). Show year, month, and total_kwh.
select*from charging_sessions;
with monthly_total_energy as(select
month(charging_start) as month,
year(charging_start) as year,
sum(energy_consumed_kwh) as total_kwh
from charging_sessions
group by 
year(charging_start) ,
month(charging_start))
select
month,year,total_kwh
from monthly_total_energy
order by month,year;

-- 53	Write two CTEs: one for sessions in Mumbai, one for sessions in Delhi. Then UNION ALL them to compare side by side.

-- * 	mumbai and delhi in single table
with mumbai_sessions as (select cs.session_id,cs.user_id,cs.station_id,cs.charging_cost_inr,
'mumbai' as city
from charging_sessions cs
join charging_stations ct
on cs.station_id = ct.station_id
where ct.city = 'mumbai'),
delhi_sessions as (select cs.session_id,cs.user_id,cs.station_id,cs.charging_cost_inr,
'delhi' as city

from charging_sessions cs
join charging_stations ct
on cs.station_id = ct.station_id
where ct.city = 'delhi')
select *from mumbai_sessions
union all
select*from delhi_sessions;

-- *	mumbai and delhi in different table
with mumbai_sessions as (select cs.session_id,cs.user_id,cs.station_id,cs.charging_cost_inr,
'mumbai' as city
from charging_sessions cs
join charging_stations ct
on cs.station_id = ct.station_id
where ct.city = 'mumbai'),
delhi_sessions as (select cs.session_id,cs.user_id,cs.station_id,cs.charging_cost_inr,
'delhi' as city

from charging_sessions cs
join charging_stations ct
on cs.station_id = ct.station_id
where ct.city = 'delhi')
select  m.session_id,m.user_id,m.station_id,m.charging_cost_inr,
d.session_id,d.user_id,d.station_id,d.charging_cost_inr
from mumbai_sessions as m
cross join delhi_sessions as d
order by m.session_id,d.session_id ;

-- 54	Use a CTE to calculate each user's average session cost, then classify users as "Budget" (avg < ₹150), "Standard" (₹150–₹400), or "Premium" (> ₹400).


with avg_session_cost as 
(select user_id,avg(charging_cost_inr)as avg_cost
from charging_sessions
group by user_id)
select user_id,avg_cost,
case
when avg_cost < 150 then 'average'
when avg_cost between 150 and 400 then 'standard'
when avg_cost > 400 then 'premium'
end as user_category
from avg_session_cost;

-- 55	Create a CTE that counts sessions per station per month. Then from that CTE, find stations that had zero sessions in any month (hint: you may need a calendar table or a simpler version — find stations with fewer than 2 sessions total).


with monthly_stations_sessions as 
(select station_id,
count(session_id) as total_sessions,
month(charging_start) as month
from charging_sessions
group by station_id,
month(charging_start)
)
select station_id,month,
sum(total_sessions) as total_sessions
from monthly_stations_sessions
group by station_id,month
having sum(total_sessions) < 2;

-- 56	Assign a row number to each charging session per user, ordered by charging_start. Show user_id, session_id, charging_start, and the row number.

select user_id,session_id,charging_start,
row_number() over(partition by user_id order by charging_start) as num	-- 	ROW_NUMBER	
from charging_sessions;

-- 57	Rank all sessions by charging_cost_inr from highest to lowest. Show rank, session_id, user_id, and cost. Use RANK() and also try DENSE_RANK() — observe the difference
select session_id,user_id,charging_cost_inr,
rank() over(order by charging_cost_inr desc)as rnk  -- RANK 
from charging_sessions;

select session_id,user_id,charging_cost_inr,
dense_rank() over(order by charging_cost_inr desc)as drnk -- DENSERANK
from charging_sessions;

-- 58	For each user, find their most expensive session (RANK = 1 ordered by charging_cost_inr DESC within each user). Show user_id, session_id, and cost

with cte as (select user_id,session_id,charging_cost_inr,
row_number() over(partition by user_id order by charging_cost_inr desc) as num
from charging_sessions)
select user_id,session_id,charging_cost_inr,num
from cte 
where num = 1;

-- 59	Calculate a running total of charging_cost_inr ordered by charging_start date for each user. Show user_id, charging_start, cost, and cumulative_cost
select user_id,charging_start,charging_cost_inr,
sum(charging_cost_inr) over(partition by user_id order by charging_start) as sum
from charging_sessions;

-- 60	For each session, show the previous session's charging_cost_inr for the same user (LAG). Also show the next session's cost (LEAD). Display user_id, session_id, current cost, prev cost, next cost

select user_id,session_id,
lag(charging_cost_inr) over(partition by user_id order by charging_start,session_id) as pre_cost,
charging_cost_inr as current_cost,
lead(charging_cost_inr) over(partition by user_id order by charging_start,session_id) as next_cost
from charging_sessions;

-- 61	Find the difference in energy_consumed_kwh between a user's current session and their previous session. Positive means they consumed more, negative means less

select user_id,session_id,energy_consumed_kwh as current_energy_cunsumption,
lag(energy_consumed_kwh) over (partition by user_id order by charging_start,session_id) as prev_energy_cunsumption,
energy_consumed_kwh - lag(energy_consumed_kwh) over (partition by user_id order by charging_start,session_id) as diff
from charging_sessions;

-- 62	Divide all users into 4 groups (quartiles) based on their total spending. Use NTILE(4). Label them "Q1 - Low", "Q2", "Q3", "Q4 - High".

with user_spend as 
(select user_id,
sum(charging_cost_inr) as total_spend
from charging_sessions
group by user_id),
user_quertile as 
(select user_id,total_spend,
ntile(4) over(order by total_spend) as quartile
from user_spend)
select user_id,total_spend,
case
when quartile = 1 then 'Q1 - LOW'
when quartile = 2 then 'Q2'
when quartile = 3 then 'Q3'
when quartile = 4 then 'Q4 - HIGH'
END AS quartile_spend
from user_quertile
order by total_spend;

-- 63	Show each station's total revenue and what percentage of the national total revenue it represents. Use SUM() as a window function over all rows

with station_revenue as
(select station_id,
sum(charging_cost_inr) as total_revenue
from charging_sessions
group by station_id)
select station_id,
sum(total_revenue) over() as national_total_revenue,
round(total_revenue*100.0/sum(total_revenue) over(),2) as revenue_percentage
from station_revenue
order by total_revenue desc;

-- 64	For each city, show the average session cost and compute how each user's average compares to their city's average (user_avg - city_avg). Use AVG() OVER PARTITION BY city.

with u_avg as
(select u.user_id,u.city,
avg(cs.charging_cost_inr) as u_avg_cost
from users u
join charging_sessions cs
on u.user_id = cs.user_id
group by u.user_id,u.city)
select
user_id,city,
u_avg_cost,
avg(u_avg_cost) over(partition by city) as c_avg_cost,
u_avg_cost - avg(u_avg_cost)over(partition by city) as diff
from u_avg
order by city,user_id;

-- 65	Final Boss: Using CTEs and window functions together — find each city's top 3 stations by total revenue. Show city, station_name, total_revenue, and rank_in_city

with st_total_revenue as (select u.city,cs.station_id,st.station_name,
sum(cs.charging_cost_inr) as total_revenue
from charging_sessions cs
join users u
on cs.user_id = u.user_id
join charging_stations st
on cs.station_id = st.station_id
group by u.city,cs.station_id,st.station_name),
ranked as
(select city,station_id,station_name,total_revenue,
dense_rank() over(partition by city order by total_revenue desc) as rnk
from st_total_revenue
)
select city,station_id,station_name,total_revenue,rnk
from ranked
where rnk <=3
order by city,rnk;


/* 	                     THE END                             */


