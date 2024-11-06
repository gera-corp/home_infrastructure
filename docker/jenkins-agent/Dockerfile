FROM jenkins/inbound-agent:latest

ENV USER=jenkins

USER root

RUN apt-get update && apt-get -y install wget gnupg2 lsb-release
## Install Packer, Ansible, pipenv:
RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
RUN apt-get update && \
    apt-get -y install packer python3-pip && \
    rm -rf /var/lib/apt/lists/*
RUN rm /usr/lib/python3.11/EXTERNALLY-MANAGED

USER ${USER}

RUN pip3 install --upgrade pip
RUN pip3 install ansible

COPY requirements.txt ./

ENV PATH="/home/${USER}/.local/bin:${PATH}"

RUN pip install -r requirements.txt
