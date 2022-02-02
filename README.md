# Childbirths
This project consist of multiple services that work together to extract, load, transform and visualize data.
### Components
+ Postgres
    + database for Airflow
    + database for DWH
+ Airflow
+ dbt
+ Metabase
+ Adminer
## Usage
### Requirements
You need to have installed `docker` and `docker-compose`.
### How to run
1. clone this repo
2. navigate to the root directory of cloned repo
3. run this command:

        $ docker-compose up

### How to use
You can access services under these addresses with these credentials:
__Airflow__
`http://localhost:8000`

    username: airflow
    password: pssd

__Adminer__
`http://localhost:8080`

DWH database

    system: PostgreSQL
    server: dbt-db
    username: dbtuser
    password: dbtpassword
    database: dbtdatabase

Airflow database

    system: PostgreSQL
    server: airflow-db
    username: airflowuser
    password: pssd
    database: airflowdb

__Metabase__
`http://localhost:3000`

No need for any authentication.

When first starting this project you will need to wait approx 10 minutes before the database is populated with data. Until then Metabase will fail to display any data. (Check Airflow to see progress on running DAG.)

### How to discard data
When you are finished with the project and want to discard residue data from your system, run the following commands:

    $ docker-compose down
    $ docker volume rm childbirths_pg-data