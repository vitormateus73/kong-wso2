#!/bin/bash
echo "### Uploading API project ###"
#recebe como argumento o local da pasta do projeto, o ambiente a ser feito o deploy, senha de acesso ao ambiente requerido e versão 

while getopts ":p:e:s:v:" opt; do
  case $opt in
    p) project="$OPTARG"
    ;;
    e) enviroment="$OPTARG"
    ;;
    s) senha="$OPTARG"
    ;;
    v) versao="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

# faz login no ambiente
echo "### Logando no ambiente $enviroment ###"
apictl login $enviroment -u admin --insecure --verbose --password $senha

#publica o projeto no api gateway
echo "### Publicando projeto $project no ambiente $enviroment ###"
apictl import-api -f $project/ -e $enviroment -k --update

# Altera o status para 'Prototype'
echo "### Alterando status da api para Prototype ###"
apictl change-status api -a "Deploy as a Prototype" -n $project -e lab -v $versao -k

# Altera o status para publicado
echo "### Alterando status da api para Publish ###"
apictl change-status api -a Publish -n $project -e $enviroment -v $versao -k