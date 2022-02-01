import sqlite3 as sq
import psycopg2 as pg
import configparser

# this extractor performs incremental load of data from source DB and inserts new rows into a table in the destination database
# incremental load is based on year

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

load = pg.connect(f"dbname={dbname} user={user} password={password} host={host} port={port}")
pg_cursor = load.cursor()

# create table in case this is first time being run
pg_cursor.execute("""CREATE TABLE IF NOT EXISTS dbt_raw_data.state_names (
                        id INT PRIMARY KEY,
                        name VARCHAR(255) NOT NULL,
                        year INT NOT NULL,
                        sex VARCHAR(1) NOT NULL,
                        state VARCHAR(255) NOT NULL,
                        count INT NOT NULL
                    );""")

pg_cursor.execute("SELECT COALESCE(MAX(year), 1700) FROM dbt_raw_data.state_names;")
result = pg_cursor.fetchone()

sq_cursor.execute(f"SELECT Id, Name, Year, Gender, State, Count FROM StateNames WHERE year > {result[0]};")

# set batch size for inserting data to destination database
batch_size = 1000000 
  

for batch in iter(lambda: sq_cursor.fetchmany(batch_size), []):
    values = ""
    for row in batch:
        (id_var, name, year, sex, state, count) = row
        values += f"({id_var}, '{name}', {year}, '{sex}', '{state}', {count}),"

    values = values[:-1]  # remove last comma ,

    # insert batch values at once to save overhead of inserting by one
    pg_cursor.execute(f"INSERT INTO dbt_raw_data.state_names(id, name, year, sex, state, count) VALUES {values} ON CONFLICT (id) DO UPDATE SET count = EXCLUDED.count;")

load.commit()

# close connections
sq_cursor.close()
ext.close()

pg_cursor.close()
load.close()