FROM ubuntu:18.04

WORKDIR /tmp

RUN apt-get update

RUN apt-get install -y software-properties-common && add-apt-repository ppa:maxmind/ppa

RUN apt-get install -y build-essential git libmaxminddb0 libmaxminddb-dev mmdb-bin

# Install prerequisites for Nginx compile
RUN apt-get install -y \
        wget \
        tar \
        libssl-dev \
        git \
        libpcre3-dev \
        zlib1g-dev \
        libgd-dev

RUN mkdir /tmp/nginx
RUN git clone https://github.com/leev/ngx_http_geoip2_module.git /tmp/nginx/ngx_http_geoip2_module

# Download Nginx and Nginx modules source
RUN wget http://nginx.org/download/nginx-1.17.7.tar.gz -O nginx.tar.gz && \
    tar -xzvf nginx.tar.gz -C /tmp/nginx --strip-components=1

# Build Nginx
WORKDIR /tmp/nginx
RUN ./configure \
    --prefix=/nginx/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=root \
    --group=root \
    --with-compat \
    --with-file-aio \
    --with-threads \
    --with-http_addition_module \
    --with-http_auth_request_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_mp4_module \
    --with-http_random_index_module \
    --with-http_realip_module \
    --with-http_secure_link_module \
    --with-http_slice_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_sub_module \
    --with-http_v2_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-stream \
    --with-stream_realip_module \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --add-module=ngx_http_geoip2_module && \
    make && \
    make install

WORKDIR /tmp

RUN touch /run/nginx.pid

RUN mkdir /etc/nginx/sites-enabled && \
    mkdir /etc/nginx/conf.d

RUN mkdir /var/cache/nginx && \
    mkdir /var/cache/nginx/client_temp && \
    mkdir /var/cache/nginx/proxy_temp && \
    mkdir /var/cache/nginx/fastcgi_temp && \
    mkdir /var/cache/nginx/uwsgi_temp && \
    mkdir /var/cache/nginx/scgi_temp

#PORTS
EXPOSE 8080
EXPOSE 8443

COPY nginx.conf /etc/nginx/nginx.conf

USER root

CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
