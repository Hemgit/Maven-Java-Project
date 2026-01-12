
# Use CentOS 7 base image
FROM centos:7

LABEL maintainer="RNS <rns@rnstech.com>"

# Point all repos to the CentOS vault (7.9.2009) and disable mirrorlists
RUN sed -i \
  -e 's|^mirrorlist=|#mirrorlist=|g' \
  -e 's|^#baseurl=http://mirror.centos.org/centos/\$releasever|baseurl=http://vault.centos.org/7.9.2009|g' \
  /etc/yum.repos.d/CentOS-Base.repo || true


# Set working directory
WORKDIR /opt

# Download Tomcat (example: 8.5.83)
RUN curl -fSL https://dlcdn.apache.org/tomcat/tomcat-8/v8.5.83/bin/apache-tomcat-8.5.83.tar.gz -o apache-tomcat.tar.gz && \
    tar xzf apache-tomcat.tar.gz && \
    mv apache-tomcat-8.5.83 tomcat && \
    rm -f apache-tomcat.tar.gz



# Move into Tomcat webapps and deploy WAR
WORKDIR /opt/tomcat/webapps


# COPY ~/webapp1/*.war /opt/tomcat/webapps/

# Expose Tomcat port
EXPOSE 8080



# Entrypoint to run Tomcat
ENTRYPOINT ["/opt/tomcat/bin/catalina.sh", "run"]
