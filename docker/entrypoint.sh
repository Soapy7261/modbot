#!/bin/ash
mariadbd --user=root --datadir=/var/lib/mysql --socket=/run/mysqld/mysqld.sock & npm start
