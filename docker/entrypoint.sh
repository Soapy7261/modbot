#!/bin/ash
mariadbd-safe --skip-grant-tables --datadir=/var/lib/mysql --skip-networking=0 --socket=/run/mysqld/mysqld.sock & sleep 5
npm start
