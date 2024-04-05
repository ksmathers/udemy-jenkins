ARG ARTIFACTORY=

FROM ${ARTIFACTORY}ubuntu:latest

ENV ENV=dev

RUN apt update && \
    apt install -y git bash curl gettext docker python3 python3-pip openssl jq wget unzip openjdk-17-jre-headless patch && \
    apt-get clean
RUN /usr/bin/pip3 install awscli

WORKDIR /root
COPY ./src ./src

# Install firewall certificate
RUN cp src/CombinedCA.cer /usr/share/ca-certificates/CombinedCA.crt
RUN echo "CombinedCA.crt" >>/etc/ca-certificates.conf
RUN update-ca-certificates

# Enable legacy renegotiation for running from behind the firewall
RUN patch -p0 -d/ <src/openssl_cnf.patch && \
    patch -p0 -d/ <src/wgetrc.patch

# Fetch and install Jenkins
RUN wget -O /usr/share/keyrings/jenkins-keyring.asc \
    https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key && \
    echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
    https://pkg.jenkins.io/debian-stable binary/ | tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null

RUN apt-get update && \
    apt-get install -y jenkins && \
    apt-get clean

# Install python libraries
#COPY dist dist
#RUN pip install dist/*whl

# Install Maven
RUN cd /opt && \
    wget -O maven.tgz \
    https://dlcdn.apache.org/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz && \
    tar xvzf maven.tgz
RUN ln -sf /opt/apache-maven-* /opt/maven && \
    ln -sf /opt/maven/bin/mvn /usr/local/bin/mvn 

# Install manual debugging utilities (development)
RUN apt install -y sudo vim rcs && \
    apt-get clean && \
    echo "jenkins ALL=NOPASSWD: ALL" >>/etc/sudoers

RUN apt-get install -y docker.io && \
    apt-get clean && \
    usermod -G docker jenkins

RUN mkdir -p /home/jenkins && \
    cp /root/src/start.sh /home/jenkins/start.sh && \
    chown -R jenkins.jenkins /home/jenkins

USER jenkins
ENV REQUESTS_CA_BUNDLE=/etc/ssl/certs/CombinedCA.pem
ENV AWS_CA_BUNDLE=/etc/ssl/certs/CombinedCA.pem
WORKDIR /home/jenkins
