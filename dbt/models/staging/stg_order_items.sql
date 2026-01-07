-- Staging layer: Limpieza básica y estandarización de items de órdenes
-- Materialización: view

with source_data as (
    select * from {{ ref('order_items') }}
),

products as (
    select
        product_id,
        {{ cast_as_double('price') }} as price
    from {{ ref('products') }}
),

renamed as (
    select
        oi.order_item_id,
        oi.order_id,
        oi.product_id,
        oi.quantity,
        oi.unit_price,
        -- Calcular total del item
        oi.quantity * oi.unit_price as item_total,
        -- Calcular descuento (si el precio unitario es menor al precio del producto)
        case
            when
                p.price is not null and oi.unit_price < p.price
                then p.price - oi.unit_price
            else 0
        end as discount_amount
    from source_data as oi
    left join products as p on oi.product_id = p.product_id
)

select * from renamed
