# ------------------------------------------------------------------------------------
# This Dockerfile is intended to start from a Centos 7 image from the Docker registry
# and produce an image with Fortify SSC installed and ready to be deployed to ECS or ??.
# The Dockerfile dependency is the license file and the install file for Fortify SSC 19.2.0,
# which you must provide, as well as a parameters required in the conf folder.
# ------------------------------------------------------------------------------------
# -----------------------------------------------------------------
# Start with the official Centos base image. Should be around 75mb.
# -----------------------------------------------------------------
FROM centos:7
EXPOSE 8080/tcp
EXPOSE 443/tcp
# -------------------------------------------
# Set up required volumes for systemd to work
# -------------------------------------------
# VOLUME /run /sys/fs/cgroup
# ---------------------------------------------------
# Copy the install and license files to /root/install
# ---------------------------------------------------
COPY ./Fortify_SSC_Server_19.2.0.zip /root/install/Fortify_SSC_Server_19.2.0.zip
COPY ./mysql-connector-java-8.0.19-1.el7.noarch.rpm /root/install/mysql-connector-java-8.0.19-1.el7.noarch.rpm
COPY ./fortifyssc.service /etc/systemd/system/
ENV container docker
# -----------------------------------------------------------------------
# Update and install some required dependencies, move license file, unzip
# install contents and move the seed files to the run dir.
# -----------------------------------------------------------------------
RUN yum -y update;\
yum -y install deltarpm;\
yum -y install unzip java-1.8.0 mysql;\
cd /root/install;\
# ----------------------------------------
# Unzip the install archive and delete it.
# ----------------------------------------
unzip Fortify_SSC_Server_19.2.0.zip -d /root/install/;\
rm Fortify_SSC_Server_19.2.0.zip;\
# -----------------------------------------------
# Unzip the Apache Tomcat server and the SSC WAR
# -----------------------------------------------
unzip apache-tomcat-9.0.24.zip -d /opt/;\
unzip Fortify_19.2.0_Server_WAR_Tomcat.zip -d /opt/apache-tomcat-9.0.24/webapps/;\
# -----------------------------
# Install the JDBC Java driver
# -----------------------------
rpm -ivh mysql-connector-java-8.0.19-1.el7.noarch.rpm;\
cp /usr/share/java/mysql-connector-java.jar /opt/apache-tomcat-9.0.24/lib/;\
# -------
# Cleanup
# -------
rm mysql-connector-java-8.0.19-1.el7.noarch.rpm;\
rm Fortify_19.2.0_Server_WAR_Tomcat.zip;\
rm apache-tomcat-9.0.24.zip;\
rm *.sig *.asc *.sha512;\
# --------------------------------
# Make the seed bundles available
# --------------------------------
mv Fortify_PCI_Basic_Seed_Bundle-2019_Q3.zip /opt/apache-tomcat-9.0.24/webapps/;\
mv Fortify_PCI_SSF_Basic_Seed_Bundle-2019_Q3.zip /opt/apache-tomcat-9.0.24/webapps/;\
mv Fortify_Process_Seed_Bundle-2019_Q3.zip /opt/apache-tomcat-9.0.24/webapps/;\
mv Fortify_Report_Seed_Bundle-2019_Q3.zip /opt/apache-tomcat-9.0.24/webapps/;\
# ----------------------------------------
# Put the docs folder there just in case.
# ----------------------------------------
mv Docs /opt/apache-tomcat-9.0.24/webapps/;\
# ------------------
# Set some env vars
# ------------------
echo "CATALINA_HOME=/opt/apache-tomcat-9.0.24" >> /etc/environment;\
echo "JRE_HOME=/etc/alternatives/jre" >> /etc/environment;\
source /etc/environment;\
# --------------------------------------------------
# For some reason the Tomcat binaries don't have +x
# --------------------------------------------------
chmod +x /opt/apache-tomcat-9.0.24/bin/*.sh;\
# ------------------------------------------
# Some hoopjumping for systemctl to network
# ------------------------------------------
(cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;\
# ----------------------------------------------------
# Enable the systemctl service that autostarts Tomcat
# ----------------------------------------------------
systemctl enable fortifyssc.service
# ------------------------------------------------------
# Copy the config files to set up a server ready to run
# ------------------------------------------------------
COPY conf/* /root/.fortify/ssc/conf/
COPY ./FortifySSCLicense /root/.fortify/fortify.license
# COPY ./ssc.autoconfig /root/.fortify/ssc.autoconfig
RUN chown -R root:root /root/.fortify/*
# chmod 664 /root/.fortify/ssc.autoconfig;\
RUN echo "FINISHED!"
# ------------------------------------------------------------------------
# This has to be the first command to run for systemctl to work correctly
# ------------------------------------------------------------------------
CMD ["/usr/sbin/init"]
