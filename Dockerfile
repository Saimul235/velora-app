FROM php:8.2-apache

# Composer ইনস্টল করার নিয়ম
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    curl

RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Composer কপি
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY . .

# Composer Dependencies ইনস্টল
RUN composer install --no-interaction --optimize-autoloader --no-dev

# Apache Root Directory পরিবর্তন
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/conf-available/*.conf

RUN a2enmod rewrite

# Storage ফোল্ডারের পারমিশন দেওয়া
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 80
