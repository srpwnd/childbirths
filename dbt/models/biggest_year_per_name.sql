{{ config(materialized="view") }} 
WITH names_ranked as
    ( SELECT year,
             id_name,
             national_count,
             rank() OVER (PARTITION BY id_name
                          ORDER BY national_count DESC) as rank
     FROM {{ref('fact_yearly_births')}})
SELECT year,
       name,
       sex,
       national_count
FROM names_ranked nr
LEFT JOIN {{ref('dim_names')}} n ON nr.id_name = n.id_name
WHERE rank = 1
GROUP BY year, name, sex, national_count