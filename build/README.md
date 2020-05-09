# Build Waltz
Build Dockerfile: [build.Dockerfile](build.Dockerfile)

Ensure you have [created a database](../README.md#1-create-database) and [setup maven profiles](../README.md#step-1-setup-maven-profiles) first.

> All commands must be run from the `waltz-docker` root directory

**Template docker command**:
```console
[user@machine:waltz-docker]$ docker build \
--no-cache # optional \
--tag <image-name>:<image_tag> \
--build-arg maven_profiles=<profiles> \
--build-arg <arg2>=<arg2_val> \
...
...
--build-arg <argn>=<arg2_val> \
-f build/build.Dockerfile .
```
This will take several minutes to run, especially the first time, as required dependencies are downloaded.  
Once complete, you can either extract the deployable artifacts to deploy them onto an external app server, or spin up a docker container to run Waltz, see [here](../README.md#3-run-waltz) for instructions on both methods.

## Build Arguments
These arguments can be passed to the `docker build` command when building Waltz, using `--build-arg <arg_name>=<arg_value>` docker syntax:  

| Argument | Mandatory | Default Value | Description |
| -------- | --------- | ------------- | ----------- |
| `maven_profiles` | Yes | | Maven profiles to build Waltz |
| `jooq_pro_version` | Yes, for MSSQL builds | | Should match the version in jOOQ Pro zip file (`jOOQ-<version>.zip`) under `config/maven` directory |
| `git_url` | No | `https://github.com/finos/waltz.git` | Git repo URL to fetch Waltz code from |
| `git_branch` | No | `master` | Branch/tag or commit ref to use, in the git repo specified above |
| `git_latest_commit_info_url` | No | `https://api.github.com/repos`<br>`/finos/waltz/commits/${git_branch}` | URL that returns info about the latest commit in the specified `git_branch`. This ensures the build process re-runs if any code has changed |
| `force_build_timestamp` | No | | To force the build process to run even if nothing has changed, pass a unique timestamp value, eg: `--build-arg force_build_timestamp=$(date +%s)` |
| `skip_tests` | No | true | Whether to run tests as part of the maven build process |

## Extract Build Artifacts

See instructions on how to extract build artifacts for [Standard Deployment (.war on Tomcat)](../README.md#standard-deployment-war-on-tomcat)