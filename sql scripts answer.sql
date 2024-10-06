use gdb023;


select distinct market from dim_customer
where customer='Atliq Exclusive' and region='APAC';

select segment,count(product) as product_count
from dim_product
group by segment
order by product_count desc;

with table1 as (select f.product_code,f.manufacturing_cost,p.product
from fact_manufacturing_cost f join dim_product p on f.product_code=p.product_code)
select product_code, product, manufacturing_cost from table1
where manufacturing_cost=240.5364 or
manufacturing_cost=0.8920;

select c.customer,c.market,f.pre_invoice_discount_pct,f.fiscal_year
from dim_customer c join fact_pre_invoice_deductions f on c.customer_code=f.customer_code
where c.market='India' and f.fiscal_year=2021
order by pre_invoice_discount_pct desc limit 5;

with table2 as (select g.gross_price,month(m.date) as months,year(m.date) as years
from fact_sales_monthly m join dim_customer c on c.customer_code=m.customer_code
join fact_gross_price g on g.product_code =m.product_code where c.customer='Atliq Exclusive')
select months,years,sum(gross_price) as gross_sales_month
from table2
group by months,years;

ALTER TABLE fact_sales_monthly
ADD months INT;
ALTER TABLE fact_sales_monthly
DROP COLUMN quater;


SELECT
    quarter,
    SUM(sold_quantity) AS total_sold_quantity
FROM (
    SELECT *,
           MONTH(date) AS months,
           CASE
               WHEN MONTH(date) < 5 THEN 'Q1'
               WHEN MONTH(date) >= 5 AND MONTH(date) < 9 THEN 'Q2'
               ELSE 'Q3'
           END AS quarter
    FROM fact_sales_monthly AS fsm
    WHERE fiscal_year = 2020
) AS subquery
GROUP BY quarter
ORDER BY total_sold_quantity DESC
LIMIT 1;

-- question 10
use gdb023;
select * from (select p.division,p.product_code,p.product,f.sold_quantity,dense_rank() over(partition by p.division order by sold_quantity desc) as rank_order
from dim_product p join fact_sales_monthly f on p.product_code=f.product_code
where f.fiscal_year=2021) as table1
where rank_order <=3;

-- q3 What is the percentage of unique product increase in 2021 vs. 2020?
select *, ((year2021 - year2020) / (year2021 + year2020))*100 AS percent_chg from (SELECT
    (SELECT COUNT(DISTINCT product_code) FROM fact_sales_monthly WHERE fiscal_year = 2021) AS year2021,
    (SELECT COUNT(DISTINCT product_code) FROM fact_sales_monthly WHERE fiscal_year = 2020) AS year2020
    -- ((year2021 - year2020) / (year2021 + year2020)) AS percent_chg
FROM fact_sales_monthly
limit 1) as table1;

select * ,(product_count_2021-product_count_2020) as difference from (select p.segment, 
(SELECT COUNT(DISTINCT product_code) FROM fact_sales_monthly WHERE fiscal_year = 2020) AS product_count_2020,
(select count(distinct product_code) from fact_sales_monthly where fiscal_year=2021) as product_count_2021
from dim_product p join fact_sales_monthly f on p.product_code=f.product_code
group by p.segment, f.fiscal_year) as table1
order by difference desc limit 1;

WITH ChannelSales AS (
  SELECT
    c.channel,
    round(SUM(f.gross_price * m.sold_quantity)) AS gross_sales_mln
  FROM fact_sales_monthly m
  JOIN fact_gross_price f ON m.product_code = f.product_code
  JOIN dim_customer c ON m.customer_code = c.customer_code
  WHERE m.fiscal_year = 2021
  GROUP BY c.channel
)

SELECT
  ChannelSales.*,
  ROUND((gross_sales_mln / SUM(gross_sales_mln) OVER ()) * 100, 2) AS percentage
FROM ChannelSales
ORDER BY gross_sales_mln DESC;


































