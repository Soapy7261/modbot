#!/bin/ash
mariadbd-safe --datadir=/var/lib/mysql --skip-networking=0 --socket=/run/mysqld/mysqld.sock & sleep 5 # Start MariaDB, waits 5 seconds to ensure its actually started
npm start
