FROM node:20-alpine

ARG COMMIT_HASH

# Set up files
WORKDIR /app
COPY . .

# Install dependencies
ENV NODE_ENV=production

#Set MariaDB
#ENV MARIADB_ROOT_PASSWORD=root_password \
#    MARIADB_DATABASE=modbot \
#    MARIADB_USER=modbot \
#    MARIADB_PASSWORD=password

RUN apk add --update --no-cache mariadb mariadb-client

#RUN mkdir -p /run/mysqld /var/lib/mysql && \
#    chmod 777 /run/mysqld && \
RUN mariadb-install-db --user=mysql --datadir=/var/lib/mysql && \
    mariadbd-safe --datadir='/var/lib/mysql' & \
    sleep 10 && \
    mariadb -e "CREATE DATABASE modbot;" && \
    mariadb -e "CREATE USER 'modbot'@'localhost' IDENTIFIED BY 'mariadb_password_mariadb_is_setup_to_ignore_requests_outside_of_docker_network';" && \
    mariadb -e "GRANT ALL PRIVILEGES ON modbot.* TO 'modbot'@'localhost';" && \
    mariadb -e "FLUSH PRIVILEGES;" 
    # Sort of a hack to make sure the database is ready before continuing
    mysql -u modbot -p mariadb_password_mariadb_is_setup_to_ignore_requests_outside_of_docker_network -h localhost -e "SELECT VERSION();" || exit 1

# Node.js
RUN npm ci

# Environment
ENV MODBOT_COMMIT_HASH=$COMMIT_HASH \
    MODBOT_USE_ENV=1 \
    MODBOT_DATABASE_HOST=localhost \
    MODBOT_DATABASE_PASSWORD=mariadb_password_mariadb_is_setup_to_ignore_requests_outside_of_docker_network \
    MODBOT_AUTH_TOKEN=SELF_TEST

COPY ./docker/entrypoint.sh /entrypoint.sh
COPY ./docker/test.sh /test.sh

# Self-test
RUN chmod +x /test.sh && \
    /test.sh || exit 1 && \
    rm /test.sh

CMD [ "/bin/ash", "/entrypoint.sh"]
