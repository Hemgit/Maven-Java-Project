
# Use a supported, RHEL-compatible base
FROM rockylinux:9

LABEL maintainer="RNS <rns@rnstech.com>"

# Update and install curl + Java (OpenJDK 11)
RUN dnf -y update && \
    dnf -y install curl tar java-11-openjdk && \
    dnf clean all

# Work in /opt
WORKDIR /opt

# Download a maintained Tomcat 8.x release (example: 8.5.83)
# Check https://tomcat.apache.org/download-80.cgi for the current 8.x release + mirrors
RUN curl -fSL https://dlcdn.apache.org/tomcat/tomcat-8/v8.5.83/bin/apache-tomcat-8.5.83.tar.gz -o apache-tomcat.tar.gz && \
    tar xzf apache-tomcat.tar.gz && \
    mv apache-tomcat-8.5.83 tomcat && \
    rm -f apache-tomcat.tar.gz

# Deploy your app (WAR renamed to webapp.war or ROOT.war)
WORKDIR /opt/tomcat/webapps
COPY target/*.war /opt/tomcat/webapps/webapp.war
# If you prefer ROOT:
# COPY target/*.war /opt/tomcat/webapps/ROOT.war

EXPOSE 8080

ENTRYPOINT ["/opt/tomcat/bin/catalina.sh", "run"]
