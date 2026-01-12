
FROM centos:7
LABEL maintainer="RNS <rns@rnstech.com>"

# Point repos to CentOS 7 vault (EOL) so yum works
RUN sed -i \
  -e 's|^mirrorlist=|#mirrorlist=|g' \
  -e 's|^#baseurl=http://mirror.centos.org/centos/\\$releasever|baseurl=http://vault.centos.org/7.9.2009|g' \
  /etc/yum.repos.d/CentOS-Base.repo || true

# Tools + Java
RUN yum clean all && yum makecache && \
    yum -y update && \
    yum -y install curl tar java-11-openjdk && \
    yum clean all

WORKDIR /opt

# --- choose one of these blocks ---

# A) Stick to 8.5.83 via archive.apache.org
ARG TOMCAT_VERSION=8.5.83
RUN curl -fSL \
  https://archive.apache.org/dist/tomcat/tomcat-8/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz \
  -o apache-tomcat.tar.gz && \
  tar xzf apache-tomcat.tar.gz && \
  mv apache-tomcat-${TOMCAT_VERSION} tomcat && \
  rm -f apache-tomcat.tar.gz

# B) Or switch to a currently mirrored version (uncomment and set desired version)
# ARG TOMCAT_VERSION=8.5.94
# RUN curl -fSL \
#   https://dlcdn.apache.org/tomcat/tomcat-8/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz \
#   -o apache-tomcat.tar.gz && \
#   tar xzf apache-tomcat.tar.gz && \
#   mv apache-tomcat-${TOMCAT_VERSION} tomcat && \
#   rm -f apache-tomcat.tar.gz

WORKDIR /opt/tomcat/webapps
# COPY ~/webapp1/*.war /opt/tomcat/webapps/
EXPOSE 8080
ENTRYPOINT ["/opt/tomcat/bin/catalina.sh", "run"]
