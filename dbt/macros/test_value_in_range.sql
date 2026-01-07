{% test value_in_range(model, column_name, min_value=none, max_value=none, include_null=false) %}
{#
    Test custom que valida que los valores de una columna estén en un rango permitido.

    Parámetros:
    - min_value: valor mínimo permitido (opcional)
    - max_value: valor máximo permitido (opcional)
    - include_null: si se permiten valores null (default: false)

    Uso en schema.yml:
    columns:
      - name: total_amount
        tests:
          - value_in_range:
              min_value: 0
              max_value: 10000
#}

select
    {{ column_name }} as valor_fuera_de_rango,
    count(*) as num_ocurrencias
from {{ model }}
where
    {% if not include_null %}
    {{ column_name }} is null
    {% if min_value is not none or max_value is not none %}
    or
    {% endif %}
    {% endif %}

    {% if min_value is not none %}
    {{ column_name }} < {{ min_value }}
    {% endif %}

    {% if min_value is not none and max_value is not none %}
    or
    {% endif %}

    {% if max_value is not none %}
    {{ column_name }} > {{ max_value }}
    {% endif %}
group by {{ column_name }}

{% endtest %}
