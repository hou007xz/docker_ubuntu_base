FROM ubuntu

RUN apt-get update && \
    apt-get install -y openssh-server && \
    apt-get install -y daemontools
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*

#ssh
RUN mkdir /var/run/sshd
RUN echo 'root:password' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

#daemontools
RUN mkdir -p /etc/bootservices/sshd
RUN echo "#!/bin/bash\n exec /usr/sbin/sshd -D" > /etc/bootservices/sshd/run
RUN chmod +x /etc/bootservices/sshd/run

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

VOLUME ["/var/cache/nginx"]

EXPOSE 22

ENTRYPOINT ["/usr/bin/svscan", "/etc/bootservices/"]