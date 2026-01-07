-- Staging layer: Limpieza básica y estandarización de productos
-- Materialización: view

with source_data as (
    select * from {{ ref('products') }}
),

renamed as (
    select
        product_id,
        name,
        category,
        price,
        created_at,
        -- Agregar campos calculados
        case
            when price < 50 then 'Económico'
            when price < 200 then 'Medio'
            else 'Premium'
        end as price_tier,
        -- Formatear precio
        concat('$', {{ cast_as_string('price') }}) as formatted_price,
        -- Clasificación de producto (compatibilidad multi-base de datos)
        case
            when
                (
                    {{ year_from_date(current_date_func()) }}
                    - {{ year_from_date('created_at') }}
                )
                < 1
                then 'Nuevo'
            when
                (
                    {{ year_from_date(current_date_func()) }}
                    - {{ year_from_date('created_at') }}
                )
                < 2
                then 'Reciente'
            else 'Establecido'
        end as product_age_category
    from source_data
)

select * from renamed
