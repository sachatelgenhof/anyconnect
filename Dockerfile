FROM ubuntu:jammy

ENV TERM linux

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    apt-get update && \
    apt-get install -y \
    apt-utils \
    wget \
    libxml2 \
    libgtk-3-0 \
    openssl \
    iproute2 \
    net-tools \
    traceroute \
    kmod \
    iptables \
    ca-certificates \
    file \
    gettext-base \
    libglib2.0-0 \
    dnsmasq \
    dmidecode \
    lsb-release \
    iputils-ping \
    alien

RUN mkdir /root/Install
WORKDIR /root/Install
COPY packages/anyconnect.tar.gz .
COPY packages/SentinelAgent_linux_x86_64_v23_2_2_4.deb .

RUN tar xzf anyconnect.tar.gz && \
    mv cisco-secure-client-linux64-* anyconnect && \
    bash -c "mkdir -p /usr/share/icons/hicolor/{48x48,64x64,96x96,128x128,256x256}/apps /usr/share/desktop-directories /usr/share/applications/"

WORKDIR /root/Install/anyconnect/vpn
RUN yes | ./vpn_install.sh 2 > /dev/null

RUN ln -sf /etc/ssl/certs/ca-certificates.crt /opt/.cisco/certificates/ca/ca-certificates.pem

WORKDIR /root/Install/anyconnect/posture
RUN ./posture_install.sh --no-license > /dev/null

WORKDIR /root

COPY docker/entrypoint.sh /entrypoint.sh
COPY docker/fix-firewall.sh /fix-firewall.sh

RUN chmod +x /entrypoint.sh && \
    chmod +x /fix-firewall.sh

RUN apt-get install /root/Install/SentinelAgent_linux_x86_64_v23_2_2_4.deb
RUN /opt/sentinelone/bin/sentinelctl management token set <token-here>

RUN mkdir -p /opt/foil && touch /opt/foil/.breathe.txt

ENTRYPOINT /entrypoint.sh
