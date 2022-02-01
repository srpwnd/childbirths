{{ config(materialized="view") }} 
WITH ranked as
    (SELECT *,
            rank() over (partition by year
                         order by ABS(1 - f_to_m_ratio)) as distance
     FROM {{ref('unisex_names_ratios')}})
SELECT year,
       name,
       female_count,
       male_count,
       f_to_m_ratio
FROM ranked
WHERE distance = 1