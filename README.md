psql -h localhost

CREATE USER postgres WITH PASSWORD 'postgres';

CREATE DATABASE quotes_board WITH OWNER user;
# /usr/local/pgsql/bin/createdb mydb -O user

\i db/db.sql
psql -U username -d myDataBase -a -f myInsertFile


GRANT ALL PRIVILEGES ON DATABASE quotes_board to postgres;

\q
