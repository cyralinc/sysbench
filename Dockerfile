FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update &&  apt-get -y install curl && apt-get -y install wget && apt-get -y install git

###############To install Sysbench from Release##############
RUN apt-get update && \
     apt -y install make automake libtool pkg-config libaio-dev
RUN apt-get update && \
     apt -y install libmysqlclient-dev libpq-dev libssl-dev && \
     apt -y install mysql-client mysql-workbench 


ARG benchdir="/cyral_bench"

WORKDIR $benchdir

RUN git clone https://github.com/akopytov/sysbench.git && \
    cd sysbench && \
    	git checkout 797e4c468f9c974abd6eb7499b718e8542a6f7b6 && \
         ./autogen.sh && \
         ./configure --with-pgsql &&  \
         make -j  && \
         make install

ENV LD_LIBRARY_PATH /usr/lib/x86_64-linux-gnu/
