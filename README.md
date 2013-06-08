## Set the shit up

    $ psql -h localhost

    # CREATE USER postgres WITH PASSWORD 'postgres';

    # CREATE DATABASE quotes_board WITH OWNER postgres;   #or /usr/local/pgsql/bin/createdb mydb -O user

    # GRANT ALL PRIVILEGES ON DATABASE quotes_board to postgres;

    # \q

## Run the shit

    rackup


## Back this shit up

    heroku pgbackups:capture # perform manual backup
    curl -o latest.dump `heroku pgbackups:url` # download latest backup

    heroku pgbackups # list backups

    # import downloaded dump into local DB
    pg_restore --verbose --clean --no-acl --no-owner -h localhost -U postgres -d quotes_board ~/Downloads/latest.dump

* [heroku help 1](https://devcenter.heroku.com/articles/pgbackups#downloading-a-backup)
* [heroku help 2](https://devcenter.heroku.com/articles/heroku-postgres-import-export#export)


## Credits

* All goes to [@timtait](https://github.com/timtait)
