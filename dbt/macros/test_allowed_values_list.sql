{% test allowed_values_list(model, column_name, values) %}
{#
    Test custom que valida que los valores de una columna estén en una lista permitida.

    Uso en schema.yml:
    columns:
      - name: status_spanish
        tests:
          - allowed_values_list:
              values: ['Completada', 'Pendiente', 'Enviada', 'Cancelada']
#}

select
    {{ column_name }} as valor_invalido,
    count(*) as num_ocurrencias
from {{ model }}
where {{ column_name }} not in (
    {% for value in values %}
        '{{ value }}'{% if not loop.last %}, {% endif %}
    {% endfor %}
)
    or {{ column_name }} is null
group by {{ column_name }}

{% endtest %}
