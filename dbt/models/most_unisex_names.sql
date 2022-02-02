{{ config(materialized="view") }} 
WITH filtered as
    (SELECT *
     FROM {{ref('unisex_names_ratios')}}
     WHERE total_count > 100000)
SELECT name,
       female_count,
       male_count,
       total_count,
       f_to_m_ratio,
       rank() over (order by ABS(1 - f_to_m_ratio)) as rank
FROM filtered
ORDER BY rank