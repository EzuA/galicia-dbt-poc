-- Macro para validar formato de email (compatible con Spark y PostgreSQL)
{% macro validate_email(email_column) %}
    {%- if target.type == 'spark' -%}
        case
            when {{ email_column }} RLIKE '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$' then true
            else false
        end
    {%- elif target.type == 'postgres' -%}
        case
            when {{ email_column }} ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' then true
            else false
        end
    {%- else -%}
        case
            when {{ email_column }} ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' then true
            else false
        end
    {%- endif -%}
{% endmacro %}
