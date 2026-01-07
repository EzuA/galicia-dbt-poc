-- Macro para calcular la tasa de crecimiento
{% macro calculate_growth_rate(current_value, previous_value) %}
    case
        when {{ previous_value }} is null or {{ previous_value }} = 0 then null
        else {{ round_numeric('(((' ~ current_value ~ ') - (' ~ previous_value ~ ')) / (' ~ previous_value ~ ')) * 100', 2) }}
    end
{% endmacro %}
