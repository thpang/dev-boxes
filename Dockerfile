# Base layer
FROM ubuntu:22.04 as baseline
RUN apt update && apt upgrade -y \
  && apt install -y python3 python3-dev python3-pip curl unzip gnupg \
  && update-alternatives --install /usr/bin/python python /usr/bin/python3 1 \
  && update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

# Layers used for building/downloading/installing tools
FROM baseline as tool_builder
ARG HELM_VERSION=3.8.1
ARG KUBECTL_VERSION=1.23.8
ARG TERRAFORM_VERSION=1.2.0

WORKDIR /build

RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - \
  && echo "deb [arch=amd64] https://apt.releases.hashicorp.com focal main" > /etc/apt/sources.list.d/tf.list \
  && apt update \
  && curl -sLO https://storage.googleapis.com/kubernetes-release/release/v{$KUBECTL_VERSION}/bin/linux/amd64/kubectl && chmod 755 ./kubectl \
  && curl -ksLO https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && chmod 755 get-helm-3 \
  && ./get-helm-3 --version v$HELM_VERSION --no-sudo \
  && apt-get install terraform=$TERRAFORM_VERSION

# Installation steps
FROM baseline

RUN apt -y install git sshpass jq

COPY --from=tool_builder /usr/local/bin/helm /usr/local/bin/helm
COPY --from=tool_builder /build/kubectl /usr/local/bin/kubectl
COPY --from=tool_builder /usr/bin/terraform /usr/bin/terraform

ARG BRANCH=main
ARG TIMESTAMP

# VOLUME ["/workspace"]
