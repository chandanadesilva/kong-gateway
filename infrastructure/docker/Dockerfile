FROM kong:1.2-centos
COPY kong/gateway.yml /
RUN yum -y install net-tools
RUN sed -e '/^#database\s*=/ s/\(^#\)\(database\s*=\s\)\(.*\)/\2off/' \
    -e '/^#declarative_config\s*=/ s/\(^#\)\(declarative_config\s*=\s\)\(.*\)/\2gateway.yml/' \
    /etc/kong/kong.conf.default > /etc/kong/kong.conf