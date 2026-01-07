-- Staging layer: Limpieza básica y estandarización de órdenes
-- Materialización: view

with source_data as (
    select * from {{ ref('orders') }}
),

renamed as (
    select
        order_id,
        user_id,
        order_date,
        status,
        total_amount,
        -- Agregar campos calculados
        case
            when status = 'completed' then 'Completada'
            when status = 'pending' then 'Pendiente'
            when status = 'shipped' then 'Enviada'
            when status = 'cancelled' then 'Cancelada'
            else 'Desconocida'
        end as status_spanish,
        -- Extraer componentes de fecha
        date(order_date) as order_date_only,
        extract(year from order_date) as order_year,
        extract(month from order_date) as order_month,
        extract(quarter from order_date) as order_quarter,
        extract(dow from order_date) as day_of_week,
        -- Clasificación de orden
        case
            when total_amount < 50 then 'Pequeña'
            when total_amount < 200 then 'Mediana'
            else 'Grande'
        end as order_size
    from source_data
)

select * from renamed
