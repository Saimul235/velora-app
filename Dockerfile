FROM php:8.2-apache

# ১. প্রয়োজনীয় সিস্টেম প্যাকেজ ও PHP এক্সটেনশন ইনস্টল
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

# ৪. Composer ডিপেনডেন্সি ইনস্টল
RUN composer install --no-interaction --optimize-autoloader --no-dev

# ৫. Apache Root Directory পরিবর্তন (public ফোল্ডারকে রুট নির্ধারণ)
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/conf-available/*.conf

# ৬. Apache mod_rewrite চালু
RUN a2enmod rewrite

# ৭. Laravel Storage ও Cache ফোল্ডারের সঠিক পারমিশন
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 80
