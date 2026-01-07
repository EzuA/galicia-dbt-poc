-- Marts layer: Dimensión de usuarios con métricas de negocio
-- Materialización: table

{{
    config(
        materialized='table',
        indexes=[
            {'columns': ['user_id'], 'type': 'btree'},
            {'columns': ['customer_tier'], 'type': 'btree'},
            {'columns': ['country'], 'type': 'btree'}
        ]
    )
}}

with user_metrics as (
    select * from {{ ref('int_user_orders') }}
),

country_codes as (
    select * from {{ ref('country_codes') }}
),

-- Enriquecer con información de país y clasificar clientes
enriched_users as (
    select
        um.*,
        -- Agregar información de país
        cc.country_code,
        cc.currency,
        cc.timezone,
        -- Clasificar clientes por valor
        case
            when um.total_spent >= 1000 then 'VIP'
            when um.total_spent >= 500 then 'Premium'
            when um.total_spent >= 100 then 'Regular'
            when um.total_spent > 0 then 'Básico'
            else 'Inactivo'
        end as customer_tier,
        -- Calcular RFM score (simplificado)
        case
            when um.days_since_last_order <= 30 then 5
            when um.days_since_last_order <= 90 then 4
            when um.days_since_last_order <= 180 then 3
            when um.days_since_last_order <= 365 then 2
            else 1
        end as recency_score,
        case
            when um.total_orders >= 10 then 5
            when um.total_orders >= 5 then 4
            when um.total_orders >= 3 then 3
            when um.total_orders >= 2 then 2
            else 1
        end as frequency_score,
        case
            when um.total_spent >= 1000 then 5
            when um.total_spent >= 500 then 4
            when um.total_spent >= 200 then 3
            when um.total_spent >= 100 then 2
            else 1
        end as monetary_score,
        -- Usar macro para símbolo de moneda
        {{ get_currency_symbol('um.country') }} as currency_symbol
    from user_metrics as um
    left join country_codes as cc on um.country = cc.country
    where um.is_valid_email = true  -- Solo usuarios con email válido
)

select * from enriched_users
