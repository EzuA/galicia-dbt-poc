-- Intermediate layer: Agregación de ventas por mes
-- Materialización: table

{{
    config(
        materialized='table',
        indexes=[
            {'columns': ['year_month'], 'type': 'btree'}
        ]
    )
}}

with orders as (
    select * from {{ ref('stg_orders') }}
),

order_items as (select * from {{ ref('stg_order_items') }}
),

-- Agregar por mes
monthly_sales as (
    select
        o.order_year,
        o.order_month,
        concat(
            {{ cast_as_string('o.order_year') }},
            '-',
            {{ lpad_string(cast_as_string('o.order_month'), 2, '0') }}
        ) as year_month,
        count(distinct o.order_id) as total_orders,
        count(distinct o.user_id) as unique_customers,
        sum(o.total_amount) as total_revenue,
        avg(o.total_amount) as avg_order_value,
        min(o.total_amount) as min_order_value,
        max(o.total_amount) as max_order_value,
        -- Métricas de productos
        count(distinct oi.product_id) as unique_products_sold,
        sum(oi.quantity) as total_items_sold,
        sum(oi.discount_amount) as total_discounts
    from orders as o
    left join order_items as oi on o.order_id = oi.order_id
    where o.status = 'completed'
    group by o.order_year, o.order_month
)

select * from monthly_sales
