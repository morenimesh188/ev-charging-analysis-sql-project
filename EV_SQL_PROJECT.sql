#1. Create a database named EV_Charging_Analytics.
create database EV_charging_analytics;
set sql_safe_updates=0;
use EV_charging_analytics;

#2. Create a table ev_charging_sessions with appropriate data types and constraints.
create table EV_charging_pattern (id int,user_id varchar(20),vehicle_model varchar(20),battery_capacity_kwh int,charging_station_id varchar(20),charging_station_location char(20),
charging_start datetime,charging_end datetime,energy_consumed int,charging_duration_hours int,charging_rate_kw int,charging_cost_usd int,time_of_day char(20),day_of_week char(20),
soc_start_pct int,soc_end_pct int,distance_km int,temperature_c int,vehicle_age_years int,charger_type varchar(20),user_type varchar(50));
select * from EV_charging_pattern;

#3. Add a new column charging_efficiency_pct.
 alter table EV_charging_pattern add column charging_efficiency_pct int;
 
#4. Modify charging_cost_usd to increase precision.
alter table EV_charging_pattern modify charging_cost_usd decimal(10,3);

#5. Drop temperature_c column.
alter table EV_charging_pattern drop temperature_c;

#6. Import all records from CSV file.
#7. Update charging_efficiency_pct = (energy_consumed / battery_capacity_kwh) * 100.
update EV_charging_pattern set charging_efficiency_pct = (energy_consumed / battery_capacity_kwh) * 100;

#8. Increase charging_cost_usd by 5% for New York.
update EV_charging_pattern set charging_cost_usd = charging_cost_usd * 1.05 where charging_station_location = 'new york';

#9.Delete records where energy_consumed < 5.
delete from EV_charging_pattern where energy_consumed < 5;

#10. Insert a test record manually.
insert into EV_charging_pattern (id) values (5000);

#11. Retrieve sessions where charging_rate_kw > 40.
select * from ev_charging_pattern where charging_rate_kw > 40;

#12. Display top 5 most expensive sessions.
select * from EV_charging_pattern  order by charging_cost_usd desc limit 5;

#13. Show distinct vehicle_model names and counts.
select vehicle_model,count(*) as vehicle_count from EV_charging_pattern group by vehicle_model;

#14. Find average charging cost per location.
select charging_station_location,avg(charging_cost_usd) as avg_crg_cost_per_loc from EV_charging_pattern group by charging_station_location;

#15. List sessions on weekends.
select * from EV_charging_pattern where day_of_week in ('saturday','sunday');

#16. Retrieve sessions where soc_end_pct  soc_start_pct > 40. 
select * from EV_charging_pattern where soc_start_pct > 40;

#17. Show average energy and duration per charger_type.
select charger_type,avg(energy_consumed) as avg_energy,avg(charging_duration_hours) as avg_duration from EV_charging_pattern group by charger_type;

#18. Find highest temperature recorded. ------------------------------------------------------------------incomplete question

#19. Display sessions with vehicle_age_years > 5 and user_type = 'Commuter'.
select*from EV_charging_pattern where vehicle_age_years > 5 and user_type = 'commuter';

#20. Categorize sessions as 'Low', 'Medium', 'High Energy' using CASE WHEN. 

select *,
case 
when energy_consumed  <40 then "low"
when energy_consumed  >85 then "high"
else "medium"
end as enrg_con_range
from EV_charging_pattern;

#21
with cte as
(select enrg_con_range
count('high','medium','low') as count_range from EV_charging_pattern group by enrg_con_range)from EV_charging_pattern as cte;

with cte as (
select *,
case 
when energy_consumed  <40 then "low"
when energy_consumed  >85 then "high"
else "medium"
end as enrg_con_range
from EV_charging_pattern)
select enrg_con_range,count(*)as total from cte where enrg_con_range in ('low','medium','high')
group by enrg_con_range;





select * from EV_charging_pattern;