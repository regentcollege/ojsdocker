# Set the base image for subsequent instructions
FROM php:8.1-apache

# Install dependencies
RUN apt-get update && pecl install redis && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl \
    default-mysql-client \
    libzip-dev \
    libonig-dev \
    zlib1g-dev \
    libicu-dev \
    g++ \
    supervisor \
    nodejs \
    npm

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions
RUN docker-php-ext-install mysqli pdo_mysql zip exif pcntl opcache bcmath
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install gd && docker-php-ext-enable opcache redis
RUN docker-php-ext-configure intl
RUN docker-php-ext-install intl

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

COPY ./config/ojs.conf /etc/apache2/sites-available/laravel.conf
COPY ./config/ojs.php.ini /usr/local/etc/php/conf.d/laravel.php.ini
COPY ./config/ojs_supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ojs_start.sh /usr/local/bin/start

RUN mkdir -p /var/www/ojs/current

RUN a2ensite laravel.conf && a2dissite 000-default.conf && chmod u+x /usr/local/bin/start && a2enmod rewrite
	
# Setup working directory
WORKDIR /var/www/ojs

CMD ["/usr/local/bin/start"]
