FROM fluentd:v1.16-debian-1

USER root

# Install plugins
RUN gem install fluent-plugin-elasticsearch \
    fluent-plugin-record-modifier \
    fluent-plugin-rewrite-tag-filter \
    fluent-plugin-systemd

USER fluent