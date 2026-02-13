{% macro calculate_success_rate(successful_count, total_count) %}
    CASE 
        WHEN {{ total_count }} > 0 
        THEN CAST({{ successful_count }} AS FLOAT) / {{ total_count }}
        ELSE NULL 
    END
{% endmacro %}
