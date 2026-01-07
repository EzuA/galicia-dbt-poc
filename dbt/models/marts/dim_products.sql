-- Marts layer: Dimensión de productos con métricas de rendimiento
-- Materialización: table

{{
    config(
        materialized='table',
        indexes=[
            {'columns': ['product_id'], 'type': 'btree'},
            {'columns': ['category'], 'type': 'btree'},
            {'columns': ['price_tier'], 'type': 'btree'}
        ]
    )
}}

with product_metrics as (
    select * from {{ ref('int_product_metrics') }}
),

product_categories as (
    select * from {{ ref('product_categories') }}
),

-- Enriquecer con información de categoría y rankings
enriched_products as (
    select
        pm.*,
        -- Agregar información de categoría
        pc.category_description,
        pc.parent_category,
        -- Agregar rankings
        row_number() over (order by pm.total_revenue desc nulls last) as revenue_rank,
        row_number()
            over (order by pm.total_quantity_sold desc nulls last)
            as quantity_rank,
        row_number() over (order by pm.total_orders desc nulls last) as orders_rank,
        row_number()
            over (order by pm.unique_customers desc nulls last)
            as customers_rank,
        -- Clasificación de rendimiento
        case
            when pm.total_revenue >= 1000 then 'Top Performer'
            when pm.total_revenue >= 500 then 'High Performer'
            when pm.total_revenue >= 100 then 'Medium Performer'
            when pm.total_revenue > 0 then 'Low Performer'
            else 'No Sales'
        end as performance_category,
        -- Calcular tasa de conversión (simplificada)
        case
            when pm.total_orders > 0
                then
                    {{
                        round_numeric(
                            '(' ~ cast_as_double('pm.total_quantity_sold')
                            ~ ' / '
                            ~ cast_as_double('pm.total_orders') ~ ')',
                            2
                        )
                    }}
            else 0
        end as conversion_rate
    from product_metrics as pm
    left join product_categories as pc on pm.category = pc.category
)

select * from enriched_products
