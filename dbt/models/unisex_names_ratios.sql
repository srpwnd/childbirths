{{ config(materialized="view") }}
SELECT f.id_name as id_name_female,
       m.id_name as id_name_male,
       f.name,
       fc.year,
       fc.national_count as female_count,
       mc.national_count as male_count,
       fc.national_count::decimal/mc.national_count::decimal as f_to_m_ratio
FROM {{ref('dim_names')}} f
INNER JOIN {{ref('dim_names')}} m ON f.name = m.name
LEFT JOIN {{ref('fact_yearly_births')}} fc on f.id_name = fc.id_name
LEFT JOIN {{ref('fact_yearly_births')}} mc on m.id_name = mc.id_name
and fc.year = mc.year
WHERE f.sex = 'F'
    and m.sex = 'M'