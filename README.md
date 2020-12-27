# php 8.0 fpm image for php development together with httpd or nginx

Example on how to use this with docker-compose

```yaml
version: '3.7'
services:
  php:
    image: mach25/php74fpm
    volumes:
      - ./html:/var/www/html:z
    networks:
      - world
  web:
    image: httpd:latest
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./html/:/var/www/html/:z
      - ./conf/:/usr/local/apache2/conf/:z
    links:
      - memcached
      - mariadb
      - php
      - mailhog
    networks:
      world:
        aliases:
          - "mywebapp.local"
  mariadb:
    image: mariadb:latest
    restart: always
    command: ["mysqld", "--character-set-server=utf8mb4", "--collation-server=utf8mb4_unicode_ci",  "--innodb-large-prefix=1",  "--innodb-file-format=barracuda",  "--innodb-file-per-table=1",  "--innodb-buffer-pool-size=20G",  "--max-allowed-packet=1024M",  "--max-heap-table-size=512M",  "--sort-buffer-size=128M",  "--join-buffer-size=128M",  "--thread-cache-size=32",  "--query-cache-size=2048M",  "--query-cache-limit=128M"]
    ports:
      - "3306:3306"
    environment:
      MYSQL_ROOT_PASSWORD: somerootpassword
      MYSQL_DATABASE: adatabasename
    volumes:
      - db-volume:/var/lib/mysql
      - ./db:/docker-entrypoint-initdb.d:z
    networks:
      - world
volumes:
  db-volume:
networks:
  world:
```
