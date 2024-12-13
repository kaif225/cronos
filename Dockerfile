FROM serversideup/php:8.4-cli
RUN install-php-extensions intl gd xsl pcov && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    composer config --no-plugins allow-plugins.phpstan/extension-installer true && \
    composer install --no-interaction --prefer-dist 
