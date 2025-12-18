#!/bin/sh
## Licensed under the terms of http://www.apache.org/licenses/LICENSE-2.0

## Set FUSEKI_BASE for runtime files
export FUSEKI_BASE="${FUSEKI_BASE:-${FUSEKI_DIR}/run}"

## Extract webapp UI files from JAR to FUSEKI_BASE if not already present
if [ ! -d "${FUSEKI_BASE}/webapp" ]; then
    echo "Extracting UI files to ${FUSEKI_BASE}/webapp..."
    unzip -q "${FUSEKI_DIR}/${FUSEKI_JAR}" "webapp/*" -d "${FUSEKI_BASE}"
fi

## Build classpath with extensions if present
CLASSPATH="${FUSEKI_DIR}/${FUSEKI_JAR}"
if [ -d "/fuseki/extensions" ] && [ -n "$(ls -A /fuseki/extensions/*.jar 2>/dev/null)" ]; then
    echo "Loading extensions from /fuseki/extensions..."
    for jar in /fuseki/extensions/*.jar; do
        echo "  - $(basename "$jar")"
        CLASSPATH="${CLASSPATH}:${jar}"
    done
fi

## Fuseki server with UI and admin area
## Use org.apache.jena.fuseki.main.cmds.FusekiMainCmd for headless/no UI
MAIN_CLASS="org.apache.jena.fuseki.main.cmds.FusekiServerCmd"

exec "$JAVA_HOME/bin/java" $JAVA_OPTIONS -cp "${CLASSPATH}" "$MAIN_CLASS" "$@"
