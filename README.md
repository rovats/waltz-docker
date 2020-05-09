# Docker Build/Run/Dev Tools for [Waltz](https://github.com/finos/waltz)
- [0: Tools Required](#0-tools-required)
  * [To Build/Run Waltz](#to-buildrun-waltz)
  * [To Develop](#to-develop)
- [1: Create Database](#1-create-database)
  * [PostgreSQL, MariaDB or MS SQL Server](#postgresql-mariadb-or-ms-sql-server)
- [2: Build Waltz](#2-build-waltz)
  * [Step 1: Setup Maven Profiles](#step-1-setup-maven-profiles)
  * [Step 2: Trigger Build](#step-2-trigger-build)
- [3: Run Waltz](#3-run-waltz)
  * [Step 1: Create Waltz Properties File](#step-1-create-waltz-properties-file)
  * [Step 2: Create Waltz Logback Config File](#step-2-create-waltz-logback-config-file)
  * [Step 3: Deploy](#step-3-deploy)
    + [Standard Deployment (.war on Tomcat)](#standard-deployment-war-on-tomcat)
    + [Docker Deployment](#docker-deployment)
---

# 0: Tools Required
## To Build/Run Waltz
* [Docker](https://www.docker.com/products/docker-desktop)
* [Git](https://git-scm.com/downloads), to clone this repo. You can also download a zip, but cloning is recommended to easily pull in  future updates/fixes
* *Optional*: A Postgres (recommended), MariaDB or MSSQL database server (if a standalone database server is required instead of one running in a Docker container)
  * _[jOOQ Pro](https://www.jooq.org/download/)_ to build Waltz from source if using MSSQL
* *Optional*: A servlet app server like Tomcat (if a standalone server is required instead of one running in a Docker container)
* *Recommended*: [Cygwin](https://www.cygwin.com/) or a similar tool if using Windows

## To Develop
WIP

# 1: Create Database
## PostgreSQL, MariaDB or MS SQL Server
If using an existing database server, create a new empty database, if you don't already have a Waltz database.

> Waltz database schema is created/updated as part of the build process

Alternatively, to run a containerised database server, see instructions here:
* [Containerised Waltz Postgres DB](database/postgres/README.md) (also includes instructions for loading sample data)
* [Containerised Waltz MariaDB](database/mariadb/README.md)
* [Containerised Waltz MSSQL DB](database/mssql/README.md)

# 2: Build Waltz
## Step 1: Setup Maven Profiles
Create a `settings.xml` file under `config/maven/` (you can copy from [config/maven/settings.xml.sample](config/maven/settings.xml.sample))  
Create Waltz database maven profiles under `config/maven/settings.xml`

>If your database runs inside a container, you'll need to set the IP address of the container in your JDBC URL.  
>
>See instructions for [Waltz Postgres DB](database/postgres/README.md), [Waltz MariaDB](database/mariadb/README.md), or [Waltz MSSQL DB](database/mssql/README.md) on how to find database container IP addresses.

The file can also be used for other custom maven settings.

## Step 2: Trigger Build
The build process downloads latest code from [finos/Waltz](https://github.com/finos/waltz) `master` branch by default.  
This can be overriden by passing a different git url or branch/tag name.  
See details of all available build arguments [here](build/README.md).

> All commands must be run from the `waltz-docker` root directory

**Template docker command**:
```console
# specify maven profiles as an argument (mandatory)
# waltz rolls out database ddl changes are part of the build process (via liquibase), so it is important to 
# build against your correct target database.
# eg: You need to run builds against your Dev/UAT/Prod databases separately, unless you are manually
#     deploying liquibase changes to these databases

[user@machine:waltz-docker]$ docker build \
--tag <image-name>:<image_tag> \
--build-arg maven_profiles=<profiles> \
-f build/build.Dockerfile .
```
This will take several minutes to run, especially the first time, as required dependencies are downloaded.  
Once complete, you can either extract the deployable artifacts to deploy them onto an external app server, or spin up a docker container to run Waltz, see below for instructions on both methods.

### Postgres and MariaDB
**Examples**:
```console
# postgres using 'local-postgres' maven profile defined in config/maven/settings.xml
[user@machine:waltz-docker]$ docker build \
--tag waltz-build:latest \
--build-arg maven_profiles=waltz-postgres,local-postgres \
-f build/build.Dockerfile .

# mariadb using 'local-mariadb' maven profile defined in config/maven/settings.xml
[user@machine:waltz-docker]$ docker build \
--tag waltz-build:latest \
--build-arg maven_profiles=waltz-mariadb,local-mariadb \
-f build/build.Dockerfile .
```

### MSSQL
To build Waltz for MSSQL from source, a [jOOQ Pro](https://www.jooq.org/download/) licence is required.  
jOOQ Pro maven dependencies need to be dowloaded and installed locally in maven repository.  

**Download jOOQ Pro**   
Download jOOQ Pro zip file (`jOOQ-<version>.zip`) from [jOOQ website](https://www.jooq.org/download/) and copy the file to `config/maven` directory.  
Ensure that the version matches the one specified in Waltz code [waltz-schema/pom.xml](https://github.com/finos/waltz/blob/master/waltz-schema/pom.xml) (see `jooq.version` property).  

> jOOQ provides a 30-day trial for jOOQ Pro, which may be used to build Waltz.  

The build process will use this zip file to install jOOQ dependencies in the build container's maven repository.

**Additional Maven Profile Properties**  
The following additional properties may need to be specified for MSSQL profiles in your `config/maven/settings.xml` file:  
* `jooq.group`: Set this to `org.jooq.trial-java-8` if using jOOQ trial version
* `jooq.version`: If your version of jOOQ doesn't match the one in [waltz-schema/pom.xml](https://github.com/finos/waltz/blob/master/waltz-schema/pom.xml). This can happen if using jOOQ trial, as that is only available for the latest jOOQ release.
* `jooq.dialect`: Set this so that it matches your version of MSSQL. See [jOOQ Documentation](https://www.jooq.org/doc/3.13/manual/sql-building/dsl-context/sql-dialects/) for details

**Additional Build Argument**  
An additional `jooq_pro_version` mandatory build argument needs to be passed for MSSQL builds, which should match the version in jOOQ Pro zip file (`jOOQ-<version>.zip`) under `config/maven` directory.  
The build process uses this argument to find the correct zip file to install jOOQ dependencies.

**Examples**
```console
# template
docker build \
--tag <image-name>:<image_tag> \
--build-arg maven_profiles=<profiles> \
--build-arg jooq_pro_version=<jooq-version> \
-f build/build.Dockerfile .

# mssql using 'local-mssql' maven profile defined in config/maven/settings.xml
# and jOOQ version 3.13.1
[user@machine:waltz-docker]$ docker build \
--tag waltz-build:latest \
--build-arg maven_profiles=waltz-mariadb,local-mariadb \
--build-arg jooq_pro_version=3.13.1 \
-f build/build.Dockerfile .
```

# 3: Run Waltz
You need the following to run Waltz:

* Waltz runtime properties file: `waltz.properties`
* Waltz logback config file: `waltz-logback.xml`
* Waltz war file: `waltz-web.war`

## Step 1: Create Waltz Properties File
Create environment specific property files (`waltz-<env>.properties`) under `config/waltz` (you can copy from [config/waltz/waltz.properties.sample](config/waltz/waltz.properties.sample))

>The default environment is `local`, so at minimum, create `waltz-local.properties`  
>
>You can also create files for other environments like `waltz-dev.properties`, `waltz-uat.properties`, `waltz-prod.properties`, depending on how many environments you have.

## Step 2: Create Waltz Logback Config File
Create environment specific logback config files (`waltz-logback-<env>.xml`) under `config/waltz` (you can copy from [config/waltz/waltz-logback.xml.sample](config/waltz/waltz-logback.xml.sample))

>The default environment is `local`, so at minimum, create `waltz-logback-local.xml`  
>
>You can also create files for other environments like `waltz-logback-dev.xml`, `waltz-logback-uat.xml`, `waltz-logback-prod.xml`, depending on how many environments you have.

## Step 3: Deploy
### Standard Deployment (.war on Tomcat)
If you already have an app server like Tomcat set up, you can extract the required artificats from the docker build image `waltz-build` and deploy them in your server:

> All commands must be run from the `waltz-docker` root directory

The following environment variables can be passed to the `docker run` command using `-e <var_name>=<var_value` docker syntax :  
| Variable Name | Mandatory | Default Value | Description |
| ------------- | --------- | ------------- | ----------- |
| `WALTZ_ENV` | Yes | `local` | This will be used to pick the correct `waltz-<env>.properties` and `waltz-logback-<env>.xml` files from your `config/waltz` directory. Build artifacts will be extracted into: `build/output/${WALTZ_ENV}` directory |
| `WALTZ_TARGET_DB` | No | Value of ${maven_profiles} build arg | This will be used to name the output `.war` file: `waltz-web.${WALTZ_TARGET_DB}.war` |

**Template docker command**:
```console
# specify target environment and db
[user@machine:waltz-docker]$ docker run --rm \
-v "$PWD"/build/output:/waltz-build-output \
-v "$PWD"/config/waltz:/waltz-bin/config \
-e WALTZ_ENV=<env> \
-e WALTZ_TARGET_DB=<target-db> \
<waltz_build_image_name>:<image_tag>
```

**Examples**:
```console
# local env and postgres db
[user@machine:waltz-docker]$ docker run --rm \
-v "$PWD"/build/output:/waltz-build-output \
-v "$PWD"/config/waltz:/waltz-bin/config \
-e WALTZ_ENV=local \
-e WALTZ_TARGET_DB=postgres \
waltz-build:latest

# dev env and mariadb
[user@machine:waltz-docker]$ docker run --rm \
-v "$PWD"/build/output:/waltz-build-output \
-v "$PWD"/config/waltz:/waltz-bin/config \
-e WALTZ_ENV=dev \
-e WALTZ_TARGET_DB=mariadb \
waltz-build:latest

# prod environment and mssql db
[user@machine:waltz-docker]$ docker run --rm \
-v "$PWD"/build/output:/waltz-build-output \
-v "$PWD"/config/waltz:/waltz-bin/config \
-e WALTZ_ENV=prod \
-e WALTZ_TARGET_DB=mssql \
waltz-build:latest
```
The above command will copy the deployment artifacts to `build/output/${WALTZ_ENV}` directory.

>Depending on how your server is configured, the artifacts may be deployed on Tomcat like so:  
>The `.war` file can be placed under Tomcat's `webapps` directory.  
>The `waltz.properties` and `waltz-logback.xml` files need to be on the classpath, so they can be dropped into the server's `lib` folder.  

### Docker Deployment

Once the `waltz-build` docker image is created by the build step, you can easily build and run a docker container to deploy Waltz.

Dockerfile: [run/run.Dockerfile](run/run.Dockerfile)

> All commands must be run from the `waltz-docker` root directory

#### a. Build `waltz-run` Docker Image

This step creates a `waltz-run` docker image by extracting deployable `waltz-web.war` file from the `waltz-build` image and copying it into Tomcat's `webapps` directory inside the `waltz-run` image.  
This also copies the correct `waltz-<env>.properties` and `waltz-logback-<env>.xml` files from `config/waltz` directory into Tomcat's `lib` directory.

> You can also override Tomcat server's config by placing custom config files under [config/tomcat](config/tomcat/README.md) directory.

The following arguments can be passed to the `docker build` command when building Waltz, using `--build-arg <arg_name>=<arg_value>` docker syntax:  

| Argument | Mandatory | Default Value | Description |
| -------- | --------- | ------------- | ----------- |
| `waltz_env` | Yes | `local` | This will be used to pick the correct `waltz-<env>.properties` and `waltz-logback-<env>.xml` files from your `config/waltz` directory |
| `waltz_build_tag` | No | `latest` | Specify the tag of the `waltz-build` image to use. In case you maintain different `waltz-build` images, you can use this tag to pick the image to extract artifacts from |
| `context_path` | No | `waltz` | Use this if you want to customise the context path in your Waltz URL |

_Template Command_
```console
[user@machine:waltz-docker]$ docker build \
--tag waltz-run:<tag> \
--build-arg waltz_build_tag=<waltz_build_tag> \
--build-arg waltz_env=<waltz_env> \
--build-arg context_path=<context_path> \
-f run/run.Dockerfile .
```

_Example_
```console
[user@machine:waltz-docker]$ docker build \
--tag waltz-run:latest \
--build-arg waltz_build_tag=latest \
--build-arg waltz_env=local \
--build-arg context_path=waltz \
-f run/run.Dockerfile .
```

#### b. Run `waltz-run` Docker Image

This will create a container from the `waltz-run` image and start a Tomcat server with Waltz deployed.

You can then access Waltz using this URL:

```
http://<host_ip>:<host_port>/${context_path}/
```

_Template Command_
```console
[user@machine:waltz-docker]$ docker run --rm -it \
--name <container_name> \
-p <host_port>:8080 \
waltz-run:<waltz_run_tag>
```

_Example_
```console
# port 8888 on the host machine will point to port 8080 in the container
# waltz url will be: http://localhost:8888/waltz

[user@machine:waltz-docker]$ docker run --rm -it \
--name waltz-run \
-p 8888:8080 \
waltz-run:latest
```
