
-- List the top 3  for the fiscal years 2023  in terms of the number of 2-wheelers sold.

                                -- TOP 3 
select maker,sum(electric_vehicles_sold)as total_sold
from ev_sales_by_makers
where date between '01-Apr-22'and '31-Mar-23'
and vehicle_category = '2-Wheelers'
group by maker
order by total_sold desc
limit 5 ;
                                 -- BOTTOM 3
select maker,sum(electric_vehicles_sold)as total_sold
from ev_sales_by_makers
where date between '01-Apr-22'and '31-Mar-23'
and vehicle_category = '2-Wheelers'
group by maker
order by total_sold 
limit 3 ;

 -- List the top 3  for the fiscal year 2024 in terms of the number of 2-wheelers sold.
                           
                           -- TOP 3
select maker,sum(electric_vehicles_sold)as total_sold
from ev_sales_by_makers
where date between '01-Apr-23'and '31-Mar-24'
and vehicle_category = '2-Wheelers'
group by maker
order by total_sold desc
limit 3 ;
                             -- BOTTOM 3
select maker,sum(electric_vehicles_sold)as total_sold
from ev_sales_by_makers
where date between '01-Apr-23'and '31-Mar-24'
and vehicle_category = '2-Wheelers'
group by maker
order by total_sold 
limit 3 ;

-- . the top 5 states with the highest penetration rate in 2-wheeler and 4-wheeler EV sales in FY 2024.
SELECT state,
      round( AVG((electric_vehicles_sold / total_vehicles_sold)) * 100,2) AS PR
FROM ev_sales_by_state
JOIN dim_date ON ev_sales_by_state.date = dim_date.date
WHERE dim_date.fiscal_year = 2024
GROUP BY state
ORDER BY PR DESC
LIMIT 5;

--  the states with negative penetration (decline) in EV sales from 2022 to 2024
SELECT state, PR
FROM (
  SELECT state,
         ROUND(AVG((electric_vehicles_sold / total_vehicles_sold)) * 100, 2) AS PR
  FROM ev_sales_by_state
  GROUP BY state
) AS state_data
WHERE PR < 5 --  lesser than 5 is being considered as very low penetration rate 
ORDER BY PR desc;

-- The EV sales and penetration rates in Delhi compare to Karnataka for 2024

SELECT state,sum(electric_vehicles_sold) as total_ev_sales,
      round( AVG((electric_vehicles_sold / total_vehicles_sold)) * 100,2) AS PR
FROM ev_sales_by_state
JOIN dim_date ON ev_sales_by_state.date = dim_date.date
WHERE dim_date.fiscal_year = 2024 and ev_sales_by_state.state in ('Delhi','Karnataka')
GROUP BY state
ORDER BY total_ev_sales,PR   DESC
;



--  the compounded annual growth rate (CAGR) in 4-wheeler units for the top 5 makers from 2022 to 2024.

-- TOP 5 MAKERS
select maker , sum(ev_sales_by_makers.electric_vehicles_sold) as total_sales
from ev_sales_by_makers
where vehicle_category = '4-Wheelers'
group by maker 
order by  total_sales asc
limit 5 ;



-- CAGR
SELECT 
  maker, 
  round((POWER(MAX(total_sales) / MIN(total_sales), 1/2) - 1),2) AS CAGR
FROM (
  SELECT 
    maker, 
    fiscal_year, 
    SUM(electric_vehicles_sold) AS total_sales
  FROM 
    ev_sales_by_makers
  JOIN 
    dim_date ON ev_sales_by_makers.date = dim_date.date
  WHERE 
    vehicle_category = '4-Wheelers' 
    AND maker IN ('Tata Motors', 'Mahindra & Mahindra', 'MG Motor', 'BYD India', 'Hyundai Motor')
  GROUP BY 
    maker, fiscal_year
) AS makers_data
GROUP BY 
  maker
ORDER BY 
  CAGR desc
  limit 5;
  
  
  
  -- the peak and low season months for EV sales based on the data from 2022 to 2024
  
  select month_category,sum(electric_vehicles_sold) as total_ev_sales
from ev_sales_by_state
group by month_category;



--  the projected number of EV sales  for the top 10 states by penetration rate in 2030, based on the compounded annual growth rate (CAGR) from previous years
              
              
              
              -- base year ev sales  calculation
select dim_date.fiscal_year,sum(electric_vehicles_sold) as base_sales
from ev_sales_by_state
join dim_date on ev_sales_by_state.date = dim_date.date
where dim_date.fiscal_year = 2022
 ;

                        -- projected sales 
SELECT state,
     round(271150 * POWER(1 + cagr, 6)) AS projected_sales -- 271150 this was the base year ev sales vol
FROM cagr_table -- cagr table was created independently for calculation
order by state desc;





-- the revenue growth rate of  EVs in India for 2022 to  2024  and 2023 to 2024



-- 2022 to 2024 
SELECT
  annual_rev.vehicle_category,
  round((POWER(MAX(revenue)/MIN(revenue), 1/2) - 1)* 100 ,2)AS revenue_gr_rate
FROM (
  SELECT
    dim_date.fiscal_year,  -- Include fiscal_year if needed for later analysis
    ev_sales_by_state.vehicle_category,
    SUM(CASE WHEN vehicle_category = '2-Wheeler' THEN 85000 * electric_vehicles_sold
             ELSE 1500000 * electric_vehicles_sold END) AS revenue
  FROM
    ev_sales_by_state
  JOIN
    dim_date ON ev_sales_by_state.date = dim_date.date
  GROUP BY
    dim_date.fiscal_year,  -- Include fiscal_year if needed for later analysis
    vehicle_category
) AS annual_rev
GROUP BY
  annual_rev.vehicle_category;
  
  
  
  --  2023 to  2024 
  
  SELECT
  annual_rev.vehicle_category,
  round((POWER(MAX(revenue)/MIN(revenue), 1/1) - 1)* 100,2) AS revenue_gr_rate
FROM (
  SELECT
    dim_date.fiscal_year,  -- Include fiscal_year if needed for later analysis
    ev_sales_by_state.vehicle_category,
    SUM(CASE WHEN vehicle_category = '2-Wheeler' THEN 85000 * electric_vehicles_sold
             ELSE 1500000 * electric_vehicles_sold END) AS revenue
  FROM
    ev_sales_by_state
  JOIN
    dim_date ON ev_sales_by_state.date = dim_date.date
  GROUP BY
    dim_date.fiscal_year,  -- Include fiscal_year if needed for later analysis
    vehicle_category
) AS annual_rev
GROUP BY
  annual_rev.vehicle_category;
  
  
  
  
  
  
  
								

           -- quarterly trends 
           
           select maker, sum(electric_vehicles_sold)as sales_vol,dim_date.quarter,dim_date.fiscal_year
           from ev_sales_by_makers
           join dim_date on ev_sales_by_makers.date = dim_date.date
           where  vehicle_category = '2-Wheelers' and maker IN ('OLA ELECTRIC','TVS','ATHER','HERO ELECTRIC','AMPERE') and dim_date.quarter = 'Q1'
           group by maker,dim_date.quarter,dim_date.fiscal_year;
           -- cagr 2w 
           
           -- CAGR
SELECT 
  maker, 
  round((POWER(MAX(total_sales) / MIN(total_sales), 1/2) - 1),2) AS CAGR
FROM (
  SELECT 
    maker, 
    fiscal_year, 
    SUM(electric_vehicles_sold) AS total_sales
  FROM 
    ev_sales_by_makers
  JOIN 
    dim_date ON ev_sales_by_makers.date = dim_date.date
  WHERE 
	vehicle_category = '2-Wheelers' and maker IN ('OLA ELECTRIC','TVS','ATHER','HERO ELECTRIC','AMPERE')

  GROUP BY 
    maker, fiscal_year
) AS makers_data
GROUP BY 
  maker
ORDER BY 
  CAGR desc
  limit 5;
  
  
  