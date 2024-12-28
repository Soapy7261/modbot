FROM node:20-alpine

ARG COMMIT_HASH

# Set up files
WORKDIR /app
COPY . .

# Install dependencies
ENV NODE_ENV=production

#Set MariaDB
ENV MARIADB_ROOT_PASSWORD=root_password \
    MARIADB_DATABASE=modbot \
    MARIADB_USER=modbot \
    MARIADB_PASSWORD=password

RUN apk add --update --no-cache mariadb

RUN mkdir -p /run/mysqld /var/lib/mysql && \
    chmod 777 /run/mysqld && \
    mariadb-install-db --user=root --datadir=/var/lib/mysql

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
