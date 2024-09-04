create database Zomato;
use zomato;

# Build a Calendar Table using the Columns Datekey_Opening
alter table main
add column Datekey_Opening DATE;
update main
set Datekey_Opening = 
  case
    when Year_Opening = 0 and Month_Opening = 0 and Day_Opening = 0 then null
    else cast(concat(Year_Opening, '-', Month_Opening, '-', Day_Opening) as date)
  end;
  
  select * from main;
  

  #KPI's 
  select Count(*) as Total_Country from country;
  select Count(*) as Total_Currency from currency;
  select count(restaurantid) as Total_Restaurant from main;
  
# Calender Table
select concat(Day_Opening, '-', Month_Opening, '-', Year_Opening) as Datekey_Opening
from main;
  
select date(Datekey_Opening) AS DATES, 
year(Datekey_Opening) AS YEARS, 
month(Datekey_Opening) AS MONTHNO, 
monthname(Datekey_Opening) AS MONTHNAME, 
CONCAT("Q",quarter(Datekey_Opening)) AS QUARTERS, 
DATE_FORMAT(Datekey_Opening, '%Y-%b') as "YYYY-MMM",
dayofweek(Datekey_Opening) AS WEEKDAYNO, 
date_format(Datekey_Opening, "%W" ) AS WEEKDAY,

case
when month(Datekey_Opening) = 4 then "FM1"
when month(Datekey_Opening) = 5 then "FM2"
when month(Datekey_Opening) = 6 then "FM3"
when month(Datekey_Opening) = 7 then "FM4"
when month(Datekey_Opening) = 8 then "FM5"
when month(Datekey_Opening) = 9 then "FM6"
when month(Datekey_Opening) = 10 then "FM7"
when month(Datekey_Opening) = 11 then "FM8"
when month(Datekey_Opening) = 12 then "FM9"
when month(Datekey_Opening) = 1 then "FM10"
when month(Datekey_Opening) = 2 then "FM11"
else "FM12"
end as Financial_Month, 

case 
when month(Datekey_Opening) between 1 and 3 then "FQ4"
when month(Datekey_Opening) between 4 and 6 then "FQ1"
when month(Datekey_Opening) between 7 and 9 then "FQ2"
else "FQ3"
end as Financial_Quarter
from main;  

# 3 Convert the Average cost for 2 column into USD dollars
alter table main
add column avg_cost_in_usd decimal(4,1);

update main m
join currency c on m.currency = c.currency
set m.avg_cost_in_usd = m.average_cost_for_two * c.Usd_rate;

select * from main;

# Find the Numbers of Resturants based on City and Country.
Set Session sql_mode=(select Replace(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

Select count(RestaurantID) as Restaurants, countryname as country, City from main m
join country c on c.Countryid = m.CountryCode 
group by 3; 

Select count(RestaurantID) as Restaurants, countryname as country from main m
join country c on c.Countryid = m.CountryCode 
group by 2 
order by 1 desc;

# Numbers of Resturants opening based on Year , Quarter , Month
select year(Datekey_Opening) as Year, count(*) as Yearwise_Restaurants_Opening
from main
group by 1
order by 1;

select year(Datekey_Opening) as Year, quarter(Datekey_Opening) as Quarter, 
count(*) as Quaterwise_Restaurants_Opening
from main
group by 1, 2
order by 1;

select year(Datekey_Opening) as Year, month(Datekey_Opening), monthname(Datekey_Opening) as Month, 
count(*) as Monthwise_Restaurants_Opening
from main
group by 1, 3
order by 1, 2 asc;

#  Count of Resturants based on Average Ratings
select
  case 
    when Rating >= 0 and Rating < 2 then '0-1.9'
    when Rating >= 2 and Rating < 3 then '2-2.9'
    when Rating >= 3 and Rating < 4 then '3-3.9'
    when Rating >= 4 and Rating <= 5 then '4-5'
  end as Rating_bucket,
count(RestaurantID) as Restaurant_Count
from main
group by Rating_bucket
order by Rating_bucket desc;

/* Create buckets based on Average Price of reasonable size and 
find out how many resturants falls in each buckets */
select 
  case 
    when avg_cost_in_usd >= 0 and avg_cost_in_usd < 20 then '0-19'
    when avg_cost_in_usd >= 20 and avg_cost_in_usd < 100 then '20-99'
    when avg_cost_in_usd >= 100 and avg_cost_in_usd < 150 then '100-149'
    when avg_cost_in_usd >= 150 and avg_cost_in_usd < 200 then '150-199'
    when avg_cost_in_usd >= 200 and avg_cost_in_usd < 250 then '200-249'
    when avg_cost_in_usd >= 250 and avg_cost_in_usd < 300 then '250-299'
    when avg_cost_in_usd >= 300 then '300+'
  end as Price_Bucket,
  count(RestaurantID) as Restaurant_Count
from main
group by Price_Bucket
order by Restaurant_Count desc;

# Percentage of Resturants based on "Has_Table_booking"
select Has_Table_booking, count(RestaurantID) as Restaurant,
concat(round(count(RestaurantID) / (select count(*) from main) * 100, 1), "%") as Percentage
from main
group by Has_Table_booking;

# Percentage of Resturants based on "Has_Online_delivery"
select Has_Online_Delivery, count(RestaurantID) as Restaurant,
concat(round(count(RestaurantID) / (select count(*) from main) * 100, 1), "%") as Percentage
from main
group by Has_Online_Delivery;
