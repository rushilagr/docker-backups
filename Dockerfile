FROM openjdk:8-jre-alpine

RUN apk add --no-cache --quiet \
    bash \
    curl \
    openssl

ENV NEO4J_SHA256=7d90638e65798ef057f32742fb4f8c87d4d2f13d7c06d7a4c093320bd4df3191 \
    NEO4J_TARBALL=neo4j-enterprise-3.2.1-unix.tar.gz
ARG NEO4J_URI=http://dist.neo4j.org/neo4j-enterprise-3.2.1-unix.tar.gz

COPY ./local-package/* /tmp/

RUN curl --fail --silent --show-error --location --remote-name ${NEO4J_URI} \
    && echo "${NEO4J_SHA256}  ${NEO4J_TARBALL}" | sha256sum -csw - \
    && tar --extract --file ${NEO4J_TARBALL} --directory /var/lib \
    && mv /var/lib/neo4j-* /var/lib/neo4j \
    && rm ${NEO4J_TARBALL} \
    && mv /var/lib/neo4j/data /data \
    && ln -s /data /var/lib/neo4j/data   

RUN mkdir backups


CMD ["neo4j"]
CMD exec bin/neo4j-admin backup --backup-dir=/backups --name=graph.db-backup --from=$NEO_SERVICE_HOST':6363'
