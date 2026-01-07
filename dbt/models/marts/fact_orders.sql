-- Marts layer: Tabla de hechos de órdenes
-- Materialización: table

{{
    config(
        materialized='table',
        indexes=[
            {'columns': ['order_id'], 'type': 'btree'},
            {'columns': ['user_id'], 'type': 'btree'},
            {'columns': ['order_date'], 'type': 'btree'},
            {'columns': ['status'], 'type': 'btree'}
        ]
    )
}}

with orders as (
    select * from {{ ref('stg_orders') }}
),

order_items as (
    select * from {{ ref('stg_order_items') }}
),

products as (
    select * from {{ ref('stg_products') }}
),

-- Crear tabla de hechos con detalles de items
fact_orders as (
    select
        o.order_id,
        o.user_id,
        o.order_date,
        o.order_date_only,
        o.order_year,
        o.order_month,
        o.order_quarter,
        o.day_of_week,
        o.status,
        o.status_spanish,
        o.order_size,
        o.total_amount,
        -- Información de items
        oi.order_item_id,
        oi.product_id,
        oi.quantity,
        oi.unit_price,
        oi.item_total,
        oi.discount_amount,
        -- Información de producto
        p.name as product_name,
        p.category as product_category,
        p.price_tier,
        p.product_age_category,
        -- Calcular margen estimado
        case
            when oi.unit_price > 0 then
                {{
                    round_numeric(
                        '((oi.unit_price - (p.price * 0.7)) / oi.unit_price) * 100',
                        2
                    )
                }}
        end as estimated_margin_pct
    from orders as o
    left join order_items as oi on o.order_id = oi.order_id
    left join products as p on oi.product_id = p.product_id
)

select * from fact_orders
