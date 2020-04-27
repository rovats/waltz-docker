# Create Database
Create a Waltz database if you don't already have one.

## PostgreSQL
If using an existing database server, create a new empty database, if you don't already have a Waltz database.

To run a containerised database server, see instructions here: [Containerised Waltz Postgres DB](database/postgres/README.md)


## MS SQL Server
Coming soon

# Setup Maven Profiles
Create a new `settings.xml` file under `config/maven/` (you can copy from `settings.sample.xml`)
Create Waltz database maven profiles under `config/maven/settings.xml`

If your database runs inside a container, you'll need to set the IP address of the container in your JDBC URL.
See instructions in the database `README.md` files to find database container IP addresses.

The file can also be used for other custom maven settings.

# Build Waltz
Built using `build/build.Dockerfile` 

Template command
```
# specify maven profiles as an argument (mandatory)
# see below for a complete list of arguments

docker build --tag waltz-build:latest --build-arg maven_profiles=<profiles> -f build/build.Dockerfile .
```

Examples
```
# postgres
docker build --tag waltz-build:latest --build-arg maven_profiles=waltz-postgres,local-postgres -f build/build.Dockerfile .

# mssql
# coming soon
```

# Run Waltz
You need the following to run Waltz:

* Waltz war file
* Waltz runtime property file: `waltz.properties`