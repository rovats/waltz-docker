#!/bin/sh
mkdir -p /waltz-build-output/${WALTZ_ENV}
cp ./waltz-web.war /waltz-build-output/${WALTZ_ENV}/waltz-web.${WALTZ_TARGET_DB}.war
cp ./config/waltz-${WALTZ_ENV}.properties /waltz-build-output/${WALTZ_ENV}/waltz.properties
cp ./config/waltz-logback-${WALTZ_ENV}.xml /waltz-build-output/${WALTZ_ENV}/waltz-logback.xml