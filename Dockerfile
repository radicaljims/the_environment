FROM centos-6.5

ENV CATALINA_HOME /opt/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
RUN mkdir -p "$CATALINA_HOME"

# Trying to use this article as a guide:
# https://www.digitalocean.com/community/tutorials/how-to-install-apache-tomcat-8-on-centos-7

# Make sure we have a Jabba
RUN yum install -y java-1.7.0-openjdk-devel
RUN yum install -y wget curl

RUN groupadd -r mongodb && useradd -r -g mongodb mongodb
RUN groupadd tomcat

RUN useradd -M -s /bin/nologin -g tomcat -d /opt/tomcat tomcat

RUN wget http://mirrors.sonic.net/apache/tomcat/tomcat-8/v8.0.36/bin/apache-tomcat-8.0.36.tar.gz

RUN tar xvf apache-tomcat-8.0.36.tar.gz -C /opt/tomcat --strip-components=1

WORKDIR $CATALINA_HOME

RUN chgrp -R tomcat conf
RUN chmod g+rwx conf
RUN chmod g+r conf/*

RUN chown -R tomcat webapps/ work/ temp/ logs/

WORKDIR /

# Okay so Mongo doesn't seem to like running in a container with Tomcat
# Or maybe it's my centos base? I'm not sure

# And now for Mongo
# Depending no how we're interacting with Mongo I'd like to have it
# off as a separate container

COPY files/mongodb.repo /etc/yum.repos.d/
COPY files/mongodb.conf /etc/
RUN yum install -y mongodb-org-2.6.12 mongodb-org-server-2.6.12 mongodb-org-shell-2.6.12 mongodb-org-mongos-2.6.12 mongodb-org-tools-2.6.12
# RUN yum install -y mongodb-org

RUN mkdir -p /data/db /data/configdb \
    && chown -R mongodb:mongodb /data/db /data/configdb
VOLUME /data/db /data/configdb

# And now for RabbitMQ
# Supposedly we can EPEL Erlang!
# (Edit: sadly that version is too old for rmq 3.6.3.whatevs)
# RUN yum install -y erlang
RUN wget https://www.rabbitmq.com/releases/erlang/erlang-17.4-1.el6.x86_64.rpm
RUN rpm -i erlang-17.4-1.el6.x86_64.rpm

RUN wget https://www.rabbitmq.com/releases/rabbitmq-server/v3.6.3/rabbitmq-server-3.6.3-1.noarch.rpm
RUN rpm --import https://www.rabbitmq.com/rabbitmq-release-signing-key.asc
RUN yum install -y rabbitmq-server-3.6.3-1.noarch.rpm

WORKDIR $CATALINA_HOME

# COPY files/startup.sh $CATALINA_HOME
COPY files/catalina.sh $CATALINA_HOME/bin/

EXPOSE 8080
EXPOSE 27017

CMD ["catalina.sh", "run"]


