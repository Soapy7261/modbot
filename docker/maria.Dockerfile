FROM node:20-alpine

ARG COMMIT_HASH

# Set up files
WORKDIR /app
COPY . .

# Install dependencies
ENV NODE_ENV=production

#Set MariaDB
ENV MYSQL_ROOT_PASSWORD=root_password \
    MYSQL_DATABASE=modbot \
    MYSQL_USER=modbot \
    MYSQL_PASSWORD=password

RUN apk add --update --no-cache mariadb

RUN mkdir -p /run/mysqld /var/lib/mysql && \
    chmod 777 /run/mysqld && \
    mysql_install_db --user=$(whoami) --datadir=/var/lib/mysql

# Node.js
RUN npm ci

# Environment
ENV MODBOT_COMMIT_HASH=$COMMIT_HASH
ENV MODBOT_USE_ENV=1

COPY ./entrypoint.sh /entrypoint.sh
COPY ./test.sh /test.sh

# Test
RUN /test.sh || exit 1 \
    && rm /test.sh

# Start

CMD [ "/bin/ash", "/entrypoint.sh"]
