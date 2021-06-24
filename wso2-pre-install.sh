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

# cria container com a configuração padrão
docker run -d -p 8280:8280 -p 8243:8243 -p 9443:9443 --name api-manager wso2/wso2am:3.2.0

# recupera o arquivo padrão de configuração
docker exec -it api-manager /bin/bash -c "cat /home/wso2carbon/wso2am-3.2.0/repository/conf/deployment.toml" > deployment.toml

# não utilizado no ambiente da POC
# troca todas as referências à localhost pelo IP (ou o nome do host)
#cp deployment.toml deployment.toml.backup
#sed -i "s/localhost/192.168.1.33/" deployment.toml
# outros ajustes poderiam ser feitos aqui....
#chmod o+r deployment.toml
# reexecuta com a configuração
#docker run -it -p 8280:8280 -p 8243:8243 -p 9443:9443 --name api-manager --volume /root/deployment.toml:/home/wso2carbon/wso2am-3.2.0/repository/conf/deployment.toml -d wso2/wso2am:3.2.0

# baixa do site do WSO2
wget https://apim.docs.wso2.com/en/3.2.0/assets/attachments/learn/api-controller/apictl-3.2.1-linux-x64.tar.gz
#descompacta
tar xvzf apictl-3.2.1-linux-x64.tar.gz
#adiciona comando ao PATH
mv apictl/apictl /usr/local/bin
# cria arquivo com a senha do admin (1x) - melhor seria criar com aplicação ou de maneira que apareça no histórico do bash
echo -n "admin" > password_lab
