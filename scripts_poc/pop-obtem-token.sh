#!/bin/bash

# chamada para recuperar o token do POP
token=$(curl --location --request POST 'https://poptst.ons.org.br/ons.pop.federation/oauth2/token' \
    --header 'Origin: http://local.ons.org.br' \
    --header 'Content-Type: application/x-www-form-urlencoded' \
    --data-urlencode 'client_id=SACT' \
    --data-urlencode 'grant_type=password' \
    --data-urlencode 'username=ons\_servicepopteste' \
    --data-urlencode 'password=76x$ixWpMF33' | jq -r '.access_token')

echo $token
