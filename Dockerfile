
# --- Dockerfile (CentOS 7 + Tomcat 8.5) ---
FROM centos:7

LABEL maintainer="RNS <rns@rnstech.com>"

# Enable CentOS 7 vault (EOL)
RUN sed -i \
  -e 's|^mirrorlist=|#mirrorlist=|g' \
  -e 's|^#baseurl=http://mirror.centos.org/centos/\\$releasever|baseurl=http://vault.centos.org/7.9.2009|g' \
  /etc/yum.repos.d/CentOS-Base.repo || true

# Install curl, tar, Java
RUN yum clean all && yum makecache && \
    yum -y update && \
    yum -y install curl tar java-11-openjdk && \
    yum clean all

# Choose Tomcat version (use archive for stability)
ARG TOMCAT_VERSION=8.5.94
WORKDIR /opt
RUN curl -fSL \
    https://archive.apache.org/dist/tomcat/tomcat-8/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz \
    -o apache-tomcat.tar.gz && \
    tar xzf apache-tomcat.tar.gz && \
    mv apache-tomcat-${TOMCAT_VERSION} tomcat && \
    rm -f apache-tomcat.tar.gz

# (Optional) run as non-root for security
RUN useradd -r -s /sbin/nologin tomcat && \
    chown -R tomcat:tomcat /opt/tomcat
USER tomcat

# Copy your WAR: either as a named app or ROOT (for /)
WORKDIR /opt/tomcat/webapps
# Copy to a named context:
 COPY build/webapp.war /opt/tomcat/webapps/webapp.war


EXPOSE 8080
ENTRYPOINT ["/opt/tomcat/bin/catalina.sh", "run"]
