FROM ubuntu:20.04
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -qq update -y \
    && apt-get -qq install -y apt-offline openssh-server \
    && apt-get -qq install -y python3 python3-apt python3-dev python3-pip \
    && apt-get -qq clean -y \
    && apt-get -qq purge -y \
    && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/* \
    && mkdir /root/.ssh \
    && mkdir /var/run/sshd \
    && echo 'root:JMJhZy1Hxg6bFuHK5JYC6Xk9d3MBN7DK' | chpasswd \
    && sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config \
    && yes | unminimize

EXPOSE 22
WORKDIR /root
CMD ["/usr/sbin/sshd", "-D"]
