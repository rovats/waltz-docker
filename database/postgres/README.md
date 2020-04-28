## Run a Containerised Postgres Server for Waltz 

Data will be persisted between container restarts.  
Local data directory: `database/postgres/data` (specified in the `-v` option below).

```console
# run the container in the background

[user@machine:waltz-docker]$ docker run -d --rm \
--name waltz-db-postgres \
-v "$PWD"/database/postgres/data:/var/lib/postgresql/data \
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