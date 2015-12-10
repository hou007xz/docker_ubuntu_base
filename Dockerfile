FROM ubuntu

# MAINTAINER NGINX Docker Maintainers "docker-maint@nginx.com"

# RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62
# RUN echo "deb http://nginx.org/packages/mainline/debian/ jessie nginx" >> /etc/apt/sources.list

# ENV NGINX_VERSION 1.9.8-1~jessie

# RUN apt-get update && \
#    apt-get install -y ca-certificates nginx=${NGINX_VERSION} && \
#    rm -rf /var/lib/apt/lists/*
RUN apt-get update
#RUN apt-get install -y nginx
RUN apt-get install -y openssh-server
RUN apt-get install -y daemontools
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*


#ssh
RUN mkdir /var/run/sshd
RUN echo 'root:hou007xz' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

#daemontools
RUN mkdir -p /etc/bootservices/sshd
RUN echo "#!/bin/bash\n exec /usr/sbin/sshd -D" > /etc/bootservices/sshd/run
RUN chmod +x /etc/bootservices/sshd/run

#RUN mkdir -p /etc/bootservices/nginx
#RUN echo "#!/bin/bash\n exec /usr/sbin/nginx" > /etc/bootservices/nginx/run
#RUN chmod +x /etc/bootservices/nginx/run

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile


# forward request and error logs to docker log collector
#RUN ln -sf /dev/stdout /var/log/nginx/access.log
#RUN ln -sf /dev/stderr /var/log/nginx/error.log

VOLUME ["/var/cache/nginx"]

#EXPOSE 22 80 443
EXPOSE 22

# CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
# CMD ["/usr/sbin/sshd", "-D"]
ENTRYPOINT ["/usr/bin/svscan", "/etc/bootservices/"]