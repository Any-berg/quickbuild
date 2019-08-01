#!/usr/bin/env bash

# make sure to work on the right directory
cd "$(dirname "${BASH_SOURCE[0]}")"

HOSTIP=`ip -4 addr show scope global dev eth0 | grep inet | awk '{print \$2}' | cut -d / -f 1`

docker stop "$(docker container ls | grep qb-sso | cut -d' ' -f1)" 2>/dev/null

docker run \
    --add-host=docker:$HOSTIP \
    --env HOSTIP=$HOSTIP \
    $([ -f .env ] && echo --env-file ./.env) \
    --env OIDCCryptoPassphrase=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '') \
    --publish 80:80 \
    --detach \
    qb-sso

rm -fv .env

#https://docs.docker.com/engine/reference/commandline/run/
    #set-environment-variables--e---env---env-file
    #add-entries-to-container-hosts-file---add-host
    #publish-or-expose-port--p---expose
#https://unix.stackexchange.com/questions/230673/how-to-generate-a-random-string
