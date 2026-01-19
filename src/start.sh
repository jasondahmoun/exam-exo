#!/bin/sh
set -e

AUTOINDEX=${AUTOINDEX:-off}
DB_NAME=${DB_NAME:-jasonbd}
DB_USER=${DB_USER:-jasonuser}
DB_PASS=${DB_PASS:-jasonmdp}
DB_ROOT_PASS=${DB_ROOT_PASS:-rootpass}

if [ "$AUTOINDEX" = "on" ]; then
  sed -i 's/__AUTOINDEX__/on/g' /etc/nginx/sites-available/default
else
  sed -i 's/__AUTOINDEX__/off/g' /etc/nginx/sites-available/default
fi

mkdir -p /var/run/mysqld
chown -R mysql:mysql /var/run/mysqld

mysqld_safe --datadir=/var/lib/mysql --socket=/var/run/mysqld/mysqld.sock &

MYSQL="mysql --defaults-extra-file=/etc/mysql/debian.cnf --protocol=socket --socket=/var/run/mysqld/mysqld.sock"
until $MYSQL -e "SELECT 1" >/dev/null 2>&1; do
  sleep 1
done

$MYSQL <<SQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
SQL

cat > /var/www/html/index.php <<'PHP'
<?php
echo "<h1>Exam docker wordpress</h1>";
echo "<ul>";
echo "<li><a href='/wordpress/'>WordPress</a></li>";
echo "<li><a href='/phpmyadmin/'>phpMyAdmin</a></li>";
echo "<li><a href='/files/'>Index des fichiers</a></li>";
echo "</ul>";
PHP

chown www-data:www-data /var/www/html/index.php

service php7.4-fpm start
nginx -g "daemon off;"