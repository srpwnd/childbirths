{{ config( materialized="table") }}
SELECT row_number() OVER () AS id_state,
                         state
FROM dbt_raw_data.state_names
GROUP BY state