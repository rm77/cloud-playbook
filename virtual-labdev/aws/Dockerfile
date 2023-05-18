FROM ubuntu:jammy

RUN apt-get update && apt-get install -y \
    python3-pip \
    unzip \
    curl \
    software-properties-common \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install awscli boto3

RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -

RUN apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com jammy main"

RUN apt-get update && apt-get install -y terraform  docker.io

RUN curl -L https://raw.githubusercontent.com/docker/compose-cli/main/scripts/install/install_linux.sh | sh

ENV PATH="/root/.local/bin:${PATH}"

WORKDIR /app

CMD ["/bin/bash"]
