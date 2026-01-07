{% macro cast_as_double(column_name) %}
    {%- if target.type == 'spark' -%}
        CAST({{ column_name }} AS DOUBLE)
    {%- elif target.type == 'postgres' -%}
        CAST({{ column_name }} AS DOUBLE PRECISION)
    {%- else -%}
        CAST({{ column_name }} AS DOUBLE PRECISION)
    {%- endif -%}
{% endmacro %}

{% macro round_numeric(expression, decimals=2) %}
    {%- if target.type == 'spark' -%}
        round({{ expression }}, {{ decimals }})
    {%- elif target.type == 'postgres' -%}
        round(CAST({{ expression }} AS NUMERIC), {{ decimals }})
    {%- else -%}
        round({{ expression }}, {{ decimals }})
    {%- endif -%}
{% endmacro %}

{% macro cast_as_string(column_name) %}
    {%- if target.type == 'spark' -%}
        CAST({{ column_name }} AS STRING)
    {%- elif target.type == 'postgres' -%}
        CAST({{ column_name }} AS VARCHAR)
    {%- else -%}
        CAST({{ column_name }} AS VARCHAR)
    {%- endif -%}
{% endmacro %}

{% macro datediff_days(end_date, start_date) %}
    {%- if target.type == 'spark' -%}
        datediff({{ end_date }}, {{ start_date }})
    {%- elif target.type == 'postgres' -%}
        ({{ end_date }}::date - {{ start_date }}::date)
    {%- else -%}
        datediff('day', {{ start_date }}, {{ end_date }})
    {%- endif -%}
{% endmacro %}

{% macro year_from_date(date_column) %}
    {%- if target.type == 'spark' -%}
        year({{ date_column }})
    {%- elif target.type == 'postgres' -%}
        EXTRACT(YEAR FROM {{ date_column }})
    {%- else -%}
        EXTRACT(YEAR FROM {{ date_column }})
    {%- endif -%}
{% endmacro %}

{% macro current_date_func() %}
    {%- if target.type == 'spark' -%}
        current_date()
    {%- elif target.type == 'postgres' -%}
        CURRENT_DATE
    {%- else -%}
        CURRENT_DATE
    {%- endif -%}
{% endmacro %}

{% macro concat_ws(separator, field1, field2='', field3='', field4='') %}
    {%- set fields = [field1, field2, field3, field4] | reject('equalto', '') | list -%}
    {%- if target.type == 'spark' -%}
        concat_ws('{{ separator }}', {{ fields | join(', ') }})
    {%- elif target.type == 'postgres' -%}
        concat({{ fields | join(" || '" + separator + "' || ") }})
    {%- else -%}
        concat({{ fields | join(" || '" + separator + "' || ") }})
    {%- endif -%}
{% endmacro %}

{% macro lpad_string(column_name, length, pad_char) %}
    {%- if target.type == 'spark' -%}
        lpad({{ column_name }}, {{ length }}, '{{ pad_char }}')
    {%- elif target.type == 'postgres' -%}
        lpad({{ column_name }}, {{ length }}, '{{ pad_char }}')
    {%- else -%}
        lpad({{ column_name }}, {{ length }}, '{{ pad_char }}')
    {%- endif -%}
{% endmacro %}
