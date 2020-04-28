#
# step 1: extract artifacts from waltz-build image
#
ARG waltz_build_tag=latest
FROM waltz-build:${waltz_build_tag} as get_artifacts

ARG waltz_env=local
ARG context_path=waltz

WORKDIR /waltz-deployment-artifacts

RUN cp /waltz-bin/waltz-web.war ./${context_path}.war
RUN cp /waltz-bin/config/waltz-${waltz_env}.properties ./waltz.properties
RUN cp /waltz-bin/config/waltz-logback-${waltz_env}.xml ./waltz-logback.xml

#
# step 2: deploy in tomcat
#
FROM tomcat:8-jdk8-openjdk

# deploy waltz
COPY --from=get_artifacts /waltz-deployment-artifacts/waltz.properties ./lib/
COPY --from=get_artifacts /waltz-deployment-artifacts/waltz-logback.xml ./lib/
COPY --from=get_artifacts /waltz-deployment-artifacts/*.war ./webapps/
