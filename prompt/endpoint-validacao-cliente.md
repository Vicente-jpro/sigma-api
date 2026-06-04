Quero que definas de forma específica como deve funcionar o endpoint da API REST que será consumido pelo **software cliente instalado na máquina do cliente** para verificar o **estado da aplicação**, validar a licença e decidir se o software pode continuar a funcionar.

O contexto do sistema é o seguinte:

- a plataforma chama-se **SIGMA (Sistema de Gestão e Monitorização de Aplicações)**;
- existe uma entidade `ChaveProduto` com os campos:
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
- os status possíveis da chave/licença são:
  - `PENDENTE`
  - `ATIVA`
  - `EXPIRADA`
  - `BLOQUEADA`
- os dados de identificação do dispositivo **não ficam em `ChaveProduto`**, mas sim numa entidade própria chamada `DispositivoCliente`;
- o controlo anti-pirataria deve considerar:
  - número de série de componentes físicos;
  - endereço MAC;
  - IP público real;
- o software cliente deve consultar a API diariamente para:
  - validar a chave;
  - validar o dispositivo;
  - obter autorização de uso;
  - receber token JWT;
  - saber se a aplicação deve continuar ativa, ficar limitada ou ser bloqueada.

Quero que a tua resposta proponha de forma **objetiva, técnica e pronta para implementação** os seguintes pontos:

## 1. Endpoint REST
Definir:
- método HTTP ideal;
- path completo versionado;
- objetivo do endpoint;
- quando deve ser chamado pelo software cliente.

## 2. JSON de request
Definir:
- estrutura completa do payload enviado pelo software cliente;
- campos obrigatórios;
- exemplo JSON realista;
- quais dados de dispositivo devem ser enviados;
- como identificar a chave/licença e o software.

## 3. Regras de validação no backend
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

## 4. JSON de response
Quero uma proposta de resposta padronizada para o software cliente contendo no mínimo:
- `autorizado`
- `statusAplicacao`
- `mensagem`
- `codigoErro`
- `token`
- `licenca`
- `cliente`
- `software`
- `dispositivo`
- `servidorEm`

## 5. Estados da aplicação no cliente
Definir quais valores `statusAplicacao` podem existir, por exemplo:
- `LIBERADA`
- `AGUARDANDO_ATIVACAO`
- `BLOQUEADA`
- `ACESSO_LIMITADO`
- `SOMENTE_LEITURA`

E explicar como o software cliente deve reagir a cada um deles.

## 6. Exemplos completos de resposta
Gerar exemplos reais de resposta JSON para pelo menos estes cenários:
- licença válida;
- licença expirada;
- licença bloqueada por suspeita de pirataria;
- chave pendente;
- chave inexistente;
- dispositivo inválido;
- limite de instalações atingido.

## 7. HTTP status codes
Indicar quais códigos HTTP devem ser usados em cada cenário, como por exemplo:
- `200`
- `403`
- `404`
- `409`
- `422`

## 8. DTOs sugeridos
Propor os DTOs Java/Spring Boot para:
- request;
- response;
- objeto de licença;
- objeto de dispositivo;
- enum de status da aplicação;
- enum de código de erro.

## 9. OpenAPI/Swagger
Apresentar também a especificação resumida do contrato OpenAPI desse endpoint:
- summary;
- description;
- request body;
- responses principais.

## 10. Regra final de decisão no software cliente
Explicar claramente a lógica que o software cliente deve seguir após receber a resposta, indicando:
- quando libera uso normal;
- quando bloqueia;
- quando mostra aviso;
- quando entra em modo restrito.

Importante:
- a resposta deve ser em português;
- a modelagem deve respeitar que `ChaveProduto` não guarda dados do dispositivo;
- a entidade `DispositivoCliente` é responsável pelos identificadores físicos e de rede;
- a resposta deve ser estruturada com títulos, subtítulos, tabelas e blocos JSON;
- quero algo com qualidade de documentação técnica para implementação imediata em **Java 21 + Spring Boot**.
