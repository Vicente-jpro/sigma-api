# Prompt final — endpoint de validação diária do software cliente

Quero que definas de forma específica, técnica e pronta para implementação como deve funcionar o endpoint da API REST que será consumido pelo **software cliente instalado na máquina do cliente** para verificar o **estado da aplicação**, validar a licença e decidir se o software pode continuar a funcionar.

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
- `limiteInstalacao`
- `instalacoesUsadas`
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
- receber token JWT;
- saber se a aplicação deve continuar ativa, ficar limitada ou ser bloqueada.

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
  "softwareId": 3,
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
- `softwareId`: identifier of the software associated with the license;
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
- associação com o software;
- status da licença;
- expiração;
- validação do dispositivo;
- registo de nova instalação;
- limite de instalações;
- deteção de tentativa suspeita;
- incremento de tentativas inválidas;
- bloqueio automático da chave quando necessário.

### 4. JSON de response padronizado e enxuto
Quero que seja definido **um único contrato de resposta JSON**, igual para todos os cenários, mudando apenas os valores dos campos.

A resposta deve seguir como referência esta **versão sólida da response**, também com **campos em inglês**:

```json
{
  "authorized": true,
  "applicationStatus": "ALLOWED",
  "message": "Valid license.",
  "errorCode": null,
  "token": "<JWT_TOKEN>",
  "tokenType": "Bearer",
  "license": {
    "id": 15,
    "status": "ACTIVE",
    "daysUsed": 42,
    "totalAllowedDays": 90,
    "daysRemaining": 48
  },
  "device": {
    "validated": true,
    "suspiciousAttempt": false,
    "status": "ACTIVE"
  },
  "serverAt": "2026-06-04T10:30:00Z"
}
```

### Regras da response
- deve existir **apenas um único formato de response**;
- a estrutura deve ser a mesma para sucesso e erro;
- o software cliente deve sempre desserializar o mesmo contrato;
- a response deve ser enxuta e conter apenas os dados necessários para a aplicação cliente decidir o seu estado;
- a response não deve incluir dados completos do cliente;
- a response não deve incluir dados completos do software;
- a response não deve incluir detalhes administrativos ou informações irrelevantes para o cliente;
- usar nomenclatura técnica em inglês de forma consistente em todos os campos JSON.

### 5. Estados da aplicação no cliente
Definir quais valores `applicationStatus` podem existir, por exemplo:
- `ALLOWED`
- `PENDING_ACTIVATION`
- `BLOCKED`
- `LIMITED_ACCESS`
- `READ_ONLY`

Explicar como o software cliente deve reagir a cada um deles.

### 6. Código de erro padronizado
Definir também um enum de `errorCode`, por exemplo:
- `LICENSE_EXPIRED`
- `LICENSE_BLOCKED`
- `LICENSE_PENDING`
- `KEY_NOT_FOUND`
- `INVALID_DEVICE`
- `INSTALLATION_LIMIT_REACHED`
- `SOFTWARE_NOT_ASSOCIATED`
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
- response padronizado;
- objeto de licença resumido;
- objeto de dispositivo resumido;
- enum de status da aplicação;
- enum de código de erro.

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
- quando entra em modo restrito.

### 12. Requisito de consistência
A resposta deve deixar explícito que:
- existe **apenas um JSON de response padrão**;
- o software cliente deve sempre desserializar a mesma estrutura;
- o que muda entre os cenários são apenas os valores de:
  - `authorized`
  - `applicationStatus`
  - `errorCode`
  - `message`
  - `token`
  - `license.status`
  - `license.daysUsed`
  - `license.totalAllowedDays`
  - `license.daysRemaining`
  - `device.validated`
  - `device.suspiciousAttempt`
  - `device.status`

---

## Requisitos importantes

- a resposta deve ser em português, mas os **campos JSON devem ser em inglês**;
- a modelagem deve respeitar que `ChaveProduto` não guarda dados do dispositivo;
- a entidade `DispositivoCliente` é responsável pelos identificadores físicos e de rede;
- a resposta deve ser estruturada com títulos, subtítulos, tabelas e blocos JSON;
- quero algo com qualidade de documentação técnica para implementação imediata em **Java 21 + Spring Boot**.
