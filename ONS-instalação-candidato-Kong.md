# Referência instalação Kong

Instalação (versão 2.3.x) 

## Referências

Principal: https://docs.konghq.com/gateway-oss/

Instalação: https://docs.konghq.com/install/docker/

Pré requisitos: 

Compatibilidade: 

## Básico

- Base: PostgreSQL e Cassandra

## Ferramentas

- Curl ou script python para automação
- decK (ferramenta de sincronização)

## Aplicações

- Gateway
- Kong Manager

Open Source
- Konga (Aplicação administrativa-alternativa antes do Kong Manager na versão 2.3)
- Wicked (Portal do Desenvolvedor)

## Modelo de instalação
- Docker, Kubernetes (Enterprise)

## Conceitos úteis

- Serviços contém rotas
- Consumers possuem credenciais

- Kong não possui noção de ambientes (ex: homologação e produção)

### Glossário

*Upstream server*: serviço destino

### Consumer

Mapeamento de uma credencial (ex: JWT) em um *role* do kong. Podemos associar este role a uma *white list* ou *black list* por exemplo (ACL).

### Service

Configura um *endpoint* para acesso ao *upstream server* (host). Os *services* terão rotas (*routes*).

### Route (rota)

Mapeamento no service que permite rotear (entre outros) uma url para um serviço

### Plugin

Extensibilidade do Kong, porém também é a maneira que os recursos dele são implementados (ex: validação de JWT, ACL)

# Proposta de instalação

> Durante a execução da PoC, o portal de gerenciamento do Kong passou a ser open-sorce também, de maneira que o Konga não é mais necessário, pois possuem a mesma funcionalidade.

## Docker

Existe a possibilidade de instalar sem banco de dados mas não funcionam muitos recursos, não utilizaremos.

```bash
# Personalização da instalação 
```

```bash
# nota: no meu teste em lab fiz com --link do docker que é obsoleto. neste fluxo vou usar as networks que é o recomendado
# em ambos os casos os containers ficam acessíveis de outros containers pelo nome (o que estiver em --name na criação)
docker network create kong-net
# depois de criado é possivel conectar a rede:
docker network connect kong-net <nome ou id do container>

# inicia a base postgre (TODO: ajustar estes defaults)
docker run -d --name kong-database -p 5432:5432 --network kong-net -e "POSTGRES_USER=kong" -e "POSTGRES_DB=kong" -e "POSTGRES_HOST_AUTH_METHOD=trust" postgres:9.6

# prepara o Postgre para o Kong 
docker run --rm --network kong-net -e "KONG_DATABASE=postgres" -e "KONG_PG_HOST=kong-database" kong kong migrations bootstrap
# jeito velho: --link kong-database:kong-database

# cria container com a configuração padrão
docker run -d --name kong --network kong-net -e "KONG_DATABASE=postgres" -e "KONG_PG_HOST=kong-database" -e "KONG_PROXY_ACCESS_LOG=/dev/stdout" -e "KONG_ADMIN_ACCESS_LOG=/dev/stdout" -e "KONG_PROXY_ERROR_LOG=/dev/stderr" -e "KONG_ADMIN_ERROR_LOG=/dev/stderr" -e "KONG_ADMIN_LISTEN=0.0.0.0:8001, 0.0.0.0:8444 ssl" -p 8000:8000 -p 8443:8443 -p 8001:8001 -p 8444:8444 kong
# jeito velho: --link kong-database:kong-database

# Konga
docker run -p 1337:1337 --network kong-net --name konga -e TOKEN_SECRET=kongakongakonga pantsel/konga

```

## Manual

# Integração

Passos a serem executados

- Recuperar arquivos para integração (contrato, regras, etc)
- Obter usuário/senha ou token de acesso ao fluxo administrativo
- Consultar o ambiente (pré-validação)
- Executar o passo de publicação do contrato
- Executar o passo de publicação de regras (se necessário)
- Reiniciar o serviço (se necessário)

## Configuração

### Portas
- 8000 - Api Gateway HTTP (Serviço)
- 8443 - Api Gateway HTTPS (Serviço)
- 8001 - Administrativa HTTP
- 8444 - Administrativa HTTPS

### Certificados

Por padrão o container docker do Kong usa certificados *self signed* que são utilizáveis em ambiente de teste, e não são um problema no momento da PoC.

No futuro será necessário endereçar os certificados dos endpoints HTTPS (Serviço e Admin) com certificados válidos (conforme a necessidade).

### Ferramental

Integração pelo Kong pode ser feita de duas maneiras:

- API REST (podemos chamar via curl ou qualquer ferramenta que possa executar chamadas HTTP)
- decK (ferramenta da Kong)

## Interface 

Até a versão 2.2 Kong Community não existia uma oficial disponível (gratuita), e instalávamos com frequência o Konga que é *open source*. Na versão 2.3 o portal Kong Manager passou também a ser *open source* e não há mais a necessidade do Konga.

## decK

> No momento de construção da PoC existe um bug que impede o uso do decK na versão *free*. Existe um [ticket aberto](https://github.com/Kong/deck/issues/274), mas não temos visibilidade de quando poderemos usá-lo.

## API REST - curl (linha de comando ou *shell script*)

### Instação básica da ferramenta

Estou considerando um fluxo via curl, mas via python também é possível e mais flexível se houver a necessidade de processamento das respostas e tratamento menos genérico

```bash
curl -X <método HTTP> <url>
```

### Autorização

O *endpoint* administrativo não possui nenhuma segurança por padrão. Está aberto e por isso é importante adicionar uma camada de segurança. 

O próprio Kong pode ser utilizado, expondo via o serviço administrativo via alguma rota, e adicionando credenciais e outras validações. Nos exemplos a seguir consideramos que não há nenhuma autorização adicionada.

### Publicação dos artefatos pré api

#### Consumers

Teremos um repositório com as configurações como abaixo. Este formato é só um exemplo, mais informações podem ser necessárias.

```properties
[consumer1]
chave_publica_rsa=BEGIN PUBLIC KEY\nABCDFGH......
nome=Consumer Simples
kid=12345
issuer=http://issuer-xyz.ons.br/....

[consumer2]
chave_publica_rsa=BEGIN PUBLIC KEY\n123456......
nome=Consumer Complexo
kid=45678
issuer=http://issuer-ghi.ons.br/....
```

As mudanças serão aplicadas na API REST
```bash
# consulta se o consumer já foi publicado
curl -X GET http://kong:8001/consumers/<nome do consumer>

# quando não existe volta http 404 

# enviar se não existir ou se mudou
curl --location --request POST 'http://kong:8001/consumers' \
--header 'Content-Type: application/json' \
--data-raw '{
    "username": "user_backoffice"
}'
# resposta JSON
{
    "custom_id": null,
    "created_at": 1612829611,
    "id": "aae850a1-f27d-42a7-a78f-4333e115525d",
    "tags": null,
    "username": "user_backoffice"
}

# adiciona a credencial JWT
curl 'http://kong:8001/consumers/aae850a1-f27d-42a7-a78f-4333e115525d/jwt' \
  -H 'authorization: eyJhb....SNFxTLU' \
  -H 'Content-Type: application/json;charset=UTF-8' \
  --data-raw '{
      "key":"https://poptst.ons.org.br/ons.pop.federation/backoffice",
      "algorithm":"RS256",
      "rsa_public_key":"-----BEGIN PUBLIC KEY-----\nMIIBI....IDAQAB\n-----END PUBLIC KEY-----",
      "token":"eyJhb....SNFxTLU"}' 
```

### Publicação dos artefatos da API

#### Services

##### Publicação básica de uma API **no gateway**

No caso da importação de arquivos swagger/openapi seria importante validar estruturalmente o arquivo antes de processar. O arquivo pode ter sido criado manualmente ou ajustado por ferramental, portanto é válido a pré-validação. Não entendemos ser parte do fluxo de publicação do gateway, mas da geração do contrato

Ser idempotente seria recurso interessante. Neste caso seria recuperar primeiro a configuração, avaliar se houveram mudanças e só aplicar se houver.

##### Consultar/Atualizar o serviço no gateway

AVALIAR: Da onde vem a informação dos services. O swagger/oas terá todos os hosts ? O campo servers só existe em oas. 

```bash
# verifica se já existe
#curl -X GET http://kong:8001/services/<nome do serviço>
curl -X GET http://kong:8001/services/servico-exemplo

# devolve HTTP 200 se já existir, ou 404 se não existir

# enviar se não existir
  curl 'http://kong:8001/services/' \
  -H 'authorization: Bearer eyJhb...TLU' \
  -H 'Content-Type: application/json;charset=UTF-8' \
  --data-raw '{
      "name":"servico-exemplo",
      "port":null,
      "retries":5,
      "connect_timeout":60000,
      "write_timeout":60000,
      "read_timeout":60000,
      "tags":[],
      "url":"http://servico-exemplo.com:8080/exemplo",
      "token":"eyJhb...TLU"}'
```

##### Consultar/Atualizar as rotas no gateway

A informação das rotas extraimos do swagger/oas

```bash
# verifica se já existe
# curl -X GET http://kong:8001/routes/<id da rota>
# ou
# curl -X GET http://kong:8001/services/<nome ou id do serviço>/routes

# enviar se não existir
curl 'http://kong:8001/routes/' \
  -H 'Content-Type: application/json;charset=UTF-8' \
  --data-raw '{
      "name":null,
      "hosts":null,
      "protocols":["http","https"],
      "methods":null,
      "paths":["/rota1","/rota2"],
      "headers":null,
      "path_handling":"v1",
      "strip_path":true,
      "preserve_host":false,
      "https_redirect_status_code":426,
      "regex_priority":0,
      "snis":null,
      "sources":null,
      "destinations":null,
      "service":{
          "id":"8cb9fbf3-db7f-4551-9968-b96d142339b8"
       }
    }' 
```

### Importação do projeto do portal do desenvolvedor

O portal funciona como um site integrado dentro da ferramenta. É possível [enviar arquivos via interface REST](https://docs.konghq.com/enterprise/2.3.x/developer-portal/files-api/), ou usar o ferramental de desenvolvimento da Kong (ex: [Imsomnia designer](https://insomnia.rest/))

Este recurso é licenciado e não evoluímos a execução prática, mas da documentação entendemos que o modelo via chamadas REST deve atender a publicação do conteúdo dos contratos e documentos.

# Integrações ONS

## Integração com POP

* Publicar as chaves
* Integrar nas apis a validação (consumers->routes->services)
* (Opcional) validar os claims/scopes

No Kong a publicação das chaves JWT é feita como credencial JWT do consumer. Por isso já na configuração do consumer este trabalho já estará concluído.

### Chave pública do ambiente de teste

Chave pública para validação do ambiente de teste
```
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5GA6ikNtJJHTp89PZ4L2
R5SHYzFkc8h3zMp8Yv/5bsCj6DlCcARepX4wR6Av2MQsPid85b65STWUUm+XQI2x
QHkyDV6Ohu3TYLzk1Sbt9jViRrI8EIa91Nzhz24vjGNgmOn7I0ogn1GMjZ0KPTAm
jf8w6vlrJ2UwWg4g65g5643f+NqbYlN1xI9h09Un6pouroaG4UqVeqGjt9HRCHG3
yrKIJYBMOC9/hjanDbPrGCngC4ADT39OUjrNiZh0/L1h6hI5rhfXEKJOV+BEc4aH
bUa60rG2gXaet8RU4cR4xN+dnBbNpNbJtiFw6YAf6lcw1hcCaQpR5+1dXfOIag7k
BQIDAQAB
-----END PUBLIC KEY-----
```

