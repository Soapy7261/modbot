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
    mariadb -e "CREATE USER 'modbot'@'localhost' IDENTIFIED BY 'password';" && \
    mariadb -e "GRANT ALL PRIVILEGES ON modbot.* TO 'modbot'@'localhost';" && \
    mariadb -e "FLUSH PRIVILEGES;" 
    #&& \
    #mysql -u modbot -p password -h localhost modbot || exit 1
# Node.js
RUN npm ci

# Environment
ENV MODBOT_COMMIT_HASH=$COMMIT_HASH
ENV MODBOT_USE_ENV=1

COPY ./docker/entrypoint.sh /entrypoint.sh
COPY ./docker/test.sh /test.sh

# Test
COPY ./docker/test.config.json /app/config.json
RUN chmod +x /test.sh && \
    /test.sh || exit 1 && \
    rm /test.sh && \
    rm /app/config.json

# Start

CMD [ "/bin/ash", "/entrypoint.sh"]
