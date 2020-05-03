## Run a Containerised MariaDB Server for Waltz 

The command below can be used to spin up a MariaDB database server instance for use with Waltz.

`MYSQL_DATABASE` is set to `waltz`, so that the default database created by MariaDB is named as `waltz`.
Set username and password using environment variables (`MYSQL_USER`, `MYSQL_PASSWORD`) as in the command below to create a new user named `waltz`, which will be granted access to the `waltz` database.

_Optional_: Use `-p 3306:3306` in the command to access your database server using the host machine's IP address.

> By default, Docker manages data peristence by writing database files to disk on the host system. This is transparent to the user and data is preserved between container restarts (until the container is removed).  
>
> While this is sufficient for dev/test instances, it is recommended that you explore options like mounting directories onto the MariaDB docker container to store data, backups etc.
>
> More information on running MariaDB in a Docker container can be found here: [MariaDB Docker Official Documentation](https://hub.docker.com/_/mariadb)

```console
# run the database container in the background

[user@machine:waltz-docker]$ docker run -d \
--name waltz-db-mariadb \
-e MYSQL_ROOT_PASSWORD=waltz_root \
-e MYSQL_USER=waltz \
-e MYSQL_PASSWORD=waltz \
-e MYSQL_DATABASE=waltz \
mariadb:10.4 \
--character-set-server=utf8mb4 \
--collation-server=utf8mb4_unicode_ci
```

### Connect to the MariaDB Server SQL Client
```console
# docker exec -it <container_name> mysql <db_name> -u <user_name> -p
# use the password set above when prompted

[user@machine:waltz-docker]$ docker exec -it waltz-db-mariadb mysql waltz -u waltz -p
```

### Find IP Address of the MariaDB Server (to use in Maven settings.xml)
```console
# docker exec <container_name> hostname -I

[user@machine:waltz-docker]$ docker exec waltz-db-mariadb hostname -I
```