## Run a Containerised Postgres Server for Waltz 

The command below can be used to spin up a Postgres database server instance for use with Waltz.  

Set the default username and password using environment variables as in the command below.  
`POSTGRES_DB` is set to `waltz`, so that the default database created by Postgres is named as `waltz`.

_Optional_: Use `-p 5432:5432` in the command to access your database server using the host machine's IP address.

> By default, Docker manages data peristence by writing database files to disk on the host system. This is transparent to the user and data is preserved between container restarts (until the container is removed).  
>
> While this is sufficient for dev/test instances, it is recommended that you explore options like mounting directories onto the Postgres docker container to store data, backups etc.
>
> More information on running Postgres in a Docker container can be found here: [Postgres Docker Official Documentation](https://hub.docker.com/_/postgres)

```console
# run the database container in the background

[user@machine:waltz-docker]$ docker run -d \
--name waltz-db-postgres \
-e POSTGRES_USER=waltz \
-e POSTGRES_PASSWORD=waltz \
-e POSTGRES_DB=waltz \
postgres:10.6
```

### Sample Data
Waltz maintainers provide sample data dumps for Postgres, which can be downloaded from the [releases page](https://github.com/finos/waltz/releases) and used to initialise your database.

1. Download the `dump_pg_*.zip` file for the latest available release (data dumps from older releases will also work, as the build process will upgrade your database)
2. Extract the `.sql` file (ususally named `dump.sql`) from the zip
3. Copy the `dump.sql` file to the `database/postgres` directory
4. Run the command to create the database, using the `-v` option to mount `database/postgres` to the container's `/docker-entrypoint-initdb.d` directory, so that Postgres can use the `dump.sql` file to initialise your `waltz` database

> `POSTGRES_USER` must be set to `postgres` for the import to work correctly, as this is what the `dump.sql` file uses

> Make sure the Postgres version in the command below matches the version in `dump.sql` file (check the line containing: _Dumped from database version_)

> This command must be run from the `waltz-docker` root directory

```console
# run the database container in the background

[user@machine:waltz-docker]$ docker run -d \
--name waltz-db-postgres \
-e POSTGRES_USER=postgres \
-e POSTGRES_PASSWORD=waltz \
-e POSTGRES_DB=waltz \
-v "${PWD}"/database/postgres:/docker-entrypoint-initdb.d \
postgres:10.6
```

### Connect to the Postgres Server SQL Client
```console
# pass the username used when creating the DB in the -U option
# docker exec -it <container_name> psql -d <db_name> -U <user_name>
# use the password set above when prompted

[user@machine:waltz-docker]$ docker exec -it waltz-db-postgres psql -d waltz -U waltz
or
[user@machine:waltz-docker]$ docker exec -it waltz-db-postgres psql -d waltz -U postgres
```

### Find IP Address of the Postgres Server (to use in Maven settings.xml)
```console
[user@machine:waltz-docker]$ docker exec waltz-db-postgres hostname -I
```