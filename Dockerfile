ARG UBUNTU_VERSION=24.04
ARG TF_VERSION=1.11.4
ARG VAULT_VERSION=1.19.2

FROM hashicorp/terraform:$TF_VERSION AS terraform
FROM hashicorp/vault:$VAULT_VERSION AS vault

FROM ubuntu:$UBUNTU_VERSION

ARG VSCODE_VERSION=1.99.3
ENV VSCODE_VERSION=$VSCODE_VERSION

COPY --from=vault /bin/vault /bin
COPY --from=terraform /bin/terraform /bin

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    ansible \
    bash \
    ca-certificates \
    curl \
    dnsutils \
    dos2unix \
    git \
    htop \
    iputils-arping \
    iputils-clockdiff \
    iputils-ping \
    iputils-tracepath \
    jq \
    net-tools \
    openssh-server \
    python-is-python3 \
    python3 \
    python3-pip \
    sshpass \
    sudo \
    telnet \
    unzip \
    vim \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/sshd && \
    echo "Port 2222" >> /etc/ssh/sshd_config && \
    echo "PermitRootLogin no" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication no" >> /etc/ssh/sshd_config && \
    echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "AllowTcpForwarding yes" >> /etc/ssh/sshd_config && \
    echo "PermitUserEnvironment yes" >> /etc/ssh/sshd_config

RUN mkdir -p /home/ubuntu/.ssh && \
    touch /home/ubuntu/.ssh/authorized_keys && \
    chmod 700 /home/ubuntu/.ssh && \
    chmod 600 /home/ubuntu/.ssh/authorized_keys && \
    chown -R ubuntu:ubuntu /home/ubuntu/

USER ubuntu
WORKDIR /home/ubuntu

RUN mkdir -p /home/ubuntu/.vscode-server/bin/$VSCODE_VERSION && \
    curl -L "https://update.code.visualstudio.com/$VSCODE_VERSION/server-linux-x64/stable" \
    -o vscode-server.tar.gz && \
    tar -xzf vscode-server.tar.gz -C /home/ubuntu/.vscode-server/bin/$VSCODE_VERSION --strip-components=1 && \
    rm vscode-server.tar.gz

USER root

EXPOSE 2222

CMD ["/usr/sbin/sshd", "-D"]
