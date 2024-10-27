FROM openjdk:8-bullseye
LABEL maintainer="Son Tran Thanh <286.trants@gmail.com>"

ARG CROWD_VERSION=6.1.1
ARG ATLASSIAN_PRODUCT=crowd
ARG AGENT_VERSION=1.3.3
ARG MYSQL_DRIVER_VERSION=8.0.22

ENV CROWD_USER=crowd \
    CROWD_GROUP=crowd \
    CROWD_HOME=/var/crowd \
    CROWD_INSTALL=/opt/crowd \
    JVM_MINIMUM_MEMORY=4g \
    JVM_MAXIMUM_MEMORY=16g \
    JVM_CODE_CACHE_ARGS="-XX:InitialCodeCacheSize=2g -XX:ReservedCodeCacheSize=4g" \
    AGENT_PATH=/var/agent \
    AGENT_FILENAME=atlassian-agent.jar

ENV JAVA_OPTS="-javaagent:${AGENT_PATH}/${AGENT_FILENAME} ${JAVA_OPTS}"

RUN mkdir -p ${CROWD_INSTALL} ${CROWD_HOME} ${AGENT_PATH} ${CROWD_INSTALL}/lib \
    && curl -o ${AGENT_PATH}/${AGENT_FILENAME} https://github.com/focela/crowd/releases/download/v${AGENT_VERSION}/atlassian-agent.jar -L \
    && curl -o /tmp/atlassian.tar.gz https://downloads.atlassian.com/software/${ATLASSIAN_PRODUCT}/downloads/atlassian-${ATLASSIAN_PRODUCT}-${CROWD_VERSION}.tar.gz -L \
    && tar xzf /tmp/atlassian.tar.gz -C ${CROWD_INSTALL} --strip-components 1 \
    && rm -f /tmp/atlassian.tar.gz \
    && curl -f -o ${CROWD_INSTALL}/lib/mysql-connector-java-${MYSQL_DRIVER_VERSION}.jar \
        "https://repo1.maven.org/maven2/mysql/mysql-connector-java/${MYSQL_DRIVER_VERSION}/mysql-connector-java-${MYSQL_DRIVER_VERSION}.jar" -L \
    && mkdir -p ${CROWD_INSTALL}/atlassian-crowd/WEB-INF/classes/ \
    && echo "crowd.home = ${CROWD_HOME}" > ${CROWD_INSTALL}/atlassian-crowd/WEB-INF/classes/crowd-application.properties

RUN export CONTAINER_USER=$CROWD_USER \
    && export CONTAINER_GROUP=$CROWD_GROUP \
    && groupadd -r $CROWD_GROUP && useradd -r -g $CROWD_GROUP $CROWD_USER \
    && chown -R $CROWD_USER:$CROWD_GROUP ${CROWD_INSTALL} ${CROWD_HOME} ${AGENT_PATH}

VOLUME $CROWD_HOME
USER $CROWD_USER
WORKDIR $CROWD_INSTALL
EXPOSE 8080

ENTRYPOINT ["/opt/crowd/start_crowd.sh", "-fg"]
