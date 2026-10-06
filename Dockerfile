FROM php:8.2-apache

# Mod_rewrite এনাবল করা (Laravel Routing-এর জন্য)
RUN a2enmod rewrite

# Document Root সেট করা public ফোল্ডারে
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/conf-available/*.conf

# প্রজেক্টের সব ফাইল কপি করা
COPY . /var/www/html

WORKDIR /var/www/html

EXPOSE 80

