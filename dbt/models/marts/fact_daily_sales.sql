-- Marts layer: Tabla de hechos de ventas diarias
-- Materialización: table

{{
    config(
        materialized='table',
        indexes=[
            {'columns': ['date'], 'type': 'btree'},
            {'columns': ['country'], 'type': 'btree'}
        ]
    )
}}

with orders as (
    select * from {{ ref('stg_orders') }}
),

order_items as (
    select * from {{ ref('stg_order_items') }}
),

users as (
    select * from {{ ref('stg_users') }}
),

-- Métricas diarias por país
daily_metrics as (
    select
        o.order_date_only as date,
        u.country,
        u.email_domain,
        -- Métricas de órdenes
        count(distinct o.order_id) as daily_orders,
        count(distinct case when o.status = 'completed' then o.order_id end)
            as daily_completed_orders,
        count(distinct case when o.status = 'cancelled' then o.order_id end)
            as daily_cancelled_orders,
        -- Métricas de clientes
        count(distinct o.user_id) as daily_active_customers,
        count(distinct case when o.status = 'completed' then o.user_id end)
            as daily_purchasing_customers,
        -- Métricas de ingresos
        sum(case when o.status = 'completed' then o.total_amount else 0 end)
            as daily_revenue,
        avg(case when o.status = 'completed' then o.total_amount end)
            as daily_avg_order_value,
        -- Métricas de productos
        count(distinct oi.product_id) as daily_unique_products,
        sum(oi.quantity) as daily_items_sold,
        -- Métricas de descuentos
        sum(oi.discount_amount) as daily_discounts_given,
        -- Tasa de conversión diaria
        case
            when count(distinct o.user_id) > 0
                then
                    {{
                        round_numeric(
                            '(' ~ cast_as_double('count(distinct case when o.status = ''completed'' then o.user_id end)')
                            ~ ' / '
                            ~ cast_as_double('count(distinct o.user_id)') ~ ') * 100',
                            2
                        )
                    }}
            else 0
        end as daily_conversion_rate
    from orders as o
    left join order_items as oi on o.order_id = oi.order_id
    left join users as u on o.user_id = u.user_id
    group by o.order_date_only, u.country, u.email_domain
)

select * from daily_metrics
