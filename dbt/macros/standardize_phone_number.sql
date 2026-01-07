-- Macro para estandarizar números de teléfono
{% macro standardize_phone_number(phone_column) %}
    case
        when {{ phone_column }} is null then null
        when length(replace(replace(replace({{ phone_column }}, '-', ''), ' ', ''), '(', '')) = 10
        then '+1' || replace(replace(replace({{ phone_column }}, '-', ''), ' ', ''), '(', '')
        when length(replace(replace(replace({{ phone_column }}, '-', ''), ' ', ''), '(', '')) = 11
        and left(replace(replace(replace({{ phone_column }}, '-', ''), ' ', ''), '(', ''), 1) = '1'
        then '+' || replace(replace(replace({{ phone_column }}, '-', ''), ' ', ''), '(', '')
        else {{ phone_column }}
    end
{% endmacro %}
