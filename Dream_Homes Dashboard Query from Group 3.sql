-Dream_Homes Dashboard Query
-Financial Information

1.Top 10 Individual Sales Leaderboard

SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name AS agent_name,
    COUNT(t.transaction_id) AS total_transactions,
    SUM(t.price) AS total_sales_value,
    ROUND(AVG(t.price)) AS avg_deal_size,
    COUNT(*) FILTER (WHERE t.transaction_type = 'Sale') AS sales_count,
    COUNT(*) FILTER (WHERE t.transaction_type = 'Rent') AS rental_count
FROM Employees e
JOIN Transactions t ON e.employee_id = t.employee_id
GROUP BY e.employee_id, agent_name
ORDER BY total_sales_value DESC
limit 10

2.Office Profitability

WITH revenue_summary AS (
    SELECT office_id, SUM(amount) AS total_revenue
    FROM Revenue
    GROUP BY office_id
),
expenses_summary AS (
    SELECT office_id, SUM(amount) AS total_expenses
    FROM Expenses
    GROUP BY office_id
)

SELECT 
    o.office_id,
    o.city,
    COALESCE(r.total_revenue, 0) AS total_revenue,
    COALESCE(e.total_expenses, 0) AS total_expenses,
    COALESCE(r.total_revenue, 0) - COALESCE(e.total_expenses, 0) AS net_profit
FROM Offices o
LEFT JOIN revenue_summary r ON o.office_id = r.office_id
LEFT JOIN expenses_summary e ON o.office_id = e.office_id
WHERE o.city <> 'Hartford'
ORDER BY net_profit DESC
limit 10;

3.Office Expense

select *
from(
select 
city,
sum(total_expenses) as expense
from(
SELECT o.office_id, o.city, o.state, 
       COALESCE(SUM(r.amount), 0) AS total_revenue,
       COALESCE(SUM(e.amount), 0) AS total_expenses,
       COALESCE(SUM(r.amount), 0) - COALESCE(SUM(e.amount), 0) AS net_profit
FROM Offices o
LEFT JOIN Revenue r ON o.office_id = r.office_id
LEFT JOIN Expenses e ON o.office_id = e.office_id
GROUP BY o.office_id
ORDER BY net_profit DESC) a
group by 1

union all

select 
state,
sum(total_expenses) as expense
from(
SELECT o.office_id, o.city, o.state, 
       COALESCE(SUM(r.amount), 0) AS total_revenue,
       COALESCE(SUM(e.amount), 0) AS total_expenses,
       COALESCE(SUM(r.amount), 0) - COALESCE(SUM(e.amount), 0) AS net_profit
FROM Offices o
LEFT JOIN Revenue r ON o.office_id = r.office_id
LEFT JOIN Expenses e ON o.office_id = e.office_id
GROUP BY o.office_id
ORDER BY net_profit DESC) a
group by 1)aa
order by expense DESC

4.Office Salary

select
city, 
state,
sum(salary) as agg_sal,
avg(salary) as avg_sal,
avg(commission_rate) as avg_cmr,
sum(bonuses) as agg_bns,
avg(bonuses) as avg_bns
from (
SELECT 
e.employee_id, 
c.salary, 
c.commission_rate, 
c.bonuses, 
c.effective_date, 
e.office_id, 
o.city, 
o.state
FROM Employees e
LEFT JOIN Compensation c ON e.employee_id = c.employee_id
left join Offices o on o.office_id = e.office_id) a
group by 1,2

-Business Insihgt

1.Customer Preference

select 
preferred_location as loc,
property_type as typ,
count(distinct client_id) as num
from (
SELECT c.client_id, c.first_name, c.last_name, c.client_type, 
       cp.property_type, cp.budget_range, cp.preferred_location
FROM Clients c
LEFT JOIN Client_Preferences cp ON c.client_id = cp.client_id) a
group by 1,2

union all 

select 
preferred_location as loc,
'Total' as typ,
count(distinct client_id) as num
from (
SELECT c.client_id, c.first_name, c.last_name, c.client_type, 
       cp.property_type, cp.budget_range, cp.preferred_location
FROM Clients c
LEFT JOIN Client_Preferences cp ON c.client_id = cp.client_id) a
group by 1,2

2.Customer Budget Range

select 
budget_range as bdgt,
property_type as typ,
count(distinct client_id) as num
from (
SELECT c.client_id, c.first_name, c.last_name, c.client_type, 
       cp.property_type, cp.budget_range, cp.preferred_location
FROM Clients c
LEFT JOIN Client_Preferences cp ON c.client_id = cp.client_id) a
group by 1,2

union all 

select 
budget_range as bdgt,
'Total' as typ,
count(distinct client_id) as num
from (
SELECT c.client_id, c.first_name, c.last_name, c.client_type, 
       cp.property_type, cp.budget_range, cp.preferred_location
FROM Clients c
LEFT JOIN Client_Preferences cp ON c.client_id = cp.client_id) a
group by 1,2

-Real Estate Market Trend

1.Pricing float

SELECT state, listing_date, avg(price) as price
FROM Property_Location
where status = 'Available'
group by 1,2
order by listing_date

2.Transaction Price Floating

select 
transaction_type as typ,
price,
transaction_date
from(
SELECT t.transaction_id, p.address, 
       c.first_name || ' ' || c.last_name AS client,
       e.first_name || ' ' || e.last_name AS agent,
       t.transaction_type, t.price, t.transaction_date
FROM Transactions t
JOIN Property_Location p ON t.property_id = p.property_id
JOIN Clients c ON t.client_id = c.client_id
JOIN Employees e ON t.employee_id = e.employee_id) aa
order by transaction_date

-Marketing Strategy

1.Market Campaign Leads Generated

SELECT campaign_name, type, start_date, end_date, cost, leads_generated,
       CASE WHEN cost > 0 THEN leads_generated::DECIMAL / cost ELSE NULL END AS leads_per_dollar
FROM Marketing_Campaigns;

2.Property status

SELECT status, COUNT(*) AS property_count
FROM Property_Location
GROUP BY status;










