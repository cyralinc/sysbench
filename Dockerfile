FROM ubuntu:xenial

ENV LD_LIBRARY_PATH /usr/lib/x86_64-linux-gnu/

RUN apt-get update

RUN apt-get -y install make automake libtool pkg-config libaio-dev git

# For MySQL support
RUN apt-get -y install libssl-dev libmysqlclient-dev mysql-client mysql-workbench 

# For PostgreSQL support
RUN apt-get -y install libpq-dev 

RUN git clone https://github.com/akopytov/sysbench.git

WORKDIR sysbench
RUN git checkout 797e4c468f9c974abd6eb7499b718e8542a6f7b6
RUN ./autogen.sh
RUN ./configure --with-mysql --with-pgsql
RUN make -j
RUN make install

WORKDIR /root
RUN rm -rf sysbench
