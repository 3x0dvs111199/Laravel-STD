FROM nginx:stable-alpine

ARG UID
ARG GID

ENV UID=${UID}
ENV GID=${GID}

# MacOS staff group's GID is 20, same as Alpine's dialout. Remove it to avoid conflicts.
RUN delgroup dialout || true

# Create laravel group and user
RUN addgroup -g ${GID} laravel
RUN adduser -G laravel -D -s /bin/sh -u ${UID} laravel

# Change Nginx user from 'nginx' to 'laravel'
RUN sed -i "s/user  nginx;/user laravel;/g" /etc/nginx/nginx.conf

# Copy Nginx config
COPY ./nginx/default.conf /etc/nginx/conf.d/

# Create working directory
RUN mkdir -p /var/www/html && chown -R laravel:laravel /var/www/html

WORKDIR /var/www/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

