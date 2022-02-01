{{ config(materialized="view") }}
SELECT f.year,
       n.name,
       n.sex,
       COALESCE(s.state_short,'(unavailable)') as state_short,
       COALESCE(s.state_full,'(unavailable)') as state_full,
       f.state_count,
       f.national_count
FROM {{ref('fact_yearly_births')}} f
LEFT JOIN {{ref('dim_names')}} n ON f.id_name = n.id_name
LEFT JOIN {{ref('dim_states')}} s ON f.id_state = s.id_state