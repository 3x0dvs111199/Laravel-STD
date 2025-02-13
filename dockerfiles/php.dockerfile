FROM php:8-fpm-alpine

ARG UID
ARG GID

ENV UID=${UID}
ENV GID=${GID}

# Install required dependencies
RUN apk add --no-cache \
    autoconf \
    gcc \
    g++ \
    make \
    curl \
    libpng-dev \
    libjpeg-turbo-dev \
    libwebp-dev \
    freetype-dev \
    libzip-dev \
    zip \
    unzip \
    bash \
    shadow

# Set working directory
WORKDIR /var/www/html

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Remove conflicting group (MacOS staff GID = 20, Alpine dialout GID = 20)
RUN delgroup dialout || true

# Create laravel user & group
RUN addgroup -g ${GID} laravel && adduser -G laravel -D -s /bin/sh -u ${UID} laravel

# Update PHP-FPM config to use 'laravel' instead of 'www-data'
RUN sed -i "s/user = www-data/user = laravel/g" /usr/local/etc/php-fpm.d/www.conf \
    && sed -i "s/group = www-data/group = laravel/g" /usr/local/etc/php-fpm.d/www.conf \
    && echo "php_admin_flag[log_errors] = on" >> /usr/local/etc/php-fpm.d/www.conf

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_mysql zip gd

# Install Redis using pecl instead of manual download
RUN pecl install redis && docker-php-ext-enable redis

# Ensure Laravel has correct ownership
RUN chown -R laravel:laravel /var/www/html

# Expose PHP-FPM port
EXPOSE 9000

CMD ["php-fpm", "-y", "/usr/local/etc/php-fpm.conf", "-R"]

