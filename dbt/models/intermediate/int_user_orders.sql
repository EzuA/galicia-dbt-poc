-- Intermediate layer: Agregación de métricas de usuarios y órdenes
-- Materialización: table

{{
    config(
        materialized='table',
        indexes=[
            {'columns': ['user_id'], 'type': 'btree'}
        ]
    )
}}

with users as (
    select * from {{ ref('stg_users') }}
),

orders as (
    select * from {{ ref('stg_orders') }}
),

order_items as (
    select * from {{ ref('stg_order_items') }}
),

-- Calcular métricas por usuario
user_metrics as (
    select
        u.user_id,
        u.full_name,
        u.country,
        u.email_domain,
        u.is_valid_email,
        -- Métricas de órdenes
        count(distinct o.order_id) as total_orders,
        count(distinct case when o.status = 'completed' then o.order_id end)
            as completed_orders,
        count(distinct case when o.status = 'cancelled' then o.order_id end)
            as cancelled_orders,
        -- Métricas de gasto
        coalesce(
            sum(case when o.status = 'completed' then o.total_amount else 0 end), 0
        ) as total_spent,
        coalesce(avg(case when o.status = 'completed' then o.total_amount end), 0)
            as avg_order_value,
        coalesce(max(case when o.status = 'completed' then o.total_amount end), 0)
            as max_order_value,
        -- Métricas de productos
        count(distinct oi.product_id) as unique_products_purchased,
        sum(oi.quantity) as total_items_purchased,
        -- Fechas
        min(o.order_date) as first_order_date,
        max(o.order_date) as last_order_date,
        -- Calcular días desde última compra (compatibilidad multi-base de datos)
        case
            when max(o.order_date) is not null
                then {{ datediff_days(current_date_func(), 'max(o.order_date)') }}
        end as days_since_last_order
    from users as u
    left join orders as o on u.user_id = o.user_id
    left join order_items as oi on o.order_id = oi.order_id
    group by u.user_id, u.full_name, u.country, u.email_domain, u.is_valid_email
)

select * from user_metrics
