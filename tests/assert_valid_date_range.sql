{% test assert_valid_date_range(model, start_date_column, end_date_column) %}

SELECT *
FROM {{ model }}
WHERE {{ end_date_column }} IS NOT NULL
    AND {{ start_date_column }} > {{ end_date_column }}

{% endtest %}
