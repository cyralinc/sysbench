# cyral-sysbench

Set of sysbench related files.

## Docker

The `Dockerfile` present in this directory can be used to build a sysbench Docker image. To do that, run:

```
docker build . -t cyral-sysbench:v0.0.1
```

After building the Docker container image, we can use it to execute sysbench commands.

## Using a prebuilt docker image
```
docker pull gcr.io/cyralpublic/cyral-sysbench:v0.0.1
```

### MySQL/Galera

A requirement to execute sysbench against a MySQL database is to create a schema and a user dedicated to sysbench.

```
mysql> CREATE SCHEMA sbtest;
mysql> CREATE USER sbtest@'%' IDENTIFIED BY 'password';
mysql> GRANT ALL PRIVILEGES ON sbtest.* to sbtest@'%';
```

To allow the use of some sysbench parameters, some MySQL global variables may need to be set, as illustrated by the following:

```
SET GLOBAL max_prepared_stmt_count = 1048576;
```

Then, to prepare a MySQL database to be used with sysbench, a command like the following can be issued:

```
docker run \
	--rm \
	--name=sb \
	--network="host" \
	gcr.io/cyralpublic/cyral-sysbench:v0.0.1 \
	sysbench \
	--db-driver=mysql \
	--tables=32 \
	--table_size=100000 \
	--threads=32 \
	--mysql-host=<mysql-host> \
	--mysql-port=<mysql-port> \
	--mysql-user=sbtest \
	--mysql-password=password \
	--mysql-ssl=REQUIRED \
	--thread-init-timeout=60 \
	oltp_read_only prepare
```

When this command finishes, sysbench has all necessary tables and data it needs, and we can use the following to run a workload.

```
# Disable TLS
docker run \
	--rm \
	--name=sb \
	--network="host" \
	gcr.io/cyralpublic/cyral-sysbench:v0.0.1 \
	sysbench \
	--db-driver=mysql \
	--report-interval=3 \
	--mysql-storage-engine=innodb \
	--table-size=100000 \
	--tables=32 \
	--rand-seed=06012020 \
	--rand-type=uniform \
	--threads=1500 \
	--warmup-time=300 \
	--time=300 \
	--mysql-host=<mysql-host> \
	--mysql-port=<mysql-port> \
	--mysql-user=sbtest \
	--mysql-password=password \
	--mysql-ssl=DISABLED \
	--thread-init-timeout=60 \
	oltp_read_only run
```

```
# Enable TLS
docker run \
	--rm \
	--name=sb \
	--network="host" \
	gcr.io/cyralpublic/cyral-sysbench:v0.0.1 \
	sysbench \
	--db-driver=mysql \
	--report-interval=3 \
	--mysql-storage-engine=innodb \
	--table-size=100000 \
	--tables=32 \
	--rand-seed=06012020 \
	--rand-type=uniform \
	--threads=1500 \
	--warmup-time=300 \
	--time=300 \
	--mysql-host=<mysql-host> \
	--mysql-port=<mysql-port> \
	--mysql-user=sbtest \
	--mysql-password=password \
	--mysql-ssl=REQUIRED \
	--thread-init-timeout=60 \
	oltp_read_only run
```

After the tests are complete, we can remove the data sysbench created, running:

```
docker run \
	--rm \
	--name=sb \
	--network="host" \
	gcr.io/cyralpublic/cyral-sysbench:v0.0.1 \
	sysbench \
	--db-driver=mysql \
	--tables=32 \
	--table_size=100000 \
	--threads=32 \
	--mysql-host=<mysql-host> \
	--mysql-port=<mysql-port> \
	--mysql-user=sbtest \
	--mysql-password=password \
	--mysql-ssl=REQUIRED \
	--thread-init-timeout=60 \
	oltp_read_only cleanup
```
