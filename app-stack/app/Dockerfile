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

# Create a user and group on the container and use this user to run container
# then assign appropriate permission for this GID on host
RUN groupadd -g 2001 mygroup
RUN adduser --disabled-password --gecos "" --force-badname --ingroup mygroup myuser

# Set file permission for volumes on host
# chown -R root:2001 /data/myvolume
# chmod -R 775 /data/myvolume
# chmod g+s /data/myvolume

# Change current user to myuser
USER myuser

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]