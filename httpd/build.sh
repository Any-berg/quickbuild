#!/usr/bin/env bash

# make sure to work on the right directory and not delete/overwrite wrong things
cd "$( dirname "${BASH_SOURCE[0]}" )"

# download all needed files here because in Docker you'd have certificate issues
rm -f Dockerfile httpd-foreground *_amd64.deb
wget https://raw.githubusercontent.com/docker-library/httpd/master/2.4/Dockerfile
wget https://raw.githubusercontent.com/docker-library/httpd/master/2.4/httpd-foreground
wget https://github.com/zmartzone/mod_auth_openidc/releases/download/v2.3.11/libapache2-mod-auth-openidc_2.3.11-1.stretch+1_amd64.deb
wget https://github.com/zmartzone/mod_auth_openidc/releases/download/v2.3.11/libcjose0_0.6.1.4-1.stretch+1_amd64.deb

# make downloaded httpd wrapper script executable
chmod a+x httpd-foreground

# use stretch parent: mod_auth_openidc requires libcurl3, not found in buster
sed -i \
    -e 's/^\(FROM debian:\)buster/\1stretch/' \
    -e 's/\(libbrotli-dev\)/#\1/' \
    Dockerfile

# insert code to set up mod_auth_openidc, but don't make httpd load it yet
cat <<'EOF' > snippet
COPY libcjose0_0.6.1.4-1.stretch+1_amd64.deb .
COPY libapache2-mod-auth-openidc_2.3.11-1.stretch+1_amd64.deb .

RUN set -eux; \
        dpkg -i libcjose0_0.6.1.4-1.stretch+1_amd64.deb; \
        apt-get update; \
        apt-get install -y --no-install-recommends \
                libhiredis0.13 \
                apache2-bin \
                ca-certificates \
        ; \
        dpkg -i libapache2-mod-auth-openidc_2.3.11-1.stretch+1_amd64.deb; \
        rm *.deb; \
        cp /usr/lib/apache2/modules/mod_auth_openidc.so modules/; \
        echo "#LoadModule auth_openidc_module modules/mod_auth_openidc.so" >> conf/httpd.conf
EOF
sed -Ei '/^COPY httpd-foreground/r snippet' Dockerfile
rm snippet

# specify workspace files that Dockerfile can COPY
printf "%s\n" \
    "**/*" \
    "!httpd-foreground" \
    "!*.stretch?1_amd64.deb" \
    > .dockerignore

# build docker image
httpd_version=$(grep "ENV HTTPD_VERSION" Dockerfile | cut -d ' ' -f 3 | xargs echo -n)
docker build -t custom/httpd:${httpd_version}-openidc .

# https://medium.com/better-programming/how-to-version-your-docker-images-1d5c577ebf54

