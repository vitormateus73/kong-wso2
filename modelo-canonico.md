# Introduçao

O objetivo das api's de modelo canônico é fornecer um dicionário de objetos comuns reutilizáveis e definições a nível empresarial ou de domínio de negócios para melhorar a interoperabilidade e facilitar a comincação entre os diversos sistemas do ONS.

## Estrutura

Cada Dominio (Elétrico, Hidrologia, Equipamento) terá sua própria api que deverá seguir a seguinte estrutura :

- Um método get que retorna o nome de todos os medolos dentro do domínio 

- Cada modelo deverá conter um description sobre o mesmo com as segunites imformações (Sistema de origem, finalidade de uso, Sistemas que utilizam o dado) 

## Modo de utilização

 A idéia principal de disponibilização dos modelos canonicos no portal do desenvolvedor é prover uma visão unica dos modelos de dados já disponíveis para para utilização no momento da modelagem das API's afim de evitar retrabalho e a duplicação de entidades. Para que essa abordagem seja de fato efetiva o desenvolvimento de novas API's deve seguir o conseito de API-First onde a modelagem da é feita antes do desenvolvimento do serviço em si.



## Versionamento

- TODO

## Exemplo

```yaml
openapi: 3.0.1
info:
  title: Modelo Canonico Elétrico
  version: 1.0.0
servers:
- url: http://localhost:10010/CanonicoEletrico/v1
paths:
  /:
    get:
      operationId: getObjetosDisponiveis
      parameters:
      responses:
        "200":
          description: Ok
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ObjetosDisponiveis'
        default:
          description: Erro
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Erro'
components:
  schemas:
    Barra:
      type: object
      description: Objeto de origem do Sistema XPTO, usado para Fins X,Y e Z  com o objetivo de resolver algo
      properties:
        Id:
          type: string
        Numero:
          type: integer
        Nome:
          type: string
        agente:
          type: string
    Dominio:
      type: object
      description: Objeto de origem do Sistema XPTO, usado para Fins X,Y e Z  com o objetivo de resolver algo
      properties:
        Identificador:
          type: string
        Descricao:
          type: integer
    ObjetosDisponiveis:
        type: array
        items:
          type: string
    Erro:
      type: object
      description: schema of error return data.
      properties:
        code:
          type: integer
          format: int32
        message:
          type: string
        fields:
          type: string
```