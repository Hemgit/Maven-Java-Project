
# Use CentOS 7 base image
FROM centos:7

LABEL maintainer="RNS <rns@rnstech.com>"

# Point all repos to the CentOS vault (7.9.2009) and disable mirrorlists
RUN sed -i \
  -e 's|^mirrorlist=|#mirrorlist=|g' \
  -e 's|^#baseurl=http://mirror.centos.org/centos/\$releasever|baseurl=http://vault.centos.org/7.9.2009|g' \
  /etc/yum.repos.d/CentOS-Base.repo || true

# Clean, update, and install required packages
RUN yum clean all && yum makecache && \
    yum -y update && \
    yum -y install wget curl tar java-11-openjdk && \
    yum clean all

# Set working directory
WORKDIR /opt

# Download Tomcat (example: 8.5.83)
RUN curl -fSL https://dlcdn.apache.org/tomcat/tomcat-8/v8.5.83/bin/apache-tomcat-8.5.83.tar.gz -o apache-tomcat.tar.gz && \
    tar xzf apache-tomcat.tar.gz && \
    mv apache-tomcat-8.5.83 tomcat && \
    rm -f apache-tomcat.tar.gz

# Copy README for reference
COPY README.md /opt/

# Example environment variable
ENV test="testing the test variable"

# Move into Tomcat webapps and deploy WAR
WORKDIR /opt/tomcat/webapps
COPY target/*.war /opt/tomcat/webapps/webapp.war
# If you prefer ROOT:
# COPY target/*.war /opt/tomcat/webapps/ROOT.war

# Expose Tomcat port
EXPOSE 8080

# Simple CMD (like your original)
CMD echo "hell this is cmd statement"

# Entrypoint to run Tomcat
ENTRYPOINT ["/opt/tomcat/bin/catalina.sh", "run"]
