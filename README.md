# Docker Dev/Build/Run Tools for [Waltz](https://github.com/finos/waltz)
- [0: Tools Required](#tools-required)
  * [To Build/Run Waltz](#to-build-run-waltz)
  * [To Develop](#to-develop)
- [1: Create Database](#create-database)
  * [PostgreSQL](#postgresql)
  * [MS SQL Server](#ms-sql-server)
- [2: Build Waltz](#build-waltz)
  * [Step 1: Setup Maven Profiles](#step-1--setup-maven-profiles)
  * [Step 2: Trigger Build](#step-2--trigger-build)
- [3: Run Waltz](#run-waltz)
  * [Step 1: Create Waltz Properties File](#step-1--create-waltz-properties-file)
  * [Step 2: Create Waltz Logback Config File](#step-2--create-waltz-logback-config-file)
  * [Step 3: Run](#step-3--run)
    + [Standard Deployment (.war on Tomcat)](#standard-deployment--war-on-tomcat-)
    + [Docker](#docker)
---

# 0: Tools Required
## To Build/Run Waltz
* [Docker](https://www.docker.com/products/docker-desktop)
* *Optional*: A Postgres (recommended) or MSSQL database server (if a standalone database server is required instead of one running in a Docker container)
* *Optional*: A servlet app server like Tomcat (if a standalone server is required instead of one running in a Docker container)

## To Develop
Coming soon

# 1: Create Database
Create a Waltz database if you don't already have one.

## PostgreSQL
If using an existing database server, create a new empty database, if you don't already have a Waltz database.

>To run a containerised database server, see instructions here: [Containerised Waltz Postgres DB](database/postgres/README.md)


## MS SQL Server
Coming soon

# 2: Build Waltz
## Step 1: Setup Maven Profiles
Create a new `settings.xml` file under `config/maven/` (you can copy from `settings.sample.xml`)  
Create Waltz database maven profiles under `config/maven/settings.xml`

>If your database runs inside a container, you'll need to set the IP address of the container in your JDBC URL.  
>
>See instructions here [Waltz Postgres DB](database/postgres/README.md) or [Waltz MSSQL DB](database/mssql/README.md) on how to find database container IP addresses.

The file can also be used for other custom maven settings.

## Step 2: Trigger Build
Built using `build/build.Dockerfile` 

**Template docker command**:
```sh
# specify maven profiles as an argument (mandatory)
# waltz rolls out database ddl changes are part of the build process (via liquibase), so it is important to 
# build against your correct target database.
# eg: You need to run builds against your Dev/UAT/Prod databases separately, unless you are manually
#     deploying liquibase changes to these databases

docker build --tag waltz-build:latest --build-arg maven_profiles=<profiles> -f build/build.Dockerfile .
```

**Examples**:
```sh
# postgres using local-postgres maven profile
docker build --tag waltz-build:latest --build-arg maven_profiles=waltz-postgres,local-postgres -f build/build.Dockerfile .

# mssql
# coming soon
```

# 3: Run Waltz
You need the following to run Waltz:

* Waltz runtime properties file: `waltz.properties`
* Waltz logback config file: `waltz-logback.xml`
* Waltz war file: `waltz-web.war`

## Step 1: Create Waltz Properties File
Create environment specific property files (`waltz-<env>.properties`) under `config/waltz` (you can copy from `config/waltz/waltz.properties.sample`)

>The default environment is `local`, so at minimum, create `waltz-local.properties`  
>
>You can also create files for other envirnoments like `waltz-dev.properties`, `waltz-uat.properties`, `waltz-prod.properties`, depending on how many environments you have.

## Step 2: Create Waltz Logback Config File
Create environment specific logback config files (`waltz-logback-<env>.xml`) under `config/waltz` (you can copy from `config/waltz/waltz-logback.xml.sample`)

>The default environment is `local`, so at minimum, create `waltz-logback-local.xml`  
>
>You can also create files for other envirnoments like `waltz-logback-dev.xml`, `waltz-logback-uat.xml`, `waltz-logback-prod.xml`, depending on how many environments you have.

## Step 3: Run
### Standard Deployment (.war on Tomcat)
If you already have an app server like Tomcat set up, you can extract the required artificats from the docker build image `waltz-build` and deploy them in your server:

**Template docker command**:
```sh
# specify target environment and db
docker run -v "$PWD"/build/output:/waltz-build-output -e WALTZ_ENV=<env> -e WALTZ_TARGET_DB=<target-db> waltz-build:latest
```

**Examples**:
```sh
# local env and postgres db
docker run -v "$PWD"/build/output:/waltz-build-output -e WALTZ_ENV=local -e WALTZ_TARGET_DB=postgres waltz-build:latest

# dev environment and mssql db
docker run -v "$PWD"/build/output:/waltz-build-output -e WALTZ_ENV=dev -e WALTZ_TARGET_DB=mssql waltz-build:latest
```
The above command will copy the deployment artifacts to `build/output` directory.

>Depending on how your server is configured, the artifacts may be deployed on Tomcat like so:  
>The `.war` file can be placed under Tomcat's `webapps` directory.  
>The `waltz.properties` and `waltz-logback.xml` files need to be on the classpath, so they can be dropped into the server's `lib` folder.  

### Docker
coming soon