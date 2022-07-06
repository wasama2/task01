-- 1) Общее количество покупателей
select count(*) as CustomerCountDistinct from Сustomer 

-- 2) Количество покупателей из Италии и Франции
with cte_countries_customers(country_code, сustomer_сount)
as(
	select country_code, count(*)
	from Сustomer
	group by country_code
),
cte_required_countries
as(
	select country_code, country_name
	from Countries
	where country_name in ('France', 'Italy')
)
select cnt.country_name as Country_name, COALESCE(cst.сustomer_сount, 0) as CustomerCountDistinct
	from cte_required_countries as cnt left join cte_countries_customers as cst
	on cnt.country_code = cst.country_code

-- 3) ТОП 10 покупателей по расходам
with cte_customer_revenue(customer_id, revenue)
as(
	select ord.customer_id, sum(ord.quantity * itm.price)
	from Orders as ord
	join Items as itm
	on ord.item_id = itm.item_id
	group by ord.customer_id
)
select cst.customer_name as Customer_name, rvn.revenue as Revenue
from Сustomer as cst
join cte_customer_revenue as rvn
on cst.customer_id = rvn.customer_id
order by rvn.revenue desc
limit 10

-- 4) Общая выручка USD по странам, если нет дохода, вернуть NULL
with cte_customer_revenue(customer_id, revenue)
as(
	select ord.customer_id, sum(ord.quantity * itm.price)
	from Orders as ord
	join Items as itm
	on ord.item_id = itm.item_id
	group by ord.customer_id
),
cte_country_revenue(country_code, revenue)
as(
	select cst.country_code, sum(rvn.revenue)
	from cte_customer_revenue as rvn
	join Сustomer as cst
	on cst.customer_id = rvn.customer_id
	group by cst.country_code
)
select cnt.country_name as Country_name, rvn.revenue as RevenuePerCountry
from Countries as cnt
left join cte_country_revenue as rvn
on cnt.country_code = rvn.country_code

-- 5) Самый дорогой товар, купленный одним покупателем
with cte_customer_item_max_prices(customer_id, item_name)
as(
	select customer_id, item_name
	from
		(select 
			ord.customer_id as customer_id, 
			itm.item_name as item_name, 
			row_number() over (partition by ord.customer_id order by itm.price desc) as rnumber
		from Orders as ord
		join Items as itm
		on ord.item_id = itm.item_id) as spr
	where rnumber = 1
)
select cst.customer_id as Customer_id, cst.customer_name as Customer_name, prc.item_name as MostExpensiveItemName
from Сustomer as cst
left join cte_customer_item_max_prices as prc
on cst.customer_id = prc.customer_id

-- 6) Ежемесячный доход
select extract(month from ord.date_time) as Month, sum(ord.quantity * itm.price) as Total_Revenue
from Orders as ord
join Items as itm
on ord.item_id = itm.item_id
group by extract(month from ord.date_time)


-- 7) Общий доход в MENA
with cte_customer_revenue(customer_id, revenue)
as(
	select ord.customer_id, sum(ord.quantity * itm.price)
	from Orders as ord
	join Items as itm
	on ord.item_id = itm.item_id
	group by ord.customer_id
),
cte_country_revenue(country_code, revenue)
as(
	select cst.country_code, sum(rvn.revenue)
	from cte_customer_revenue as rvn
	join Сustomer as cst
	on cst.customer_id = rvn.customer_id
	group by cst.country_code
)
select COALESCE(sum(revenue), 0) as Total_Revenue_MENA
from cte_country_revenue
where country_code in (
	select country_code
	from Countries
	where country_zone = 'MENA')


-- 8) Найти дубликаты
select date_time, customer_id, item_id, counter as duplicate_count
from (
    select date_time, customer_id, item_id, count(*) as counter 
    from Orders
    group by date_time, customer_id, item_id) as subr
where counter > 1