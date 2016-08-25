# This is a minimal dockerfile based on centos6 used to facilitate running the generated iptables script.
# Nothing magical happening here....

FROM centos:centos6

# install essentials
RUN yum install -y wget dhclient
RUN yum install -y wget openssh-server

RUN mkdir /var/run/sshd
RUN echo 'root:abc123' | chpasswd
RUN sed -i 's/#PermitRootLogin without-password/#PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]

# install pipework
RUN wget -N -P /opt/bin/ https://raw.githubusercontent.com/jpetazzo/pipework/master/pipework
RUN chmod +x /opt/bin/pipework
