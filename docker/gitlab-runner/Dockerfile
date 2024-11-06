FROM gitlab/gitlab-runner:latest
RUN curl -O https://get.docker.com/builds/Linux/x86_64/docker-latest.tgz
RUN tar -xvzf docker-latest.tgz -C /tmp/ && mv /tmp/docker/docker /usr/bin/docker
