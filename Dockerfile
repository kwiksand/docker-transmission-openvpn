FROM centos:centos7
MAINTAINER "Shannon Carver" <shannon.carver@gmail.com>

ENV TZ=Australia/Perth

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Add s6 overlay v1.14.0.3 (https://github.com/just-containers/s6-overlay)
ADD runit-2.1.2-1.el7.centos.x86_64.rpm /tmp/
RUN rpm -Uvh /tmp/runit-2.1.2-1.el7.centos.x86_64.rpm && \
    yum install -y epel-release && \
    rpm -Uvh https://rpm.darkhaven.co/darkhaven-release-1-0.noarch.rpm && \
    yum install -y openvpn cronie rsyslog transmission-daemon ethtool && \
    mkdir -p /etc/service/openvpn /etc/service/crond /etc/service/transmission

# supervisor
COPY runit/service/crond/* /etc/service/crond/
COPY runit/service/openvpn/* /etc/service/openvpn/
COPY runit/service/transmission/* /etc/service/transmission/

#ADD clientcert.ovpn /etc/openvpn/clientcert.ovpn

EXPOSE 51222 57011
#EXPOSE 51222 

COPY runit_bootstrap /usr/sbin/runit_bootstrap
RUN chmod 755 /usr/sbin/runit_bootstrap /etc/service/openvpn/run /etc/service/transmission/run /etc/service/crond/run
ENTRYPOINT ["/usr/sbin/runit_bootstrap"]
