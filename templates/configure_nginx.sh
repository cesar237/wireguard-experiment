#! /usr/bin/bash

cd /tmp

# Compile nginx from source
# Download Nginx and RTMP module
rm -rf nginx-1.22.1 nginx-rtmp-module-master
wget http://nginx.org/download/nginx-1.22.1.tar.gz
wget https://github.com/arut/nginx-rtmp-module/archive/master.zip
tar -xf nginx-1.22.1.tar.gz
unzip master.zip
rm nginx-1.22.1.tar.gz master.zip


# Compile Nginx with RTMP module
cd nginx-1.22.1
./configure \
    --sbin-path=/usr/bin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --with-http_ssl_module \
    --add-module=../nginx-rtmp-module-master
make -j `nproc`
sudo make install
cd /tmp

# Move videos to be streamed
rm -rf /var/www/html/dash /var/www/html/hls /tmp/scripts/dash scripts/hls
cd /tmp/scripts
unzip dash-video.zip
unzip hls-video.zip
mv dash /var/www/html
mv hls /var/www/html

# Restart nginx with new configuration
killall nginx
/usr/bin/nginx
