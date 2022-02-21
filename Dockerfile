FROM python:3.9
RUN pip install 'apache-airflow[postgres]' && pip install dbt
RUN pip install airflow-dbt
RUN pip install SQLAlchemy
RUN mkdir /project
COPY scripts_airflow/ /project/scripts/

RUN chmod +x /project/scripts/init.sh
ENTRYPOINT [ "/project/scripts/init.sh" ]
