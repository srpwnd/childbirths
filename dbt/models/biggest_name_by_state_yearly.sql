{{ config(materialized="view") }} 
WITH filtered as
    (SELECT *
     FROM {{ref('fact_yearly_births')}}
     WHERE id_state IS NOT NULL),
                                       ranks as
    (SELECT id_name,
            id_state,
            year,
            state_count,
            max(state_count) over (partition by id_state,
                                                year) as max_count
     FROM filtered)
SELECT r.id_name,
       n.name,
       n.sex,
       r.id_state,
       s.state_short,
       s.state_full,
       r.year,
       r.state_count
FROM ranks r
LEFT JOIN {{ref('dim_names')}} n on r.id_name = n.id_name
LEFT JOIN {{ref('dim_states')}} s on r.id_state = s.id_state
where state_count = max_count