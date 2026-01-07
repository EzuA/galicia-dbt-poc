-- Intermediate layer: Agregación de métricas de productos
-- Materialización: table

{{
    config(
        materialized='table',
        indexes=[
            {'columns': ['product_id'], 'type': 'btree'},
            {'columns': ['category'], 'type': 'btree'}
        ]
    )
}}

with products as (
    select * from {{ ref('stg_products') }}
),

orders as (
    select * from {{ ref('stg_orders') }}
),

order_items as (
    select * from {{ ref('stg_order_items') }}
),

-- Calcular métricas de productos
product_metrics as (
    select
        p.product_id,
        p.name,
        p.category,
        p.price,
        p.price_tier,
        p.product_age_category,
        -- Métricas de ventas
        count(distinct oi.order_id) as total_orders,
        sum(oi.quantity) as total_quantity_sold,
        sum(oi.item_total) as total_revenue,
        avg(oi.quantity) as avg_quantity_per_order,
        -- Métricas de clientes
        count(distinct o.user_id) as unique_customers,
        -- Métricas de descuentos
        sum(oi.discount_amount) as total_discounts_given,
        avg(oi.discount_amount) as avg_discount_per_item,
        -- Fechas
        min(o.order_date) as first_sale_date,
        max(o.order_date) as last_sale_date,
        -- Calcular días desde última venta (compatibilidad multi-base de datos)
        case
            when max(o.order_date) is not null
                then {{ datediff_days(current_date_func(), 'max(o.order_date)') }}
        end as days_since_last_sale
    from products as p
    left join order_items as oi on p.product_id = oi.product_id
    left join orders as o on oi.order_id = o.order_id and o.status = 'completed'
    group by
        p.product_id, p.name, p.category, p.price, p.price_tier, p.product_age_category
)

select * from product_metrics
