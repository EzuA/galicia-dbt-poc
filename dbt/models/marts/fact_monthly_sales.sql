-- Marts layer: Tabla de hechos de ventas mensuales con crecimiento
-- Materialización: incremental

{{
    config(
        materialized='incremental',
        unique_key='year_month',
        on_schema_change='fail'
    )
}}

with monthly_sales as (
    select * from {{ ref('int_monthly_sales') }}
),

-- Calcular métricas de crecimiento
growth_metrics as (
    select
        *,
        lag(total_revenue) over (order by year_month) as prev_period_revenue,
        lag(total_orders) over (order by year_month) as prev_period_orders,
        lag(unique_customers) over (order by year_month) as prev_period_customers,
        -- Usar macro para calcular crecimiento
        {{
            calculate_growth_rate(
                'total_revenue',
                'lag(total_revenue) over (order by year_month)'
            )
        }} as revenue_growth_pct,
        {{
            calculate_growth_rate(
                'total_orders',
                'lag(total_orders) over (order by year_month)'
            )
        }} as orders_growth_pct,
        {{
            calculate_growth_rate(
                'unique_customers',
                'lag(unique_customers) over (order by year_month)'
            )
        }} as customers_growth_pct
    from monthly_sales
)

select * from growth_metrics

{% if is_incremental() %}
    -- Solo procesar datos nuevos en ejecuciones incrementales
    where year_month > (select max(year_month) from {{ this }})
{% endif %}
