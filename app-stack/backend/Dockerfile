FROM php:7.4-fpm

# Set working directory
WORKDIR /var/www

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    # needed for gd
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    # need for development & debug
    iputils-ping \
    mariadb-client

# Install extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-configure pdo_mysql --with-pdo-mysql && \
    docker-php-ext-install gd mysqli pdo_mysql

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# # Add user for laravel application
# RUN groupadd -g 1000 www
# RUN useradd -u 1000 -ms /bin/bash -g www www

# # Copy existing application directory contents
# COPY . /var/www

# # Copy existing application directory permissions
# COPY --chown=www:www . /var/www

# # Change current user to www
# USER www

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]