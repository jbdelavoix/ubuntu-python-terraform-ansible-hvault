ARG UBUNTU_VERSION=22.04
ARG TF_VERSION=1.2.1
ARG VAULT_VERSION=1.10

FROM hashicorp/terraform:${TF_VERSION} as terraform
FROM hashicorp/vault:${VAULT_VERSION} as vault

FROM ubuntu:${UBUNTU_VERSION}

COPY --from=vault /bin/vault /bin
COPY --from=terraform /bin/terraform /bin

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    ansible \
    bash \
    curl \
    dnsutils \
    dos2unix \
    git \
    htop \
    iputils-arping \
    iputils-clockdiff \
    iputils-ping \
    iputils-tracepath \
    net-tools \
    python-is-python3 \
    python3 \
    python3-pip \
    sshpass \
    telnet \
    unzip \
    vim \
    wget \
    && rm -rf /var/lib/apt/lists/*
