
# --- Dockerfile (CentOS 7 + Tomcat 8.5) ---
FROM centos:7

LABEL maintainer="RNS <rns@rnstech.com>"

# Use explicit vault repos so yum works on EOL CentOS 7
RUN cat >/etc/yum.repos.d/CentOS-Base.repo <<'EOF'
[base]
name=CentOS-7 - Base
baseurl=http://vault.centos.org/7.9.2009/os/$basearch/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

[updates]
name=CentOS-7 - Updates
baseurl=http://vault.centos.org/7.9.2009/updates/$basearch/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

[extras]
name=CentOS-7 - Extras
baseurl=http://vault.centos.org/7.9.2009/extras/$basearch/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
EOF

# Tools + Java
RUN yum clean all && yum makecache && \
    yum -y update && \
    yum -y install curl tar java-11-openjdk && \
    yum clean all

# Pick a Tomcat 8.5.x from Apache archive (stable URLs)
ARG TOMCAT_VERSION=8.5.94
WORKDIR /opt
RUN curl -fSL \
    https://archive.apache.org/dist/tomcat/tomcat-8/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz \
    -o apache-tomcat.tar.gz && \
    tar xzf apache-tomcat.tar.gz && \
    mv apache-tomcat-${TOMCAT_VERSION} tomcat && \
    rm -f apache-tomcat.tar.gz

# Optional hardening
RUN useradd -r -s /sbin/nologin tomcat && \
    chown -R tomcat:tomcat /opt/tomcat
USER tomcat

# Deploy WAR(s) with their original names → “normal” context paths
WORKDIR /opt/tomcat/webapps
# If you expect exactly one WAR in the build context:
#COPY *.war /opt/tomcat/webapps/
# Or a specific one:
 COPY student.war /opt/tomcat/webapps/

EXPOSE 8080
ENTRYPOINT ["/opt/tomcat/bin/catalina.sh", "run"]
