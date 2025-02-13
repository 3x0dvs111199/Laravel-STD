FROM php:8-fpm-alpine

# Set working directory
WORKDIR /var/www/html

# Install system dependencies
RUN apk add --no-cache \
    autoconf \
    gcc \
    g++ \
    make \
    libzip-dev \
    zip \
    unzip \
    curl \
    shadow

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_mysql zip

# Install Redis using pecl (instead of manual download)
RUN pecl install redis && docker-php-ext-enable redis

# Update PHP-FPM config to run as root (⚠️ Not recommended, but if necessary)
RUN sed -i "s/user = www-data/user = root/g" /usr/local/etc/php-fpm.d/www.conf \
    && sed -i "s/group = www-data/group = root/g" /usr/local/etc/php-fpm.d/www.conf \
    && echo "php_admin_flag[log_errors] = on" >> /usr/local/etc/php-fpm.d/www.conf

# Expose PHP-FPM port
EXPOSE 9000

# Start PHP-FPM
CMD ["php-fpm", "-y", "/usr/local/etc/php-fpm.conf", "-R"]

