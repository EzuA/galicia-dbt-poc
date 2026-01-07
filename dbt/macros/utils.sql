{% macro execute_sql(query) %}
  {% set results = run_query(query) %}
  {{ log("Query executed successfully", info=True) }}
  -- Optional: use print_table(results) for a better output format
{% endmacro %}
