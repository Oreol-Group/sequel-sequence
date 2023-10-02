# Contributing to sequel-sequence

👍🎉 First off, thanks for taking the time to contribute! 🎉👍

The following is a set of guidelines for contributing to this project. These are
mostly guidelines, not rules. Use your best judgment, and feel free to propose
changes to this document in a pull request.

## Code of Conduct

Everyone interacting in this project's codebases, issue trackers, chat rooms and
mailing lists is expected to follow the [code of conduct](https://github.com/oreol-group/sequel-sequence/blob/master/CODE_OF_CONDUCT.md).

## Reporting bugs

This section guides you through submitting a bug report. Following these
guidelines helps maintainers and the community understand your report, reproduce
the behavior, and find related reports.

- Before creating bug reports, please check the open issues; somebody may
  already have submitted something similar, and you may not need to create a new
  one.
- When you are creating a bug report, please include as many details as
  possible, with an example reproducing the issue.

## Contributing with code

Before making any radicals changes, please make sure you discuss your intention
by [opening an issue on Github](https://github.com/oreol-group/sequel-sequence/issues).

When you're ready to make your pull request, follow checklist below to make sure
your contribution is according to how this project works.

1. [Fork](https://help.github.com/forking/) sequel-sequence
2. Create a topic branch - `git checkout -b my_branch`
3. Make your changes using [descriptive commit messages](#commit-messages)
4. Update CHANGELOG.md describing your changes by adding an entry to the
   "Unreleased" section. If this section is not available, create one right
   before the last version.
5. Push to your branch - `git push origin my_branch`
6. [Create a pull request](https://docs.github.com/articles/creating-a-pull-request)
7. That's it!

## Styleguides

### Commit messages

- Use the present tense ("Add feature" not "Added feature")
- Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit the first line to 72 characters or less
- Reference issues and pull requests liberally after the first line

### Changelog

- Add a message describing your changes to the "Unreleased" section. The
  changelog message should follow the same style as the commit message.
- Prefix your message with one of the following:
  - `[Added]` for new features.
  - `[Changed]` for changes in existing functionality.
  - `[Deprecated]` for soon-to-be removed features.
  - `[Removed]` for now removed features.
  - `[Fixed]` for any bug fixes.
  - `[Security]` in case of vulnerabilities.

### Ruby code

- This project uses [Rubocop](https://rubocop.org) to enforce code style. Before
  submitting your changes, make sure your tests are passing and code conforms to
  the expected style by running `rake`.
```bash
$ bundle exec rake rubocop
```
- Do not change the library version. This will be done by the maintainer
  whenever a new version is about to be released.

## Ruby tests

Key points in preparing RDBMS and using tests.

### Preparing a PostgreSQL database

- Make sure you have a test PostgreSQL database:
```bash
$ sudo psql -U USER_NAME -d test
test=# \dt
          List of relations
 Schema |  Name   | Type  |   Owner   
--------+---------+-------+-----------
 public | masters | table | USER_NAME
 public | things  | table | USER_NAME
```
and role `postgres`
```bash
$ psql -d test -c 'SELECT rolname FROM pg_roles;'
          rolname          
---------------------------
 postgres
```
- If none of them exist, create role
```bash
$ psql -d postgres -c "create role postgres superuser createdb login password 'postgres';"
```
and database with a couple of tables:

```bash
$ sudo psql -U postgres -d postgres
postgres=# CREATE DATABASE test;
postgres=# \c test
test=# CREATE TABLE IF NOT EXISTS things ();
test=# CREATE TABLE IF NOT EXISTS masters ();
test=# \q
```

### Preparing a MariaDB database

- Make sure you have a test MariaDB database:
```bash
$ mysql
MariaDB [(none)]> show databases;
MariaDB [(none)]> USE test;
MariaDB [test]> SHOW TABLES;
+----------------------+
| Tables_in_test       |
+----------------------+
| builders             |
| wares                |
+----------------------+
```
- If it doesn't exists, create one with a couple of tables:
```bash
MariaDB [(none)]> CREATE DATABASE test;
MariaDB [(none)]> USE test;
MariaDB [test]> CREATE TABLE IF NOT EXISTS wares(id int auto_increment, primary key(id));
MariaDB [test]> CREATE TABLE IF NOT EXISTS builders(id int auto_increment, primary key(id));
```

### Preparing a MySQL database

The optimal way to share Mysql and MariaDB on the same computer is to utilize docker containers.

- Check the local availability of a Mysql container:
```bash
$ docker image ls
REPOSITORY          TAG             IMAGE ID       CREATED         SIZE
mysql               latest          3503aa5f0751   2 days ago      599MB
```
- If there is no distribution package download the docker container with Mysql to the local computer:
```bash
$ docker run -p 3360:3306 --name test_mysql  -e MYSQL_ROOT_PASSWORD=rootroot -d mysql:latest
```
- Show running containers:
```bash
$ docker container ls      
CONTAINER ID   IMAGE          COMMAND                  CREATED          STATUS          PORTS                               NAMES
a0d3476699f4   mysql:latest   "docker-entrypoint.s…"   17 minutes ago   Up 11 seconds   33060/tcp, 0.0.0.0:3360->3306/tcp   test_mysql
```
- Launch the MySQL container if it is still not running:
```bash
$ docker start test_mysql
```

To create a new database for tests, you could run the MySQL client in the terminal as follows:

- Check the IP address of the running MySQL server:
```bash
$ docker inspect test_mysql
...
  "IPAddress": "172.17.0.2",
...
```
- Run the MySQL client:
```bash
$ docker run -e MYSQL_ROOT_PASSWORD=rootroot -it mysql /bin/bash
bash-4.4#
```
- Launch the MySQL shell:
```bash
bash-4.4# mysql -h 172.17.0.2 -u root  -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 8
Server version: 8.1.0 MySQL Community Server - GPL

Copyright (c) 2000, 2023, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>
```
- Make sure that the test database is available:
```bash
mysql> show schemas;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| test               |
+--------------------+
```
- If the test danabase doesn't exists, create it:
```bash
mysql> CREATE DATABASE test;
```
- Create a couple of tables:
```bash
mysql> USE test;
mysql> CREATE TABLE IF NOT EXISTS stuffs(id int auto_increment, primary key(id));
mysql> CREATE TABLE IF NOT EXISTS creators(id int auto_increment, primary key(id));
```

### Preparing a SQLite database

- Add a test SQLite database:
```bash
$ mkdir db && touch db/test.sqlite3
```
- Add a couple of tables in the SQLite database:
```bash
$ sqlite3 db/test.sqlite3
sqlite> create table objects(id integer primary key autoincrement);
sqlite> create table apprentices(id integer primary key autoincrement);
```

### Running tests:

```bash
$ bundle exec rake TEST=test/sequel/postgresql_sequence_test.rb
$ bundle exec rake TEST=test/sequel/mariadb_sequence_test.rb
$ bundle exec rake TEST=test/sequel/mysql_sequence_test.rb
$ bundle exec rake TEST=test/sequel/sqlite_sequence_test.rb
$ bundle exec rake TEST=test/sequel/mock_sequence_test.rb
```

Short command:
```bash
$ bundle exec rake postgresql
$ bundle exec rake mariadb
$ bundle exec rake mysql
$ bundle exec rake sqlite
$ bundle exec rake mock
```
