FROM node:20-alpine

ARG COMMIT_HASH

# Set up files
WORKDIR /app
COPY . .
COPY docker/entrypoint.sh /entrypoint.sh
# Install dependencies
ENV NODE_ENV=production

#Set MariaDB
ENV MARIADB_ROOT_PASSWORD=mariadb_password_mariadb_is_setup_to_ignore_requests_outside_of_docker_network \
    MARIADB_DATABASE=modbot \
    MARIADB_USER=modbot \
    MARIADB_PASSWORD=mariadb_password_mariadb_is_setup_to_ignore_requests_outside_of_docker_network \
    # Modbot environment variables
    MODBOT_COMMIT_HASH=$COMMIT_HASH \
    MODBOT_USE_ENV=1 \
    MODBOT_DATABASE_HOST=localhost \
    MODBOT_DATABASE_PASSWORD=mariadb_password_mariadb_is_setup_to_ignore_requests_outside_of_docker_network \
    MODBOT_AUTH_TOKEN=SELF_TEST
RUN apk add --update --no-cache mariadb mariadb-client

#RUN mkdir -p /run/mysqld /var/lib/mysql && \
#    chmod 777 /run/mysqld && \
RUN mariadb-install-db --user=mysql --datadir=/var/lib/mysql && \
    mariadbd-safe --datadir='/var/lib/mysql' & \
    sleep 3 && \
    #mariadb -e "CREATE DATABASE modbot;" && \
    #mariadb -e "CREATE USER 'modbot'@'localhost' IDENTIFIED BY 'mariadb_password_mariadb_is_setup_to_ignore_requests_outside_of_docker_network';" && \
    #mariadb -e "GRANT ALL PRIVILEGES ON modbot.* TO 'modbot'@'localhost';" && \
    #mariadb -e "FLUSH PRIVILEGES;"
    # Sort of a hack to make sure the database is ready before continuing
    #mariadb -u modbot -p mariadb_password_mariadb_is_setup_to_ignore_requests_outside_of_docker_network -h localhost -e "SELECT VERSION();" || exit 1
    # Node.js
    RUN npm ci && \
    # Self test
    chmod +x /app/docker/test.sh && \
    /app/docker/test.sh || exit 1 && \
    # Clean up the extra files
    rm -rf /app/docker

CMD [ "/bin/ash", "/entrypoint.sh" ]
