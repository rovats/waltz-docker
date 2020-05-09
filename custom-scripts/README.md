You may use it to store custom scripts, frequently used commands etc.  

> This directory will not be overwritten when a `git pull` is invoked.  


**Example Script for Postgres**

```bash
#!/bin/sh

#
# build
#
docker build \
--tag waltz-build:latest \
--build-arg maven_profiles=waltz-postgres,local-postgres \
--build-arg force_build_timestamp=$(date +%s) \
-f build/build.Dockerfile .

#
# extract (if deploying in an existing tomcat server)
#
docker run --rm \
-v "$PWD"/build/output:/waltz-build-output \
-e WALTZ_ENV=local \
-e WALTZ_TARGET_DB=postgres \
waltz-build:latest

#
# or deploy in tomcat inside a docker container
#
docker build \
--tag waltz-run:latest \
--build-arg waltz_build_tag=latest \
--build-arg waltz_env=local \
-f run/run.Dockerfile .

docker stop waltz-run 

docker run --rm -it \
--name waltz-run \
-p 8888:8080 \
waltz-run:latest
```