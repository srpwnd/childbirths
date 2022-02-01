{{ config(materialized="table") }}
SELECT sn.year,
       n.id_name,
       s.id_state,
       sn.count,
       'state' as "type"
FROM dbt_raw_data.state_names sn
LEFT JOIN {{ref('dim_names')}} n ON sn.name = n.name
AND sn.sex = n.sex
LEFT JOIN {{ref('dim_states')}} s ON sn.state = s.state
UNION ALL
SELECT nn.year,
       n.id_name,
       NULL as id_state,
       nn.count,
       'national' as "type"
FROM dbt_raw_data.state_names nn
LEFT JOIN {{ref('dim_names')}} n ON nn.name = n.name
AND nn.sex = n.sex