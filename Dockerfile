## Licensed to the Apache Software Foundation (ASF) under one or more
## contributor license agreements.  See the NOTICE file distributed with
## this work for additional information regarding copyright ownership.
## The ASF licenses this file to You under the Apache License, Version 2.0
## (the "License"); you may not use this file except in compliance with
## the License.  You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.

## ============================================================================
## Optimized Apache Jena Fuseki Docker Image
## ============================================================================
## This multi-stage Dockerfile creates a minimal, secure, and efficient
## Apache Jena Fuseki SPARQL server container.
##
## Features:
## - Multi-stage build for minimal final image size
## - Custom JDK created with jlink containing only required modules
## - Runs as non-root user for security
## - Alpine Linux base for smallest footprint
## - SHA1 checksum verification of downloaded artifacts
## - Optimized layer caching
## ============================================================================

ARG JAVA_VERSION=21
ARG ALPINE_VERSION=3.21
ARG JENA_VERSION="5.6.0"

# Internal build arguments
ARG FUSEKI_DIR=/fuseki
ARG FUSEKI_JAR=jena-fuseki-server-${JENA_VERSION}.jar
ARG JAVA_MINIMAL=/opt/java-minimal

## ============================================================================
## Stage 1: Build - Download Fuseki and create minimal JDK
## ============================================================================
FROM eclipse-temurin:${JAVA_VERSION}-alpine AS builder

ARG JAVA_MINIMAL
ARG JENA_VERSION
ARG FUSEKI_DIR
ARG FUSEKI_JAR
ARG REPO=https://repo1.maven.org/maven2
ARG JAR_URL=${REPO}/org/apache/jena/jena-fuseki-server/${JENA_VERSION}/${FUSEKI_JAR}

# Validate JENA_VERSION is set
RUN [ "${JENA_VERSION}" != "" ] || { echo -e '\n**** ERROR: JENA_VERSION must be set ****\n' ; exit 1 ; }

RUN echo "============================================================================" && \
    echo "Building Apache Jena Fuseki ${JENA_VERSION} Docker Image" && \
    echo "============================================================================"

# Install build dependencies (kept minimal)
RUN apk add --no-cache \
    curl \
    binutils

# Set working directory
WORKDIR $FUSEKI_DIR

# Copy download script
COPY download.sh .
RUN chmod +x download.sh

# Download Fuseki JAR with SHA1 checksum verification
RUN ./download.sh --chksum sha1 "$JAR_URL"

# Create minimal JDK using jlink
# This significantly reduces the final image size by including only required Java modules
ARG JDEPS_EXTRA="jdk.crypto.cryptoki,jdk.crypto.ec"
RUN JDEPS="$(jdeps --multi-release base --print-module-deps --ignore-missing-deps ${FUSEKI_JAR})" && \
    echo "Required Java modules: ${JDEPS},${JDEPS_EXTRA}" && \
    jlink \
        --compress zip-9 \
        --strip-debug \
        --no-header-files \
        --no-man-pages \
        --output "${JAVA_MINIMAL}" \
        --add-modules "${JDEPS},${JDEPS_EXTRA}"

# Copy configuration files
COPY entrypoint.sh log4j2.properties ./

## ============================================================================
## Stage 2: Runtime - Create minimal runtime image
## ============================================================================
FROM alpine:${ALPINE_VERSION}

# Import build arguments
ARG JENA_VERSION
ARG JAVA_MINIMAL
ARG FUSEKI_DIR
ARG FUSEKI_JAR

# Copy minimal JDK and Fuseki from builder stage
COPY --from=builder ${JAVA_MINIMAL} ${JAVA_MINIMAL}
COPY --from=builder ${FUSEKI_DIR} ${FUSEKI_DIR}

WORKDIR $FUSEKI_DIR

# Define directory structure
ARG LOGS=${FUSEKI_DIR}/logs
ARG DATA=${FUSEKI_DIR}/databases
ARG BACKUPS=${FUSEKI_DIR}/backups
ARG CONFIG=${FUSEKI_DIR}/configuration

# User configuration
ARG JENA_USER=fuseki
ARG JENA_GROUP=$JENA_USER
ARG JENA_GID=1000
ARG JENA_UID=1000

# Create non-root user for security
RUN addgroup -g "${JENA_GID}" "${JENA_GROUP}" && \
    adduser "${JENA_USER}" \
        -G "${JENA_GROUP}" \
        -s /bin/ash \
        -u "${JENA_UID}" \
        -H \
        -D

# Set ownership
RUN mkdir -p "${FUSEKI_DIR}" && \
    chown -R ${JENA_USER}:${JENA_GROUP} ${FUSEKI_DIR}

# Switch to non-root user
USER $JENA_USER

# Create directory structure with proper permissions
RUN mkdir -p $LOGS && \
    mkdir -p $DATA && \
    mkdir -p $BACKUPS && \
    mkdir -p $CONFIG && \
    chmod +x entrypoint.sh

# Environment variables
ENV JAVA_HOME=${JAVA_MINIMAL} \
    JAVA_OPTIONS="-Xmx2048m -Xms2048m" \
    JENA_VERSION=${JENA_VERSION} \
    FUSEKI_JAR="${FUSEKI_JAR}" \
    FUSEKI_DIR="${FUSEKI_DIR}"

# Labels following OCI image spec
LABEL org.opencontainers.image.title="Apache Jena Fuseki" \
      org.opencontainers.image.description="Optimized Apache Jena Fuseki SPARQL server - lightweight, secure, and fast" \
      org.opencontainers.image.version="${JENA_VERSION}" \
      org.opencontainers.image.vendor="ConceptKernel" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.source="https://github.com/ConceptKernel/jena-fuseki-dockerfile" \
      org.opencontainers.image.documentation="https://github.com/ConceptKernel/jena-fuseki-dockerfile#readme" \
      maintainer="ConceptKernel"

# Expose Fuseki port
EXPOSE 3030

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3030/$/ping || exit 1

# Entrypoint and default command
ENTRYPOINT ["./entrypoint.sh"]
CMD []
