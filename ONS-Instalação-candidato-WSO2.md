# Referência instalação WSO2

Instalação (versão 3.2.0) - 22/12/2020

## Referências

Pré requisitos: https://apim.docs.wso2.com/en/latest/install-and-setup/install/installation-prerequisites/

Compatibilidade: https://apim.docs.wso2.com/en/latest/install-and-setup/setup/reference/product-compatibility/#tested-operating-systems-and-jdks

## Básico

- JDK 8 ou 11 (testado contra a OpenJDK)
- Base: MySQL (5.7, 8), Oracle (12c, 19c), Microsoft SQL Server 2017, PostgreSQL 10
- Apache ANT ??

## Ferramentas (requisitos)

- Python 3 (testado, 2 talvez funcione)
- nginx ou *Simple HTTP Server* do python

## Arquivos

Versão mínima: https://github.com/wso2/product-apim/releases/download/v3.2.0/wso2am-3.2.0.zip

Versão com pacote de analytics: https://github.com/wso2/product-apim/releases/download/v3.2.0/wso2am-analytics-3.2.0.zip

## Modelo de instalação
- Existem pacotes Windows (msi), Linux gerenciado (yum, apt), Linux pacote (deb, rpm)
- Docker, Docker Compose, Kubernetes, Helm 
- Tem Ansible, Puppet

### Base de dados

- PostgreSQL tem suporte na aplicação e tem disponibilidade em nuvem

TODO: Guia do banco

## Conceitos úteis

### Subscriber

Aplicativo que consome a API. Pode ser usado para filtros e *throttling* das chamadas. No JWT é identificado pelo *claim* azp (*Authorized Party*).

### Separação dos papéis

- publisher (ferramenta do construtor da api - backend)
- devportal (ferramenta de quem consome a api - front ou back end)

### Fluxo de publicação

API possui vários estágios:

- CREATED - Criada no publisher, mas não disponível no devportal nem no gateway. Neste momento não pode ser utilizada por ninguém.
- PROTOTYPED - Criada no publisher, disponível no devportal, mas não no gateway. Disponível para uso pelo desenvolvedor do consumidor da api.
- PUBLISHED - Criada no publisher, disponível no no devportal e disponível no gateway

- DEPRECATED - Avaliar o uso no nosso fluxo
- BLOCKED - Avaliar o uso no nosso fluxo
- RETIRED - Avaliar o uso no nosso fluxo

# Proposta de instalação

## Docker

Pasta principal no container: /home/wso2carbon/wso2am-3.2.0

TODO: Avaliar a abordagem. Foi mais prático expor a pasta repository abaixo como bind mount no host para facilitar o andamento

```bash
# Personalização da instalação é efetuada no arquivo deployment.toml 
/home/wso2carbon/wso2am-3.2.0/repository/conf/deployment.toml

# Personalização do log é feita neste arquivo
/home/wso2carbon/wso2am-3.2.0/repository/conf/log4j2.properties

# pasta do banco de dados H2 embarcado
/home/wso2carbon/wso2am-3.2.0/repository/database
```

```bash
# cria container com a configuração padrão
docker run -it -p 8280:8280 -p 8243:8243 -p 9443:9443 --name api-manager wso2/wso2am:3.2.0
# copia o diretório /home/wso2carbon/wso2am-3.2.0/repository para o volume local 
docker cp 7390570cc3e7:/home/wso2carbon/wso2am-3.2.0/repository /root/repository
# consede permissão de acesso ao volume
chmod -R 777 repository

# recupera o arquivo padrão de configuração
docker exec -it api-manager /bin/bash -c "cat /home/wso2carbon/wso2am-3.2.0/repository/conf/deployment.toml" > deployment.toml
# troca todas as referências à localhost pelo IP (ou o nome do host)
cp deployment.toml deployment.toml.backup
sed -i "s/localhost/192.168.1.33/" deployment.toml
# outros ajustes poderiam ser feitos aqui....
chmod o+r deployment.toml



# remove o container

# reexecuta com a configuração
docker run -it -p 8280:8280 -p 8243:8243 -p 9443:9443 --name api-manager --volume /root/deployment.toml:/home/wso2carbon/wso2am-3.2.0/repository/conf/deployment.toml -d wso2/wso2am:3.2.0

# fluxo com a pasta repository como bind mount (FIXME: o segundo volume não devia ser necessário)
docker run -p 8280:8280 -p 8243:8243 -p 9443:9443 --name api-manager-debug --volume /root/wso2_log/repository:/home/wso2carbon/wso2am-3.2.0/repository --volume /root/deployment.toml:/home/wso2carbon/wso2am-3.2.0/repository/conf/deployment.toml -d wso2/wso2am:3.2.0

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
- TODO: mais passos

## Configuração

Portas
- 8280 - Api Gateway HTTP (Serviço)
- 8243 - Api Gateway HTTPS (Serviço)
- 9443 - Administrativa

Certificados

- TODO: Certificado dos endpoinst HTTPS (Serviço e Admin)

Ferramental

Integração pelo WSO2 pode ser feita de várias maneiras. 

## interface 

/carbon - interface administrativa (legada)

/devportal - portal de uso (não se aplica a tarefas administrativas)

/publisher

## API REST

## apictl (linha de comando)

Ferramenta de apoio do gateway de API

### Instação básica da ferramenta

```bash
# baixa do site do WSO2
wget https://apim.docs.wso2.com/en/3.2.0/assets/attachments/learn/api-controller/apictl-3.2.1-linux-x64.tar.gz
#descompacta
tar xvzf apictl-3.2.1-linux-x64.tar.gz

# configura um ambiente (ex: lab)
apictl add-env -e lab --apim https://192.168.1.33:9443 --token https://192.168.1.33:9443/oauth2/token

#comando úteis (desnecessários para o processo)
apictl remove env lab
apictl list envs

#configurações são gravadas em
#/home/<usuário>/.wso2apictl/main_config.yaml
#C:\Users\<usuário>\.wso2apictl\main_config.yaml

# cria arquivo com a senha do admin (1x) - melhor seria criar com aplicação ou de maneira que apareça no histórico do bash
echo -n "admin" > password_lab

# faz o login com a senha em arquivo
cat password_lab | apictl login lab -u admin --insecure --verbose --password-stdin

# valida o login listando as apis no serviço (-k é para ignorar erros do certificado)
apictl list apis -e lab -k
ID                                     NAME                VERSION             CONTEXT             STATUS              PROVIDER
c5038bbe-8536-43e4-803c-5feaceed9fdf   echo-postman        v1                  /echo               PUBLISHED           admin

```

### Publicação básica de uma API

TODO: No caso da importação de arquivos swagger/openapi seria importante validar estruturalmente o arquivo antes de processar. O arquivo pode ter sido criado manualmente ou ajustado por ferramental, portanto é válido a pré-validação.

Primeiro usamos o apictl para criar um projeto de API (local na máquina). Este comando (init) gera arquivos locais para serem importados no gateway.

```bash
# se for com um swagger ou openapi (--force necessário quando cria a 1a vez)
# Hidrologia aqui É O NOME PASTA NÃO DA API
# O nome da API é o que constar na seção info/(name|title) do swagger
apictl init Hidrologia --oas api-hidrologia.yaml --force

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# swagger inválido aqui dá erro 500 no passo import sem maiores detalhes
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

# se for com um yaml de definição do wso2
apictl init Hidrologia --definition definicao.yaml --force
```

Na sequência ajustamos os parâmetros necessários. Existe a possibilidade de mudança no template e ter variáveis definidas por usuário (detalhes em https://apim.docs.wso2.com/en/latest/learn/api-controller/importing-apis-via-dev-first-approach/)

```bash
# este exemplo substitui todos os endereços padrão (localhost) por um host de homologação (homapis.ons.org.br) 
sed -i "s/localhost/homapis\.ons\.org\.br/g" Meta-information/api.yaml
```

### Importação do projeto

Uma vez criado o projeto, prosseguimos com a implantação na ferramenta

```bash
# Hidrologia aqui É O NOME PASTA NÃO DA API

# na primeira vez
apictl import-api -f Hidrologia/ -e lab -k

# ao atualizar (ou criar)
apictl import-api -f Hidrologia/ -e lab -k --update

```

Neste momento a API já fica disponível no publisher com estado 'CREATED'. Ela pode ser modificada pela ferramenta publisher, mas não fica disponível no portal.

Para mudar o estado da api:
```bash
# Hidrologia aqui É O NOME DA API NA SEÇÃO NA NAME DO SWAGGGER

# neste caso está se mudando para 'Prototype'
apictl change-status api -a "Deploy as a Prototype" -n Hidrologia -e lab -v 1.0.0 -k

# neste caso está se mudando para 'Publicado'
apictl change-status api -a Publish -n Hidrologia -e lab -v 1.0.0 -k
```

Neste momento passa estar disponível no portal do desenvolvedor (devportal)

### Comandos úteis

```bash
# Hidrologia aqui É O NOME DA API NA SEÇÃO NA NAME DO SWAGGGER

# apagar a api do catálogo
apictl delete api --name Hidrologia -e lab -v 1.0.0 -k
```

# Integrações ONS

## Integração com POP

* Publicar as chaves
* Integrar nas apis a validação
* (Opcional) validar os claims/scopes

WSO2 possui duas maneiras de integrar a chave externa ([referência principal]( https://apim.docs.wso2.com/en/latest/learn/api-security/oauth2/access-token-types/jwt-tokens/#validating-jwts-generated-by-external-oauth-providers))

* Adicionando um certificado na *store* do Java do serviço do WSO2
* Via url JWKS (JSON com as informações da(s) chave(s) pública(s) de validação)

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

### Ajustes no token gerado

Foram necessários três ajustes para o funcionamento correto

#### Identificador **kid** (no **header** do JWT)
O WSO2 usa o *kid* para decidir qual chave pública validar o token, no caso de termos múltiplas.
Existe um alias padrão que pode ser utilizado caso este campo não esteja presente.

#### Claim **azp** (no **payload** do JWT)
O WSO2 usa o *azp* para identificar o *Subscriber* (conceito do WSO2) da aplicação.

**TODO**: Avaliar se podemos definir um padrão se o campo não for enviado
#### Claim **jti** (no **payload** do JWT)
O WSO2 faz cache dos tokens e usa o *jti* como chave. 

**TODO**: Avaliar se é possível desativar o cache, e se sim se ele continua sendo necessário para o fluxo

### Solução *trusted store* do Java

O processo de gerar o certificado e atualizar a *store* do java é possível, mas específico do Java.

A *store* do Java não importa diretamente chave pública, por isso precisamos gerar um certificado x509 com a chave. Para isso **precisamos** da chave privada.

Geração do certificado para importação

```bash
# gera a solicitação
openssl req -new -key private.pem -out cert_req.csr

# cria o certificado
openssl x509 -req -in cert_req.csr -signkey private.pem -out cert.pem
```

Importação na *store* do Java

```bash
# arquivo client-truststore.jks fica na pasta
# wso2am<...>/repository/resources/security
keytool -import -trustcacerts -keystore client-truststore.jks -alias https://poptst.ons.org.br/ons.pop.federation/ -file cert.pem
#senha padrão: wso2carbon
```

### Solução JWKS

A url via JWKS funciona em praticamente todos os gateways. O arquivo extrai-jwks.py pode ser usado para gerar o JSON necessário. Daí em diante é somente necessário termos um serviço web para disponibilizá-lo. Para efeitos de teste podemos usar um nginx se já existir ou *Simple HTTP Server* do python.

Arquivo JWKS de exemplo gerado com a chave acima. Perceba que é um array, dado que várias chaves podem ser disponibilizadas simultâneamente.

```json
[
    {
        "n": "5GA6ikNtJJHTp89PZ4L2R5SHYzFkc8h3zMp8Yv_5bsCj6DlCcARepX4wR6Av2MQsPid85b65STWUUm-XQI2xQHkyDV6Ohu3TYLzk1Sbt9jViRrI8EIa91Nzhz24vjGNgmOn7I0ogn1GMjZ0KPTAmjf8w6vlrJ2UwWg4g65g5643f-NqbYlN1xI9h09Un6pouroaG4UqVeqGjt9HRCHG3yrKIJYBMOC9_hjanDbPrGCngC4ADT39OUjrNiZh0_L1h6hI5rhfXEKJOV-BEc4aHbUa60rG2gXaet8RU4cR4xN-dnBbNpNbJtiFw6YAf6lcw1hcCaQpR5-1dXfOIag7kBQ", 
        "e": "AQAB", 
        "kty": "RSA", 
        "kid": "https://poptst.ons.org.br/ons.pop.federation/"
    }
]
```

Geração do site jwks com python
```bash
# cria a pasta com arquivos a serem disponibilizados via http
mkdir http_server

# gera o arquivo json
python3 extrai-jwks.py >> http_server/jwks.json

cd http_server
python3 -m http.server 8005 &

# verificar se o sucesso da chamada
curl http://localhost:8005/jwks.json
```
Para referência o diff do arquivo original na imagem docker, com os ajustes em ambiente de laboratório.
## diff do arquivo de configuração
```diff
--- deployment.toml	2021-02-01 14:54:19.819199700 -0300
+++ deployment.toml.backup	2021-02-01 15:26:46.238004700 -0300
@@ -1,5 +1,5 @@
 [server]
-hostname = "192.168.1.33"
+hostname = "localhost"
 node_ip = "127.0.0.1"
 #offset=0
 mode = "single" #single or ha
@@ -54,13 +54,13 @@
 display_in_api_console = true
 description = "This is a hybrid gateway that handles both production and sandbox token traffic."
 show_as_token_endpoint_url = true
-service_url = "https://192.168.1.33:${mgt.transport.https.port}/services/"
+service_url = "https://localhost:${mgt.transport.https.port}/services/"
 username= "${admin.username}"
 password= "${admin.password}"
-ws_endpoint = "ws://192.168.1.33:9099"
-wss_endpoint = "wss://192.168.1.33:8099"
-http_endpoint = "http://192.168.1.33:${http.nio.port}"
-https_endpoint = "https://192.168.1.33:${https.nio.port}"
+ws_endpoint = "ws://localhost:9099"
+wss_endpoint = "wss://localhost:8099"
+http_endpoint = "http://localhost:${http.nio.port}"
+https_endpoint = "https://localhost:${https.nio.port}"
 
 #[apim.cache.gateway_token]
 #enable = true
@@ -92,7 +92,7 @@
 
 #[apim.analytics]
 #enable = false
-#store_api_url = "https://192.168.1.33:7444"
+#store_api_url = "https://localhost:7444"
 #username = "$ref{super_admin.username}"
 #password = "$ref{super_admin.password}"
 #event_publisher_type = "default"
@@ -110,7 +110,7 @@
 #type = "failover"
 
 #[apim.key_manager]
-#service_url = "https://192.168.1.33:${mgt.transport.https.port}/services/"
+#service_url = "https://localhost:${mgt.transport.https.port}/services/"
 #username = "$ref{super_admin.username}"
 #password = "$ref{super_admin.password}"
 #pool.init_idle_capacity = 50
@@ -120,10 +120,10 @@
 #key_validation_handler_impl = "org.wso2.carbon.apimgt.keymgt.handlers.DefaultKeyValidationHandler"
 
 #[apim.idp]
-#server_url = "https://192.168.1.33:${mgt.transport.https.port}"
-#authorize_endpoint = "https://192.168.1.33:${mgt.transport.https.port}/oauth2/authorize"
-#oidc_logout_endpoint = "https://192.168.1.33:${mgt.transport.https.port}/oidc/logout"
-#oidc_check_session_endpoint = "https://192.168.1.33:${mgt.transport.https.port}/oidc/checksession"
+#server_url = "https://localhost:${mgt.transport.https.port}"
+#authorize_endpoint = "https://localhost:${mgt.transport.https.port}/oauth2/authorize"
+#oidc_logout_endpoint = "https://localhost:${mgt.transport.https.port}/oidc/logout"
+#oidc_check_session_endpoint = "https://localhost:${mgt.transport.https.port}/oidc/checksession"
 
 #[apim.jwt]
 #enable = true
@@ -139,12 +139,12 @@
 #[apim.oauth_config]
 #enable_outbound_auth_header = false
 #auth_header = "Authorization"
-#revoke_endpoint = "https://192.168.1.33:${https.nio.port}/revoke"
+#revoke_endpoint = "https://localhost:${https.nio.port}/revoke"
 #enable_token_encryption = false
 #enable_token_hashing = false
 
 #[apim.devportal]
-#url = "https://192.168.1.33:${mgt.transport.https.port}/devportal"
+#url = "https://localhost:${mgt.transport.https.port}/devportal"
 #enable_application_sharing = false
 #if application_sharing_type, application_sharing_impl both defined priority goes to application_sharing_impl
 #application_sharing_type = "default" #changed type, saml, default #todo: check the new config for rest api
@@ -167,7 +167,7 @@
 #enable_policy_deploy = true
 #enable_blacklist_condition = true
 #enable_persistence = true
-#throttle_decision_endpoints = ["tcp://192.168.1.33:5672","tcp://192.168.1.33:5672"]
+#throttle_decision_endpoints = ["tcp://localhost:5672","tcp://localhost:5672"]
 
 #[apim.throttling.blacklist_condition]
 #start_delay = "5m"
@@ -185,23 +185,23 @@
 #port = 10005
 
 #[[apim.throttling.url_group]]
-#traffic_manager_urls = ["tcp://192.168.1.33:9611","tcp://192.168.1.33:9611"]
-#traffic_manager_auth_urls = ["ssl://192.168.1.33:9711","ssl://192.168.1.33:9711"]
+#traffic_manager_urls = ["tcp://localhost:9611","tcp://localhost:9611"]
+#traffic_manager_auth_urls = ["ssl://localhost:9711","ssl://localhost:9711"]
 #type = "loadbalance"
 
 #[[apim.throttling.url_group]]
-#traffic_manager_urls = ["tcp://192.168.1.33:9611","tcp://192.168.1.33:9611"]
-#traffic_manager_auth_urls = ["ssl://192.168.1.33:9711","ssl://192.168.1.33:9711"]
+#traffic_manager_urls = ["tcp://localhost:9611","tcp://localhost:9611"]
+#traffic_manager_auth_urls = ["ssl://localhost:9711","ssl://localhost:9711"]
 #type = "failover"
 
 #[apim.workflow]
 #enable = false
-#service_url = "https://192.168.1.33:9445/bpmn"
+#service_url = "https://localhost:9445/bpmn"
 #username = "$ref{super_admin.username}"
 #password = "$ref{super_admin.password}"
-#callback_endpoint = "https://192.168.1.33:${mgt.transport.https.port}/api/am/admin/v0.17/workflows/update-workflow-status"
-#token_endpoint = "https://192.168.1.33:${https.nio.port}/token"
-#client_registration_endpoint = "https://192.168.1.33:${mgt.transport.https.port}/client-registration/v0.17/register"
+#callback_endpoint = "https://localhost:${mgt.transport.https.port}/api/am/admin/v0.17/workflows/update-workflow-status"
+#token_endpoint = "https://localhost:${https.nio.port}/token"
+#client_registration_endpoint = "https://localhost:${mgt.transport.https.port}/client-registration/v0.17/register"
 #client_registration_username = "$ref{super_admin.username}"
 #client_registration_password = "$ref{super_admin.password}"
 
@@ -223,7 +223,7 @@
 #from_address = "APIM.com"
 #username = "APIM"
 #password = "APIM+123"
-#hostname = "192.168.1.33"
+#hostname = "localhost"
 #port = 3025
 #enable_start_tls = false
 #enable_authentication = true
@@ -233,7 +233,7 @@
 #enable_realtime_notifier = true
 #realtime_notifier.ttl = 5000
 #enable_persistent_notifier = true
-#persistent_notifier.hostname = "https://192.168.1.33:2379/v2/keys/jti/"
+#persistent_notifier.hostname = "https://localhost:2379/v2/keys/jti/"
 #persistent_notifier.ttl = 5000
 #persistent_notifier.username = "root"
 #persistent_notifier.password = "root"
@@ -254,11 +254,7 @@
 name = "org.wso2.is.notification.ApimOauthEventInterceptor"
 order = 1
 [event_listener.properties]
-notification_endpoint = "https://192.168.1.33:${mgt.transport.https.port}/internal/data/v1/notify"
+notification_endpoint = "https://localhost:${mgt.transport.https.port}/internal/data/v1/notify"
 username = "${admin.username}"
 password = "${admin.password}"
-'header.X-WSO2-KEY-MANAGER' = "default"
-
-[[apim.jwt.issuer]]
-name = "https://poptst.ons.org.br/ons.pop.federation/"
-jwks.url = "http://localhost:8005/jwks.json"
\ No newline at end of file
+'header.X-WSO2-KEY-MANAGER' = "default"
\ No newline at end of file
```
