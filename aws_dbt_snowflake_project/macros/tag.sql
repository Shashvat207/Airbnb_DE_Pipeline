{% macro tag(col) %}

    CASE 
        WHEN {{col}}<100 THEN 'low'
        WHEN {{col}}<200 THEN 'Medium'
        ELSE 'high'
    END

{% endmacro %}