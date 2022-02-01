from datetime import datetime

from airflow import DAG
from airflow.operators.bash import BashOperator

dag = DAG(
    dag_id='incremental_dag',
    schedule_interval=None,
    start_date=datetime(2022, 1, 1),
    catchup=False,
    tags=['childbirths', 'incremental'],
)

ext1 = BashOperator(
    task_id='extract_national_names',
    bash_command='python /python/national_names_extractor_incremental.py',
    dag=dag,
)

ext2 = BashOperator(
    task_id='extract_state_names',
    bash_command='python /python/state_names_extractor_incremental.py',
    dag=dag,
)

ext1 >> ext2
