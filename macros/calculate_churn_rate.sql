{% macro calculate_churn_rate(churned_count, total_count) %}
    CASE 
        WHEN {{ total_count }} > 0 
        THEN CAST({{ churned_count }} AS FLOAT) / {{ total_count }}
        ELSE NULL 
    END
{% endmacro %}
