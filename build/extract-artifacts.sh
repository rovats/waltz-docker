#!/bin/sh
cp ./waltz-web.war /waltz-build-output/waltz-web-${WALTZ_TARGET_DB}-${WALTZ_ENV}.war
cp ./config/waltz-${WALTZ_ENV}.properties /waltz-build-output/waltz.properties
cp ./config/waltz-logback-${WALTZ_ENV}.xml /waltz-build-output/waltz-logback.xml