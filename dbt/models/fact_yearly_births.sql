{{ config(materialized="table") }}
SELECT COALESCE(sn.year,nn.year) as year,
       n.id_name,
       s.id_state,
       sn.count as state_count,
       nn.count as national_count
FROM dbt_raw_data.state_names sn
FULL OUTER JOIN dbt_raw_data.national_names nn ON sn.year = nn.year and sn.name = nn.name and sn.sex = nn.sex
LEFT JOIN {{ref('dim_names')}} n ON COALESCE(sn.name, nn.name) = n.name
AND COALESCE(sn.sex, nn.sex) = n.sex
LEFT JOIN {{ref('dim_states')}} s ON sn.state = s.state_short