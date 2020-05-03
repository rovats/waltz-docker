#
# step 1: checkout code
#
FROM alpine/git as code_checkout

# specify these using --build-arg these to use a different url/branch(or tag) to build from
ARG git_url=https://github.com/finos/waltz.git
ARG git_branch=master
ARG cache_bust_url=https://api.github.com/repos/finos/waltz/commits/${git_branch}

WORKDIR /waltz-src

# ensure new code is fetched if anything has changed
ADD ${cache_bust_url} /tmp/cache_bust

# fetch code
RUN git clone --single-branch --depth 1 --branch ${git_branch} ${git_url} .


#
# step 2: build waltz ui
#
FROM node:10.20.1 as ui_build

WORKDIR /waltz-src/waltz-ng

# install node dependencies
COPY --from=code_checkout /waltz-src/waltz-ng/package.json .
RUN npm install

# build ui
COPY --from=code_checkout /waltz-src/waltz-ng .
COPY --from=code_checkout /waltz-src/.git /waltz-src/.git
ENV BUILD_ENV=prod
RUN npm run build


#
# step 3: build waltz
#
FROM openjdk:8 as waltz_build

RUN apt-get update && apt-get install -y \
    maven \
    git \
    xsltproc

# copy custom maven settings
COPY ./config/maven/settings.xml /etc/maven

WORKDIR /waltz-tmp

# cache maven dependencies
COPY build/transform-main-pom.xsl /tmp/
COPY --from=code_checkout /waltz-src/pom.xml /tmp/main-pom.xml
RUN xsltproc -o ./pom.xml /tmp/transform-main-pom.xsl /tmp/main-pom.xml
RUN mvn dependency:go-offline

# install jOOQ Pro dependencies if needed
COPY ./config/maven/ .
RUN if [ -r jOOQ-${jooq_pro_version}.zip ]; then \
        unzip jOOQ-${jooq_pro_version}.zip && \
        cd jOOQ-${jooq_pro_version} && \
        chmod +x maven-install.sh && \
        ./maven-install.sh; \
    fi

# build args
# mandatory param, eg: --build-arg maven_profiles=waltz-postgres,local-postgres
ARG maven_profiles
ARG skip_tests=true
# mandatory param for MSSQL
ARG jooq_pro_version

WORKDIR /waltz-src

# copy source code
COPY --from=code_checkout /waltz-src .
COPY --from=ui_build /waltz-src/waltz-ng/dist ./waltz-ng/dist

# build
RUN mvn clean package -P${maven_profiles} -Dexec.skip=true -DskipTests=${skip_tests}


#
# step 4: copy output
#
FROM alpine:latest as build_output

# to derive output war file name
ARG maven_profiles

WORKDIR /waltz-bin

# copy build output
COPY --from=waltz_build /waltz-src/waltz-web/target/waltz-web.war .
# copy config files
COPY config/waltz/waltz-logback-*.xml ./config/
COPY config/waltz/waltz-*.properties ./config/

# copy artifact extract file
COPY build/extract-artifacts.sh .
RUN chmod +x ./extract-artifacts.sh

ENV WALTZ_ENV=local
ENV WALTZ_TARGET_DB=${maven_profiles}

RUN mkdir /waltz-build-output

CMD ["./extract-artifacts.sh"]