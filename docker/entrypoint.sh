#!/bin/ash
mariadbd-safe --datadir=/var/lib/mysql --skip-networking=0 --socket=/run/mysqld/mysqld.sock & npm start