-- Macro para obtener el símbolo de moneda según el país
{% macro get_currency_symbol(country) %}
    case
        when {{ country }} = 'Argentina' then '$'
        when {{ country }} = 'México' then '$'
        when {{ country }} = 'Colombia' then '$'
        when {{ country }} = 'Chile' then '$'
        when {{ country }} = 'España' then '€'
        else '$'
    end
{% endmacro %}
