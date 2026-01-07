{% test column_match_pattern(model, column_name, pattern, negate=false) %}
{#
    Test custom que valida que los valores de una columna coincidan con un patrón.

    Parámetros:
    - pattern: patrón SQL para validar (ej: '%@%.%' para emails)
    - negate: si es true, valida que NO coincida con el patrón

    Uso en schema.yml:
    columns:
      - name: email
        tests:
          - column_match_pattern:
              pattern: '%@%.%'
#}

select
    {{ column_name }} as valor_invalido,
    count(*) as num_ocurrencias
from {{ model }}
where
    {% if negate %}
    {{ column_name }} like '{{ pattern }}'
    {% else %}
    {{ column_name }} not like '{{ pattern }}'
    {% endif %}
    or {{ column_name }} is null
group by {{ column_name }}

{% endtest %}
