# eisenvault/alfresco

FROM ubuntu:16.04
MAINTAINER Tushar Khanka <tushar.khanka@eisenvault.com>

# install some necessary/desired debs and get updates
RUN apt-get update -y && \
    apt-get install -y \
                   vim \
                   apache2 \
                   fontconfig \
                   patch \
                   sudo \
                   rsync \
                   tesseract-ocr \
                   tesseract-ocr-eng \
                   poppler-utils \
                   parallel \
                   pdftk zip \
                   supervisor \
                   wget && \
    apt-get clean all && rm -rf /tmp/* /var/tmp/*

RUN groupadd evadm
RUN useradd -m -s /bin/bash -g evadm evadm
#RUN mkdir /opt/eisenvault_installations/
#RUN mkdir /opt/eisenvault_installations/ocr/
RUN mkdir -p /home/evadm/ev-install-scripts-5.2
COPY assets/install_alfresco.sh /home/evadm/install_alfresco.sh
COPY assets/install_mysql_connector.sh /home/evadm/install_mysql_connector.sh

COPY assets/ev-base-code /home/evadm/ev-install-scripts-5.2
RUN ./home/evadm/ev-install-scripts-5.2/ev-install-package/install-scripts/common-scripts/new-server-initial-setup.sh

#RUN chown -R evadm:evadm /opt/eisenvault_installations/
RUN chown -R evadm:evadm /home/evadm
USER evadm

# install alfresco
#COPY assets/install_alfresco.sh /home/evadm/install_alfresco.sh
RUN /home/evadm/install_alfresco.sh
# install mysql connector for alfresco
#COPY assets/install_mysql_connector.sh /home/evadm/install_mysql_connector.sh
RUN /home/evadm/install_mysql_connector.sh
#    rm -rf /home/evadm/* 
# this is for LDAP configuration
RUN mkdir -p /opt/eisenvault_installations/alfresco/tomcat/shared/classes/alfresco/extension/subsystems/Authentication/ldap/ldap1/
RUN mkdir -p /opt/eisenvault_installations/alfresco/tomcat/shared/classes/alfresco/extension/subsystems/Authentication/ldap-ad/ldap1/
COPY assets/ldap-authentication.properties /opt/eisenvault_installations/alfresco/tomcat/shared/classes/alfresco/extension/subsystems/Authentication/ldap/ldap1/ldap-authentication.properties
COPY assets/ldap-ad-authentication.properties /opt/eisenvault_installations/alfresco/tomcat/shared/classes/alfresco/extension/subsystems/Authentication/ldap-ad/ldap1/ldap-ad-authentication.properties


# backup alf_data so that it can be used in init.sh if necessary
ENV ALF_DATA /opt/eisenvault_installations/alfresco/alf_data
#RUN chown evadm:evadm /alf_data.install/
RUN rsync -av $ALF_DATA /home/evadm/alf_data.install/

# adding path file used to disable tomcat CSRF
#COPY assets/disable_tomcat_CSRF.patch /opt/eisenvault_installations/alfresco/disable_tomcat_CSRF.patch

# install scripts
#COPY assets/init.sh /opt/eisenvault_installations/alfresco/init.sh
#COPY assets/supervisord.conf /etc/supervisord.conf

# inatall eisenvault
#RUN mkdir -p /home/evadm/ev-install-scripts-5.2

#COPY assets/ev-base-code /home/evadm/ev-install-scripts-5.2
#RUN ev-install-scripts-5.2/scripts/new-server-initial-setup.sh
#RUN chown -R evadm:evadm /home/evadm
#RUN chown -R evadm:evadm /home/evadm
#RUN chown -R evadm:evadm /opt/

#USER evadm
ENV EV_BASE=/home/evadm/ev-install-scripts-5.2/ev-install-package/install-scripts/linux-scripts/prod
#ENV ALF_HOME=alfresco
WORKDIR $EV_BASE
RUN pwd
RUN ls
RUN ./install_prod.sh /opt/eisenvault_installations/alfresco

##configure apache2

#RUN a2enmod rewrite && service apache2 restart
#RUN a2enmod ssl
#RUN a2enmod proxy proxy_ajp proxy_http
#RUN a2enmod headers
#RUN service apache2 restart

#RUN mkdir /etc/apache2/certs

#COPY assets/apache2/certs /etc/apache2/certs
#COPY assets/apache2/sites-available /etc/apache2/sites-available


ENV AMP_APPLY=/opt/eisenvault_installations/alfresco/
WORKDIR $AMP_APPLY
RUN ./bin/apply_amps.sh -force -verbose
RUN ./alfresco.sh restart

#RUN mkdir -p /opt/eisenvault_installations/alfresco/tomcat/webapps/ROOT
#COPY assets/index.jsp /opt/eisenvault_installations/alfresco/tomcat/webapps/ROOT/

VOLUME /opt/eisenvault_installations/alfresco/alf_data
VOLUME /opt/eisenvault_installations/alfresco/tomcat/logs
#VOLUME /opt/eisenvault_installations/content


EXPOSE 21 80 137 138 139 445 7070 8009 8080
#CMD /usr/bin/supervisord -c /etc/supervisord.conf -n

