#!/bin/bash
echo "Starting installing..."

# Instalação com docker Ubuntu Focal 20.04
apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common gnupg2 vim
apt-get install -y ifupdown  debootstrap zfs-fuse build-essential ubuntu-drivers-common net-tools

# Caso o Docker não esteja instalado docker:
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable edge"

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io ifupdown aufs-tools debootstrap zfs-fuse nfs-kernel-server

# Deixar o docker ativo na inicialização
systemctl enable docker.service

# Não hibernar:
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

# Pull kong-ee image 
docker pull kong-docker-kong-gateway-docker.bintray.io/kong-enterprise-edition:2.3.2.0-alpine

# Create network kong
docker network create kong-ee-net

# inicia a base postgre (TODO: ajustar estes defaults)
docker run -d --name kong-database -p 5432:5432 --network kong-net -e "POSTGRES_USER=kong" -e "POSTGRES_DB=kong" -e "POSTGRES_HOST_AUTH_METHOD=trust" postgres:9.6

# prepara o Postgre para o Kong 
docker run --rm --network kong-net -e "KONG_DATABASE=postgres" -e "KONG_PG_HOST=kong-database" kong kong migrations bootstrap
# jeito velho: --link kong-database:kong-database

# cria container com a configuração padrão
docker run -d --name kong --network kong-net -e "KONG_DATABASE=postgres" -e "KONG_PG_HOST=kong-database" -e "KONG_PROXY_ACCESS_LOG=/dev/stdout" -e "KONG_ADMIN_ACCESS_LOG=/dev/stdout" -e "KONG_PROXY_ERROR_LOG=/dev/stderr" -e "KONG_ADMIN_ERROR_LOG=/dev/stderr" -e "KONG_ADMIN_LISTEN=0.0.0.0:8001, 0.0.0.0:8444 ssl" -p 8000:8000 -p 8443:8443 -p 8001:8001 -p 8444:8444 kong
# jeito velho: --link kong-database:kong-database

# Konga
#docker run -d -p 1337:1337 --network kong-net --name konga -e TOKEN_SECRET=kongakongakonga pantsel/konga


