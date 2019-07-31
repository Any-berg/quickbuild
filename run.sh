#!/usr/bin/env bash

if [ ! -f .env ]; then
    echo "\
# missing '.env': get values for first three from your OIDC provider
OIDCProvider=
OIDCClientID=
OIDCClientSecret=

#OIDCCryptoPassphrase=<RANDOMLY_GENERATED_STRING>
#emailPattern=^[^@]+@.+$"
    exit 1
fi

HOSTIP=`ip -4 addr show scope global dev eth0 | grep inet | awk '{print \$2}' | cut -d / -f 1`

docker run \
    --add-host=docker:$HOSTIP \
    --env HOSTIP=$HOSTIP \
    --env-file ./.env \
    --env OIDCCryptoPassphrase=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '') \
    --publish 80:80 \
    qb-sso

#https://docs.docker.com/engine/reference/commandline/run/
    #set-environment-variables--e---env---env-file
    #add-entries-to-container-hosts-file---add-host
    #publish-or-expose-port--p---expose
#https://unix.stackexchange.com/questions/230673/how-to-generate-a-random-string
