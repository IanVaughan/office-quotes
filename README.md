
## Set the shit up

    $ psql -h localhost

    # CREATE USER postgres WITH PASSWORD 'postgres';

    # CREATE DATABASE quotes_board WITH OWNER postgres;   #or /usr/local/pgsql/bin/createdb mydb -O user

    # GRANT ALL PRIVILEGES ON DATABASE quotes_board to postgres;

    # \q

## Run the shit

    rackup
