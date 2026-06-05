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
- `PENDENTE`
- `ATIVA`
- `EXPIRADA`
- `BLOQUEADA`

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
Definir:
- estrutura completa do payload enviado pelo software cliente;
- campos obrigatórios;
- exemplo JSON realista;
- dados de dispositivo que devem ser enviados;
- como identificar a chave/licença e o software.

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

### 4. JSON de response padronizado e minimalista
Quero que seja definido **um único contrato de resposta JSON**, igual para todos os cenários, mudando apenas os valores dos campos.

A resposta deve ser **minimalista** e conter apenas o necessário para o software cliente tomar decisão.

Deve conter no mínimo:
- `autorizado`
- `statusAplicacao`
- `codigoErro`
- `mensagem`
- `token`
- `tokenType`
- `expiraEm`
- `servidorEm`
- `licenca`

O objeto `licenca` também deve ser minimalista e conter apenas:
- `id`
- `status`
- `diasRestantes`

A resposta **não deve** incluir dados desnecessários como:
- dados completos do cliente;
- dados completos do software;
- detalhes extensos do dispositivo;
- informações administrativas;
- metadados que não sejam usados diretamente pelo software cliente.

A resposta **não deve ter estruturas diferentes para sucesso e erro**.  
Deve existir **um único formato de response** para facilitar o consumo pelo software cliente.

### 5. Estados da aplicação no cliente
Definir quais valores `statusAplicacao` podem existir, por exemplo:
- `LIBERADA`
- `AGUARDANDO_ATIVACAO`
- `BLOQUEADA`
- `ACESSO_LIMITADO`
- `SOMENTE_LEITURA`

Explicar como o software cliente deve reagir a cada um deles.

### 6. Código de erro padronizado
Definir também um enum de `codigoErro`, por exemplo:
- `LICENCA_EXPIRADA`
- `LICENCA_BLOQUEADA`
- `LICENCA_PENDENTE`
- `CHAVE_NAO_ENCONTRADA`
- `DISPOSITIVO_INVALIDO`
- `LIMITE_INSTALACOES_ATINGIDO`
- `SOFTWARE_NAO_ASSOCIADO`
- `DADOS_INVALIDOS`

Explicar quando cada código deve ser retornado.

### 7. Exemplos completos de resposta
Gerar exemplos reais de resposta JSON **usando sempre o mesmo contrato minimalista**, para pelo menos estes cenários:
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
- response padronizado minimalista;
- objeto de licença resumido;
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
  - `autorizado`
  - `statusAplicacao`
  - `codigoErro`
  - `mensagem`
  - `token`
  - `licenca.status`
  - `licenca.diasRestantes`

---

## Requisitos importantes

- a resposta deve ser em português;
- a modelagem deve respeitar que `ChaveProduto` não guarda dados do dispositivo;
- a entidade `DispositivoCliente` é responsável pelos identificadores físicos e de rede;
- a resposta deve ser estruturada com títulos, subtítulos, tabelas e blocos JSON;
- quero algo com qualidade de documentação técnica para implementação imediata em **Java 21 + Spring Boot**.
