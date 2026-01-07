-- Snapshot de productos para tracking de cambios
{% snapshot snap_products %}

{{
    config(
        target_schema='snapshots',
        unique_key='product_id',
        strategy='timestamp',
        updated_at='updated_at'
    )
}}

    select
        product_id,
        name,
        category,
        price,
        created_at,
        current_timestamp as updated_at
    from {{ ref('products') }}

{% endsnapshot %}
