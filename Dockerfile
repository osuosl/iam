from centos:latest

RUN yum -y update

RUN yum -y install ruby\
                   rubygems\
                   vim\
                   screen

EXPOSE 80
EXPOSE 8000
EXPOSE 22

WORKDIR "/root"

CMD "/bin/echo 'Please Specify a Command when you docker run'"
