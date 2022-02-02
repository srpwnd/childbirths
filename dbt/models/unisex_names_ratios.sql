{{ config(materialized="view") }}
SELECT f.id_name as id_name_female,
       m.id_name as id_name_male,
       f.name,
       SUM(fc.national_count) as female_count,
       SUM(mc.national_count) as male_count,
       SUM(fc.national_count) + SUM(mc.national_count) as total_count,
       SUM(fc.national_count)::decimal/SUM(mc.national_count)::decimal as f_to_m_ratio
FROM {{ref('dim_names')}} f
INNER JOIN {{ref('dim_names')}} m ON f.name = m.name
LEFT JOIN {{ref('fact_yearly_births')}} fc on f.id_name = fc.id_name
LEFT JOIN {{ref('fact_yearly_births')}} mc on m.id_name = mc.id_name
and fc.year = mc.year
WHERE f.sex = 'F'
    and m.sex = 'M'
group by f.id_name, m.id_name, f.name 