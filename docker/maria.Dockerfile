FROM node:20-alpine

ARG COMMIT_HASH

# Set up files
WORKDIR /app
COPY . .
COPY docker/entrypoint.sh /entrypoint.sh
# Install dependencies

ENV NODE_ENV=production \
    # MariaDB environment variables
    #MARIADB_ROOT_PASSWORD=mariadb_password_mariadb_is_setup_to_ignore_requests_outside_of_docker_network \
    #MARIADB_DATABASE=modbot \
    #MARIADB_USER=modbot \
    #MARIADB_PASSWORD=mariadb_password_mariadb_is_setup_to_ignore_requests_outside_of_docker_network \
    # Modbot environment variables
    MODBOT_COMMIT_HASH=$COMMIT_HASH \
    MODBOT_USE_ENV=1 \
    MODBOT_DATABASE_HOST=localhost \
    MODBOT_DATABASE_PASSWORD=mariadb_password_mariadb_is_setup_to_ignore_requests_outside_of_docker_network \
    MODBOT_AUTH_TOKEN=SELF_TEST

RUN apk add --update --no-cache mariadb mariadb-client && \
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql && \
    mariadbd-safe --datadir='/var/lib/mysql' & \
    sleep 5 && \
    # Set up the database
    mariadb -e "CREATE DATABASE modbot;" && \
    mariadb -e "CREATE USER 'modbot'@'localhost' IDENTIFIED BY 'mariadb_password_mariadb_is_setup_to_ignore_requests_outside_of_docker_network';" && \
    mariadb -e "GRANT ALL PRIVILEGES ON modbot.* TO 'modbot'@'localhost';" && \
    mariadb -e "FLUSH PRIVILEGES;" && \
    # Sort of a hack to make sure the database is ready before continuing, but it also segfaults because, I don't know.
    #mariadb -u modbot -p mariadb_password_mariadb_is_setup_to_ignore_requests_outside_of_docker_network -h localhost -P 3306 -e "SELECT VERSION();" --verbose || exit 1 && \
    # Node.js
    npm ci && \
    # Self test
    chmod +x /app/docker/test.sh && \
    /app/docker/test.sh || exit 1 && \
    # Clean up the extra files
    rm -rf /app/docker

CMD [ "/bin/ash", "/entrypoint.sh" ]
