FROM ubuntu:latest

RUN apt-get update && apt-get install -y \
    python3-pip \
    unzip \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install awscli boto3

RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -

RUN apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

RUN apt-get update && apt-get install -y terraform

ENV PATH="/root/.local/bin:${PATH}"

WORKDIR /app

CMD ["/bin/bash"]
