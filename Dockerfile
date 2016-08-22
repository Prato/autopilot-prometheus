# Configuration-free base from which to build
# FROM gliderlabs/alpine:3.4
FROM prom/prometheus:0.17.0

# easier to spin up via docker-cli, overwrite on deploy
ENV LOG_LEVEL=DEBUG \
    CONTAINERPILOT_VER=2.4.1 \
    CONSUL_VERSION=0.6.4 \
    CONSUL_TEMPLATE_VERSION=0.15.0 \
    VAULT_VERSION=0.6.0

RUN apk --no-cache add \
        curl

# Add Containerpilot and set its configuration
RUN export CONTAINERPILOT_SHA256="da9ea474e575e1604f394f85218133a4600a47f5f2f5acd6c81a1c1f71216c18" \
    && curl -Lso /tmp/containerpilot.tar.gz \
        "https://github.com/joyent/containerpilot/releases/download/${CONTAINERPILOT_VER}/containerpilot-${CONTAINERPILOT_VER}.tar.gz" \
    && echo "${CONTAINERPILOT_SHA256}  /tmp/containerpilot.tar.gz" | sha265sum -c \
    && tar zxf /tmp/containerpilot.tar.gz -C /usr/local/bin \
    && rm /tmp/containerpilot.tar.gz

# Install consul
RUN export \
        PACKAGE_NAME="consul" \
        PACKAGE_VERSION=${CONSUL_VERSION} \
        PACKAGE_SHA256="abdf0e1856292468e2c9971420d73b805e93888e006c76324ae39416edcf0627" \
    && curl --retry 7 --fail -LsSo /tmp/${PACKAGE_NAME}.zip \
        "https://releases.hashicorp.com/${PACKAGE_NAME}/${PACKAGE_VERSION}/${PACKAGE_NAME}_${PACKAGE_VERSION}_linux_amd64.zip" \
    && echo "${PACKAGE_SHA256}  /tmp/${PACKAGE_NAME}.zip" | sha256sum -c \
    && unzip /tmp/${PACKAGE_NAME} -d /usr/local/bin \
    && rm /tmp/${PACKAGE_NAME}.zip

# Install consul-template
RUN export \
        PACKAGE_NAME="consul-template" \
        PACKAGE_VERSION=${CONSUL_TEMPLATE_VERSION} \
        PACKAGE_SHA256="b7561158d2074c3c68ff62ae6fc1eafe8db250894043382fb31f0c78150c513a" \
    && curl --retry 7 --fail -LsSo /tmp/${PACKAGE_NAME}.zip \
        "https://releases.hashicorp.com/${PACKAGE_NAME}/${PACKAGE_VERSION}/${PACKAGE_NAME}_${PACKAGE_VERSION}_linux_amd64.zip" \
    && echo "${PACKAGE_SHA256}  /tmp/${PACKAGE_NAME}.zip" | sha256sum -c \
    && unzip /tmp/${PACKAGE_NAME} -d /usr/local/bin \
    && rm /tmp/${PACKAGE_NAME}.zip

# Install vault
RUN export \
        PACKAGE_NAME="vault" \
        PACKAGE_VERSION=${VAULT_VERSION} \
        PACKAGE_SHA256="283b4f591da8a4bf92067bf9ff5b70249f20705cc963bea96ecaf032911f27c2" \
    && curl --retry 7 --fail -LsSo /tmp/${PACKAGE_NAME}.zip \
        "https://releases.hashicorp.com/${PACKAGE_NAME}/${PACKAGE_VERSION}/${PACKAGE_NAME}_${PACKAGE_VERSION}_linux_amd64.zip" \
    && echo "${PACKAGE_SHA256}  /tmp/${PACKAGE_NAME}.zip" | sha256sum -c \
    && unzip /tmp/${PACKAGE_NAME} -d /usr/local/bin \
    && rm /tmp/${PACKAGE_NAME}.zip


COPY etc /usr/local/etc
COPY bin /usr/local/bin

ENTRYPOINT []

CMD ["containerpilot", \
     "/usr/local/bin/prometheus", \
     "-config.file=/usr/local/etc/prometheus/prometheus.yml", \
     "-storage.local.path=/usr/local/data/prometheus", \
     "-web.console.libraries=/usr/local/etc/prometheus/console_libraries", \
     "-web.console.templates=/usr/local/etc/prometheus/consoles" ]
