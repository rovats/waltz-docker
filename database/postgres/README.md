## Run a Containerised Postgres Server for Waltz 

The command below can be used to spin up a Postgres database server instance for use with Waltz. 
While this is sufficient for dev/demo instances, it is recommended that you follow the official Postgres documentation to set up your database server for production to ensure your data is safe.

Set the default username and password using environment variables as in the command below.
`POSTGRES_DB` is set to `waltz`, so that the default database created by Postgres is named as `waltz`.

More information on running Postgres in a Docker container can be found here: [Postgres Docker Official Documentation](https://hub.docker.com/_/postgres)

```console
# run the database container in the background

[user@machine:waltz-docker]$ docker run -d \
--name waltz-db-postgres \
-e POSTGRES_USER=waltz \
-e POSTGRES_PASSWORD=waltz \
-e POSTGRES_DB=waltz \
-p 5432:5432 \
postgres:9.6;
```

### Connect to the Postgres Server SQL Client
```console
# use the password set above when prompted

[user@machine:waltz-docker]$ docker exec -it waltz-db-postgres psql -U waltz
```

### Find IP Address of the Postgres Server (to use in Maven settings.xml)
```console
[user@machine:waltz-docker]$ docker exec waltz-db-postgres hostname -I
```