{{ config( materialized="table") }}
SELECT row_number() OVER () AS id_name,
                         name,
                         sex
FROM dbt_raw_data.national_names
GROUP BY name,
         sex