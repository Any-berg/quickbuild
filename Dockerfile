# parent image is based on httpd:2.4.39 (see "httpd/build.sh" for details)
FROM custom/httpd:2.4.39-openidc

# provide at least first 3 values (from your OIDC provider) in an ".env" file
#ENV OIDCProvider     
ENV OIDCClientID          _
ENV OIDCClientSecret      _

#ENV OIDCCryptoPassphrase
ENV emailPattern          ^[^@]+@.+$
ENV serverAdmin           admin@your-domain.com

COPY reverse-proxy.conf conf/extra/httpd-vhosts.conf

# enable virtual host and all the modules that it needs
RUN sed -i \
        -e 's/^#\(Include .*httpd-vhosts.conf\)/\1/' \
        -e 's/^#\(LoadModule .*mod_proxy_http.so\)/\1/' \
        -e 's/^#\(LoadModule .*mod_proxy.so\)/\1/' \
        -e 's/^#\(LoadModule .*mod_xml2enc.so\)/\1/' \
        -e 's/^#\(LoadModule .*mod_substitute.so\)/\1/' \
        -e 's/^#\(LoadModule .*mod_deflate.so\)/\1/' \
        -e 's/^#\(LoadModule .*mod_auth_openidc.so\)/\1/' \
        conf/httpd.conf;
