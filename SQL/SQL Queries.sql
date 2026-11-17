--Overall business performance

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    SUM(quantity) AS total_quantity,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(
        SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2
    ) AS profit_margin_percentage,
    ROUND(
        SUM(sales) / NULLIF(COUNT(DISTINCT order_id), 0), 2
    ) AS average_order_value
FROM retail_sales_raw;


--Monthly Sales vs Monthly Profit Trends

SELECT
    EXTRACT(YEAR FROM order_date) AS year,
    EXTRACT(MONTH FROM order_date) AS month,
    TO_CHAR(order_date, 'Mon YYYY') AS month_name,

    ROUND(SUM(sales), 2) AS monthly_sales,

    ROUND(SUM(profit), 2) AS monthly_profit,

    ROUND(
        SUM(profit) / NULLIF(SUM(sales), 0) * 100,
        2
    ) AS profit_margin_percentage,

    COUNT(DISTINCT order_id) AS total_orders

FROM retail_sales_raw

GROUP BY
    EXTRACT(YEAR FROM order_date),
    EXTRACT(MONTH FROM order_date),
    TO_CHAR(order_date, 'Mon YYYY')

ORDER BY
    year,
    month;


--Month-over-Month (MoM) Sales and Profit Growth.
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', order_date) AS sales_month,
        SUM(sales) AS total_sales,
        SUM(profit) AS total_profit
    FROM retail_sales_raw
    GROUP BY DATE_TRUNC('month', order_date)
),

monthly_comparison AS (
    SELECT
        sales_month,
        total_sales,
        total_profit,

        LAG(total_sales) OVER (
            ORDER BY sales_month
        ) AS previous_month_sales,

        LAG(total_profit) OVER (
            ORDER BY sales_month
        ) AS previous_month_profit

    FROM monthly_sales
)

SELECT
    sales_month,
    total_sales,
    previous_month_sales,

    ROUND(
        (total_sales - previous_month_sales)
        / NULLIF(previous_month_sales, 0) * 100, 2
    ) AS sales_growth_pct,

    total_profit,
    previous_month_profit,

    ROUND(
        (total_profit - previous_month_profit)
        / NULLIF(previous_month_profit, 0) * 100, 2
    ) AS profit_growth_pct

FROM monthly_comparison
ORDER BY sales_month;

--SQL Analysis 3 – Category & Sub-category Analysis
SELECT
    category,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    SUM(quantity) AS total_quantity,
    ROUND(SUM(sales)::NUMERIC, 2) AS total_sales,
    ROUND(SUM(profit)::NUMERIC, 2) AS total_profit,
    ROUND(
        SUM(profit)::NUMERIC / NULLIF(SUM(sales), 0) * 100,
        2
    ) AS profit_margin_pct
FROM retail_sales_raw
GROUP BY category
ORDER BY total_sales DESC;

-- Sub-category Profitability Analysis.
SELECT
    category,
    sub_category,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(quantity) AS total_quantity,
    ROUND(SUM(sales)::NUMERIC, 2) AS total_sales,
    ROUND(SUM(profit)::NUMERIC, 2) AS total_profit,

    ROUND(
        SUM(profit)::NUMERIC /
        NULLIF(SUM(sales), 0) * 100,
        2
    ) AS profit_margin_pct

FROM retail_sales_raw

GROUP BY
    category,
    sub_category

ORDER BY total_profit ASC;


--SQL Analysis 4 – Product-Level Profitability Analysis.
--Step 1: Identify loss-making products
SELECT
    product_id,
    product_name,

    SUM(quantity) AS total_quantity,

    ROUND(SUM(sales)::NUMERIC, 2) AS total_sales,

    ROUND(SUM(profit)::NUMERIC, 2) AS total_profit,

    ROUND(
        SUM(profit)::NUMERIC /
        NULLIF(SUM(sales), 0) * 100,
        2
    ) AS profit_margin_pct

FROM retail_sales_raw

GROUP BY
    product_id,
    product_name

HAVING SUM(profit) < 0

ORDER BY total_profit ASC;

--Step 2: Top 10 Most Profitable Products.
SELECT
    product_id,
    product_name,
    SUM(quantity) AS total_quantity,

    ROUND(SUM(sales)::NUMERIC, 2) AS total_sales,

    ROUND(SUM(profit)::NUMERIC, 2) AS total_profit,

    ROUND(
        SUM(profit)::NUMERIC /
        NULLIF(SUM(sales), 0) * 100,
        2
    ) AS profit_margin_pct

FROM retail_sales_raw

GROUP BY
    product_id,
    product_name

ORDER BY total_profit DESC

LIMIT 10;

--SQL Analysis 5 – Discount Impact on Profitability.
SELECT
    discount,

    COUNT(*) AS total_transactions,

    SUM(quantity) AS total_quantity,

    ROUND(SUM(sales)::NUMERIC, 2) AS total_sales,

    ROUND(SUM(profit)::NUMERIC, 2) AS total_profit,

    ROUND(
        SUM(profit)::NUMERIC /
        NULLIF(SUM(sales), 0) * 100,
        2
    ) AS profit_margin_pct

FROM retail_sales_raw

GROUP BY discount

ORDER BY discount;

--SQL Analysis 6 – Regional Sales & Profitability Analysis.
SELECT
    region,

    COUNT(DISTINCT order_id) AS total_orders,

    COUNT(DISTINCT customer_id) AS total_customers,

    SUM(quantity) AS total_quantity,

    ROUND(SUM(sales)::NUMERIC, 2) AS total_sales,

    ROUND(SUM(profit)::NUMERIC, 2) AS total_profit,

    ROUND(
        SUM(profit)::NUMERIC /
        NULLIF(SUM(sales), 0) * 100,
        2
    ) AS profit_margin_pct

FROM retail_sales_raw

GROUP BY region

ORDER BY total_sales DESC;

--SQL Analysis 6 – Customer-Level Sales & Profitability Analysis.
--Step 1: Customer-wise performance

SELECT
    customer_id,
    customer_name,

    COUNT(DISTINCT order_id) AS total_orders,

    SUM(quantity) AS total_quantity,

    ROUND(SUM(sales)::NUMERIC, 2) AS total_sales,

    ROUND(SUM(profit)::NUMERIC, 2) AS total_profit,

    ROUND(
        SUM(profit)::NUMERIC /
        NULLIF(SUM(sales), 0) * 100,
        2
    ) AS profit_margin_pct

FROM retail_sales_raw

GROUP BY
    customer_id,
    customer_name

ORDER BY total_sales DESC;

--Step 2: Identify the top 10 valuable customers
SELECT
    customer_id,
    customer_name,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales)::NUMERIC, 2) AS total_sales,
    ROUND(SUM(profit)::NUMERIC, 2) AS total_profit

FROM retail_sales_raw

GROUP BY
    customer_id,
    customer_name

ORDER BY total_profit DESC

LIMIT 10;

--Step 3: Identify loss-making customers
SELECT
    customer_id,
    customer_name,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales)::NUMERIC, 2) AS total_sales,
    ROUND(SUM(profit)::NUMERIC, 2) AS total_profit

FROM retail_sales_raw

GROUP BY
    customer_id,
    customer_name

HAVING SUM(profit) < 0

ORDER BY total_profit ASC;