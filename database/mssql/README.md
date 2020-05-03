## Run a Containerised MSSQL Server for Waltz 

The commands below can be used to spin up a MSSQL database server instance (Developer Edition) for use with Waltz.

> Microsoft only allows Developer editions to be used for dev/test systems, not for production. Please refer to Microsoft official documentation for licence terms and setting up a production database instance.
>
> More information on running MSSQL in a Docker container can be found here: [MSSQL Docker Official Documentation](https://hub.docker.com/_/microsoft-mssql-server)

### 1. Create an MSSQL Database Server Instance
Set the `sa` password using `SA_PASSWORD` environment variable.  
_Optional_: Use `-p 1433:1433` in the command to access your server using the host machine's IP address.

```console
# run the database container in the background

[user@machine:waltz-docker]$ docker run -d \
--name waltz-db-mssql \
-e "ACCEPT_EULA=Y" \
-e "SA_PASSWORD=waltzSA@123" \
mcr.microsoft.com/mssql/server:2017-latest
```
### 2. Add Full Text Search Support
```console
# 1. connect to the mssql server container

[user@machine:waltz-docker]$ docker exec -it waltz-db-mssql /bin/bash

# 2. install fts

root@containerid:/# apt-get update && \
apt-get install -yq curl apt-transport-https && \
curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
curl https://packages.microsoft.com/config/ubuntu/16.04/mssql-server-2017.list | tee /etc/apt/sources.list.d/mssql-server.list && \
apt-get update && \
apt-get install -y mssql-server-fts

# 3. exit from the container command prompt

root@containerid:/# exit

# 4. restart docker container

[user@machine:waltz-docker]$ docker restart waltz-db-mssql
```

### 3. Create Waltz Database and User
Connect to the [sqlcmd](https://docs.microsoft.com/en-us/sql/tools/sqlcmd-utility?view=sql-server-ver15) tool inside the MSSQL container:

```console
# docker exec -it <container_name> /opt/mssql-tools/bin/sqlcmd -S localhost -U sa
# use the 'sa' password set above when prompted

[user@machine:waltz-docker]$ docker exec -it \
waltz-db-mssql \
/opt/mssql-tools/bin/sqlcmd \
-S localhost \
-U sa
```

On the `sqlcmd` prompt, run the following SQL commands to create `waltz` database and user:
```sql
-- create database
CREATE DATABASE waltz
GO

-- create login
CREATE LOGIN waltz WITH PASSWORD = 'waltzU@123', DEFAULT_DATABASE = waltz
GO

-- create user and grant permissions
USE waltz
GO
CREATE USER waltz FOR LOGIN waltz
GO
EXEC sp_addrolemember 'db_owner', 'waltz'
GO

-- exit
EXIT
```

### Connect to the MSSQL Server SQL Client
```console
# docker exec -it <container_name> /opt/mssql-tools/bin/sqlcmd -S localhost -U waltz
# use the password set above for 'waltz' user when prompted

[user@machine:waltz-docker]$ docker exec -it \
waltz-db-mssql \
/opt/mssql-tools/bin/sqlcmd \
-S localhost \
-U waltz
```

### Find IP Address of the MSSQL Server (to use in Maven settings.xml)
```console
# docker exec <container_name> hostname -I

[user@machine:waltz-docker]$ docker exec waltz-db-mssql hostname -I
```