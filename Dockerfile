FROM php:8.2-apache

# ১. প্রয়োজনীয় প্যাকেজ ও PHP এক্সটেনশন ইনস্টল
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    curl \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# ২. Composer ইনস্টল
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# ৩. প্রজেক্ট ফাইল কপি
COPY . /var/www/html

# ৪. মেমোরি লিমিট তুলে Composer নিরাপদভাবে ইনস্টল
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install --no-interaction --optimize-autoloader --no-dev --ignore-platform-reqs

# ৫. Apache Root Directory-কে public ফোল্ডারে সেট করা
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/conf-available/*.conf

# Mod Rewrite এনাবল
RUN a2enmod rewrite

# Storage ও Cache ফোল্ডারের পারমিশন
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 80
