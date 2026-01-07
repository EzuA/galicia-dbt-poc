-- Macro para generar una serie de fechas
{% macro generate_date_series(start_date, end_date) %}
    select
        generate_series(
            '{{ start_date }}'::date,
            '{{ end_date }}'::date,
            '1 day'::interval
        )::date as date
{% endmacro %}
