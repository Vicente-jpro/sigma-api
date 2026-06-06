# Prompt final — endpoint de validação diária do software cliente

Quero que definas de forma específica, técnica e pronta para implementação como deve funcionar o endpoint da API REST que será consumido pelo **software cliente instalado na máquina do cliente** para validar a licença e decidir se o software pode continuar a funcionar.

## Contexto do sistema

A plataforma chama-se **SIGMA (Sistema de Gestão e Monitorização de Aplicações)**.

Existe uma entidade `ChaveProduto` com os seguintes campos:
- `id`
- `status`
- `dataCriacao`
- `dataAtivacao`
- `totalDiasPermitidos`
- `diasUsados`
- `ultimaVerificacaoEm`
- `cliente`
- `software`
- `limiteMaxInstalacao`
- `numeroInstalacao`
- `quantidadeTentativasInvalidas`

Os status possíveis da chave/licença são:
- `PENDING`
- `ACTIVE`
- `EXPIRED`
- `BLOCKED`

Os dados de identificação do dispositivo **não ficam em `ChaveProduto`**.  
Esses dados devem ficar numa entidade própria chamada `DispositivoCliente`.

O controlo anti-pirataria deve considerar:
- número de série de componentes físicos;
- endereço MAC;
- IP público real.

O software cliente deve consultar a API diariamente para:
- validar a chave;
- validar o dispositivo;
- obter autorização de uso;
- receber token JWT quando aplicável;
- saber se a aplicação deve continuar ativa ou ser bloqueada.

Se a API estiver temporariamente indisponível, o software cliente deve tolerar a indisponibilidade por até **1 semana**, permitindo uso temporário durante esse período com base na última validação bem-sucedida.

---

## O que quero que definas

### 1. Endpoint REST
Definir:
- método HTTP ideal;
- path completo versionado;
- objetivo do endpoint;
- momento em que deve ser chamado pelo software cliente.

### 2. JSON de request
O endpoint de validação diária do software cliente deve receber **exatamente** o seguinte formato de request, com **campos em inglês**:

```json
{
  "productKey": "SIGMA-ABC-12345-XYZ",
  "device": {
    "motherboardSerial": "SN-PC-45879-XPT",
    "macAddress": "00:1B:44:11:3A:B7"
  },
  "appVersion": "2.4.1",
  "installationId": "550e8400-e29b-41d4-a716-446655440000"
}
```

### Request rules
- `productKey`: license key to validate;
- `device.motherboardSerial`: primary physical machine identifier;
- `device.macAddress`: machine MAC address;
- `appVersion`: installed client software version;
- `installationId`: unique and persistent identifier of the installation on the device.

### Important request requirements
- the request must follow exactly this structure;
- the `device` object must contain only:
  - `motherboardSerial`
  - `macAddress`
- the real public IP may be obtained by the backend from the HTTP request itself;
- do not include unnecessary fields in the payload;
- the goal of the request must be simplicity, contract stability, and ease of consumption by the client software.

### 3. Regras de validação no backend
Explicar a ordem ideal das validações, incluindo:
- existência da chave;
- status da licença;
- expiração;
- validação do dispositivo;
- registo de nova instalação;
- limite de instalações;
- deteção de tentativa suspeita;
- incremento de tentativas inválidas;
- bloqueio automático da chave quando necessário.

#### Regra explícita para nova instalação
Uma instalação é considerada nova quando o `installationId` ainda não está registado para aquela licença.

O backend só pode registar uma nova instalação quando:
- `numeroInstalacao < limiteMaxInstalacao`

Quando essa condição for verdadeira, a nova instalação pode ser criada e associada ao dispositivo informado.

Quando essa condição não for verdadeira, o backend deve rejeitar a operação com erro de limite de instalações atingido.

#### Diferença obrigatória entre erros
- `INVALID_DEVICE`: o dispositivo informado não corresponde ao registo esperado da instalação/licença;
- `INSTALLATION_LIMIT_REACHED`: a instalação seria válida como nova instalação, mas `numeroInstalacao` já atingiu `limiteMaxInstalacao`.

### 4. JSON de response padronizado e simplificado
Quero que seja definido **um único contrato de resposta JSON**, igual para todos os cenários, mudando apenas os valores dos campos.

A resposta deve ser **minimalista** e conter apenas os atributos essenciais para o software cliente tomar decisão, evitando complexidade desnecessária.

A resposta deve seguir como referência esta versão final simplificada, com **campos em inglês**:

```json
{
  "message": "Valid license.",
  "errorCode": null,
  "token": "<JWT_TOKEN>",
  "license": {
    "status": "ACTIVE",
    "daysRemaining": 48
  }
}
```

### Regras da response
- deve existir **apenas um único formato de response**;
- a estrutura deve ser a mesma para sucesso e erro;
- o software cliente deve sempre desserializar o mesmo contrato;
- a response deve conter apenas os dados essenciais para a aplicação cliente decidir o seu estado;
- a response não deve incluir dados completos do cliente;
- a response não deve incluir dados completos do software;
- a response não deve incluir detalhes administrativos ou informações irrelevantes para o cliente;
- a response não deve incluir detalhes internos do dispositivo se esses dados não alterarem a lógica do cliente;
- usar nomenclatura técnica em inglês de forma consistente em todos os campos JSON.

#### Regra explícita do token
- `token` deve ser retornado apenas quando a licença permitir uso do software;
- quando a licença não permitir uso, `token` deve ser `null`.

#### Regras de nulabilidade
- `message`: obrigatório em todos os cenários;
- `errorCode`: deve ser `null` quando não houver erro;
- `token`: deve ser `null` quando a licença não autorizar uso;
- `license.status`: obrigatório em todos os cenários;
- `license.daysRemaining`: obrigatório em todos os cenários e deve ser numérico;
- `license.daysRemaining`: quando a licença estiver expirada, deve ser `0`, e não `null`.

### 5. Regra de decisão no cliente usando `license.status`
O software cliente deve basear a decisão de execução no valor de `license.status`.

Regras esperadas:
- `ACTIVE`: o software pode operar normalmente;
- `PENDING`: o software não deve liberar uso normal;
- `EXPIRED`: o software não deve liberar uso normal;
- `BLOCKED`: o software deve bloquear uso imediatamente.

Explicar claramente como o cliente deve reagir a cada um desses status.

### 6. Código de erro padronizado
Definir também um enum de `errorCode`, por exemplo:
- `LICENSE_EXPIRED`
- `LICENSE_BLOCKED`
- `LICENSE_PENDING`
- `KEY_NOT_FOUND`
- `INVALID_DEVICE`
- `INSTALLATION_LIMIT_REACHED`
- `INVALID_DATA`

Explicar quando cada código deve ser retornado.

### 7. Exemplos completos de resposta
Gerar exemplos reais de resposta JSON **usando sempre o mesmo contrato**, para pelo menos estes cenários:
- licença válida;
- licença expirada;
- licença bloqueada por suspeita de pirataria;
- chave pendente;
- chave inexistente;
- dispositivo inválido;
- limite de instalações atingido.

#### Regra obrigatória para os exemplos
Todos os exemplos devem respeitar **exatamente** o contrato final simplificado.

Isso significa que:
- nenhum exemplo pode adicionar campos fora do contrato definido;
- nenhum exemplo pode omitir campos obrigatórios do contrato;
- todos os exemplos devem usar sempre a mesma estrutura JSON;
- o que muda entre os exemplos deve ser apenas o valor dos campos já definidos no contrato.

### 8. HTTP status codes
Indicar quais códigos HTTP devem ser usados em cada cenário, como por exemplo:
- `200`
- `403`
- `404`
- `409`
- `422`

### 9. DTOs sugeridos
Propor os DTOs Java/Spring Boot para:
- request;
- response padronizado simplificado;
- objeto de licença resumido;
- enum de código de erro;
- enum de status da licença.

### 10. OpenAPI/Swagger
Apresentar também a especificação resumida do contrato OpenAPI desse endpoint:
- summary;
- description;
- request body;
- responses principais.

### 11. Regra final de decisão no software cliente
Explicar claramente a lógica que o software cliente deve seguir após receber a resposta, indicando:
- quando libera uso normal;
- quando bloqueia;
- quando mostra aviso;
- quando permite uso temporário por indisponibilidade da API;
- quando deve encerrar o período de tolerância offline de 1 semana.

### 12. Requisito de consistência
A resposta deve deixar explícito que:
- existe **apenas um JSON de response padrão**;
- o software cliente deve sempre desserializar a mesma estrutura;
- o que muda entre os cenários são apenas os valores de:
  - `message`
  - `errorCode`
  - `token`
  - `license.status`
  - `license.daysRemaining`

---

## Requisitos importantes

- a resposta deve ser em português, mas os **campos JSON devem ser em inglês**;
- a modelagem deve respeitar que `ChaveProduto` não guarda dados do dispositivo;
- a entidade `DispositivoCliente` é responsável pelos identificadores físicos e de rede;
- a resposta deve ser estruturada com títulos, subtítulos, tabelas e blocos JSON;
- quero algo com qualidade de documentação técnica para implementação imediata em **Java 21 + Spring Boot**;
- priorizar simplicidade do contrato e reduzir ao máximo os atributos retornados ao cliente.
