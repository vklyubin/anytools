FROM oraclelinux:9-slim

LABEL description="v1.7 Running nginx, listen on 80 and 8080, plus lot of tools"
LABEL org.opencontainers.image.authors="vladimir.klyubin@broadcom.com"

RUN microdnf install -y tar openssl nginx mlocate bash bash-completion openssh-clients nmap tcpdump bind-utils net-tools iputils iproute ca-certificates traceroute frr openldap-clients curl && \
    microdnf clean all

RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && rm kubectl
RUN curl -LO https://get.helm.sh/helm-v3.16.4-linux-amd64.tar.gz && \
    tar xzvf helm-v3.16.4-linux-amd64.tar.gz && install -o root -g root -m 0755 linux-amd64//helm /usr/local/bin/helm && rm -rf linux-amd64

COPY nginx.conf /etc/nginx/nginx.conf
COPY bgpd.conf /etc/quagga/bgpd.conf
COPY index.html /usr/share/nginx/html/
COPY anytools-startup.sh /usr/local/bin/

EXPOSE 8080 80

CMD ["/bin/bash","/usr/local/bin/anytools-startup.sh"]
