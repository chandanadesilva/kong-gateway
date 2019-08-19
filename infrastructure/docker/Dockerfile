FROM kong:1.2-centos
COPY kong/gateway.yml /
RUN yum -y install net-tools
RUN sed -e '/^#database\s*=/ s/\(^#\)\(database\s*=\s\)\(.*\)/\2off/' \
    -e '/^#declarative_config\s*=/ s/\(^#\)\(declarative_config\s*=\s\)\(.*\)/\2gateway.yml/' \
    -e '/^#admin_listen\s*=/ s/\(^#\)\(admin_listen\s*=\s\)\(.*\)/\20.0.0.0:8001, 0.0.0.0:8444 ssl/' \
    /etc/kong/kong.conf.default > /etc/kong/kong.conf