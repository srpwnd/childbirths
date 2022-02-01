import sqlite3 as sq
import psycopg2 as pg
import configparser

# this extractor performs full load of data from source DB and rewrites any existing data in destination DB

# parse credentials from config file
parser = configparser.ConfigParser()
parser.read("/datafiles/pipeline.conf")
dbname = parser.get("dbt_postgres_credentials", "database")
user = parser.get("dbt_postgres_credentials", "username")
password = parser.get("dbt_postgres_credentials", "password")
host = parser.get("dbt_postgres_credentials", "host")
port = parser.get("dbt_postgres_credentials", "port")


# connect to source DB
ext = sq.connect("/datafiles/database.sqlite")
sq_cursor = ext.cursor()

# extract full data from source
sq_cursor.execute("SELECT Id, Name, Year, Gender, Count FROM NationalNames;")

# connect to destination DB
load = pg.connect(f"dbname={dbname} user={user} password={password} host={host} port={port}")
pg_cursor = load.cursor()


# create table in case this is first time being run
pg_cursor.execute("""CREATE TABLE IF NOT EXISTS dbt_raw_data.national_names (
                        id INT PRIMARY KEY,
                        name VARCHAR(255) NOT NULL,
                        year INT NOT NULL,
                        sex VARCHAR(1) NOT NULL,
                        count INT NOT NULL
                    );""")


# truncate all data in table in case it has data from previous runs
pg_cursor.execute("TRUNCATE TABLE dbt_raw_data.national_names;")


# set batch size for inserting data to destination database
batch_size = 1000000 
  

for batch in iter(lambda: sq_cursor.fetchmany(batch_size), []):
    values = ""
    for row in batch:
        (id_var, name, year, sex, count) = row
        values += f"({id_var}, '{name}', {year}, '{sex}', {count}),"

    values = values[:-1]  # remove last comma ,

    # insert batch values at once to save overhead of inserting by one
    pg_cursor.execute(f"INSERT INTO dbt_raw_data.national_names(id, name, year, sex, count) VALUES {values};")

load.commit()

# close connections
sq_cursor.close()
ext.close()

pg_cursor.close()
load.close()
