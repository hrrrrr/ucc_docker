FROM php:8.2-fpm

ARG user="ucc"
ARG uid="1000"
WORKDIR /root
# Install apt-get
RUN apt-get update && apt-get install -y \
        git \
        vim \
        curl \
        zip \
        unzip \
        nodejs \
        npm 
RUN apt-get update && apt-get install -y default-libmysqlclient-dev && docker-php-ext-install mysqli pdo pdo_mysql

RUN echo 'memory_limit = 2048M' >> /usr/local/etc/php/conf.d/docker-php-memlimit.ini

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php

RUN mv composer.phar /usr/bin/composer

RUN apt-get install -y zlib1g-dev && apt-get install -y libzip-dev
RUN docker-php-ext-install zip

RUN export COMPOSER_ALLOW_SUPERUSER=1
RUN echo "export COMPOSER_ALLOW_SUPERUSER=1" >> ~/.bashrc


# User add
RUN useradd -G www-data,root -u $uid -d /home/$user $user

RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

# Install laravel
RUN composer global require laravel/installer
RUN composer global require laravel/laravel
# RUN ["/bin/bash", "-c", "echo PATH=$PATH:~/.composer/vendor/bin/ >> ~/.bashrc"]
# RUN ["/bin/bash", "-c", "source ~/.bashrc"]
RUN composer create-project laravel/laravel /home/$user/app

# RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli
# RUN docker-php-ext-install mysqli pdo pdo_mysql
RUN pecl install redis && docker-php-ext-enable redis

# Work dir
WORKDIR /home/$user/app
USER $user
EXPOSE 9000
CMD ["php-fpm"]
# permission
# RUN chmod -R 775 /var/www/html/storage
# RUN chmod -R 775 /var/www/html/bootstrap/cache
