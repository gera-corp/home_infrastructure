FROM fluent/fluentd:v1.16.1-debian-1.0
USER root
#latest version supporting elasticsearch v7.17*
RUN gem install elasticsearch -v 7.17.7
RUN ["gem", "install", "fluent-plugin-elasticsearch", "--no-document", "--version", "5.3.0"]
#RUN ["gem", "install", "fluent-plugin-prometheus"]
USER fluent