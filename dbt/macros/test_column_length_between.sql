{% test column_length_between(model, column_name, min_length=none, max_length=none) %}
{#
    Test custom que valida que la longitud de una columna de texto esté en un rango.

    Parámetros:
    - min_length: longitud mínima permitida (opcional)
    - max_length: longitud máxima permitida (opcional)

    Uso en schema.yml:
    columns:
      - name: full_name
        tests:
          - column_length_between:
              min_length: 3
              max_length: 100
#}

select
    {{ column_name }} as valor_invalido,
    length({{ column_name }}) as longitud,
    count(*) as num_ocurrencias
from {{ model }}
where
    {{ column_name }} is null
    {% if min_length is not none %}
    or length({{ column_name }}) < {{ min_length }}
    {% endif %}
    {% if max_length is not none %}
    or length({{ column_name }}) > {{ max_length }}
    {% endif %}
group by {{ column_name }}, length({{ column_name }})

{% endtest %}
