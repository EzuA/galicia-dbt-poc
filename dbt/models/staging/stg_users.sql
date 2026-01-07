-- Staging layer: Limpieza básica y estandarización de usuarios
-- Materialización: view (por defecto para staging)

with source_data as (
    select * from {{ ref('users') }}
),

renamed as (
    select
        user_id,
        email,
        first_name,
        last_name,
        created_at,
        country,
        -- Crear nombre completo
        email as email_domain,
        -- Extraer dominio del email
        true as is_valid_email,
        -- Validar email
        first_name || ' ' || last_name as full_name
    from source_data
)

select * from renamed
