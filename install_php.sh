#!/bin/sh

cd /tmp
curl -O http://php.net/distributions/php-5.6.9.tar.gz
tar zxvf php-5.6.9.tar.gz
cd php-5.6.9
curl https://raw.githubusercontent.com/tenderlove/phuby/ed41daece6a9191a0240dae9c9b610bb06d61177/configure.diff | patch
./configure --enable-debug \
            --enable-embed \
            --disable-cli \
            --with-mysql=/usr/local \
            --with-mysqli=/usr/local/bin/mysql_config \
            --with-mysql-sock=/tmp/mysql.sock \
            --prefix=/tmp/omg

make
find . -path '*.libs*' -name *.o -execdir sh -c 'cp * ../' \;
make
make install
