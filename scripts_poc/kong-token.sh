#!/bin/bash

# chamada sem o token falha....
echo "chamando sem token"
curl --location --request GET 'http://10.24.1.207:8000/echo/get'

echo "chamando com token"
curl --location --request GET 'http://10.24.1.207:8000/echo/get' --header "Authorization: Bearer $(./pop-obtem-token.sh)"
