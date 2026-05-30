Claro — aqui está o **prompt completo com a seção 19 já ajustada** para aplicar essa mudança de modelagem no seu texto final.

---

# Prompt final — SIGMA

Quero desenvolver uma plataforma chamada **SIGMA (Sistema de Gestão e Monitorização de Aplicações)** no formato de **API REST**, com o objetivo de gerir clientes, softwares, licenças/chaves de produto, ativações, monitorização de uso autorizado, controlo anti-pirataria, auditoria administrativa e envio de notificações.

## 1. Objetivo do sistema
O SIGMA deve permitir:

- gestão de clientes;
- gestão de softwares;
- gestão de chaves de produto/licenças;
- controlo de instalações;
- ativação e expiração de licenças;
- autenticação segura por token;
- monitorização diária do uso;
- controlo anti-pirataria;
- envio de alertas por email;
- gestão de administradores;
- auditoria de ações administrativas;
- rastreabilidade de alterações de status das licenças.

O sistema será consumido por softwares cliente que devem consultar a API diariamente para validar a licença e obter autorização de uso.

---

## 2. Perfis de utilizador

### 2.1 Administrador
Pode:
- gerir clientes;
- gerir softwares;
- gerir chaves de produto;
- ativar chaves de produto;
- consultar informações de uso e status das licenças;
- consultar histórico de alterações das chaves conforme permissões;
- ter visão geral de clientes, softwares e licenças através de filtros e dashboards.

### 2.2 Super Administrador
Pode:
- gerir administradores;
- gerir clientes;
- gerir softwares;
- gerir chaves de produto;
- ativar chaves de produto;
- visualizar pedidos de recuperação de palavra-passe;
- alterar a palavra-passe de administradores;
- visualizar histórico completo de alterações de status das chaves;
- ter visão global do sistema com dashboards, filtros, métricas e auditoria.

---

## 3. Gestão de clientes, softwares e licenças

O SIGMA deve permitir:

- **CRUD de clientes**;
- **CRUD de softwares**;
- **CRUD de chaves de produto**.

### Regras da licença
- Um cliente pode ter várias chaves de produto para o mesmo software.
- A licença é por tempo.
- O Administrador ou Super Administrador deve informar o número de meses da licença.
- Para simplificar o controlo:
  - **1 mês = 30 dias**
- O SIGMA deve calcular automaticamente o `totalDiasPermitidos`.
- O campo `diasUsados` deve ser incrementado diariamente por scheduler.
- Quando `diasUsados` atingir `totalDiasPermitidos`, a licença deve passar automaticamente para `EXPIRADA`.

---

## 4. Entidade ChaveProduto

A entidade **ChaveProduto** deve conter apenas:

- `id` único da chave;
- `status` da chave;
- `dataCriacao`;
- `dataAtivacao`;
- `totalDiasPermitidos`;
- `diasUsados`;
- `ultimaVerificacaoEm`;
- `cliente` associado;
- `software` associado;
- `limiteInstalacao` — limite máximo de instalações permitidas;
- `instalacoesUsadas` — número de instalações realizadas;
- `quantidadeTentativasInvalidas`.

### Regras dos campos
- `diasUsados` deve ser incrementado pelo scheduler;
- `ultimaVerificacaoEm` deve guardar a última data/hora em que a chave foi verificada;
- antes de incrementar, o sistema deve verificar `ultimaVerificacaoEm`;
- com base na data atual, deve calcular quantos dias precisam ser adicionados para manter a integridade caso o scheduler falhe.

---

## 5. Status da chave/licença

A chave/licença deve ter apenas os seguintes status:

- **PENDENTE**  
  Quando o Administrador ou Super Administrador cadastra um cliente e associa a um software.

- **ATIVA**  
  Quando o Administrador ou Super Administrador ativa a chave e o cliente está dentro do prazo.

- **EXPIRADA**  
  Quando o prazo terminou.

- **BLOQUEADA**  
  Quando há suspeita de pirataria.

---

## 6. Histórico de alteração de status da chave/licença

O SIGMA deve possuir uma entidade específica chamada **HistoricoStatusChave** para registar toda alteração de status da licença/chave.

### Entidade `HistoricoStatusChave`
Campos obrigatórios:

- `id`
- `chaveProduto`
- `statusAnterior`
- `statusNovo`
- `alteradoPor` → utilizador que fez a alteração (`User`)
- `dataAlteracao`
- `motivoAlteracao`
- `origemAlteracao` → `MANUAL`, `SISTEMA`, `ANTI_PIRATARIA`

### Regras
- toda alteração de status da `ChaveProduto` deve gerar um registo em `HistoricoStatusChave`;
- quando a alteração for manual, `alteradoPor` deve ser preenchido;
- quando a alteração for automática pelo sistema, `alteradoPor` pode ser `null`;
- `motivoAlteracao` deve ser registado em alterações manuais relevantes;
- o histórico deve servir para auditoria e controlo interno;
- registos de histórico não devem ser apagados nem alterados por administradores comuns;
- o Super Administrador deve ter acesso completo ao histórico;
- alterações automáticas também devem ser registadas, incluindo:
  - `PENDENTE -> ATIVA`
  - `ATIVA -> EXPIRADA`
  - `ATIVA -> BLOQUEADA`

### Objetivo
Garantir:
- rastreabilidade;
- responsabilização;
- prova administrativa;
- controlo sobre ações dos funcionários;
- histórico íntegro de mudanças de licença.

---

## 7. Regra de instalação e ativação

A chave do produto deve ser usada para ativar a instalação do software no computador do cliente.

### Regras
- uma chave pode ser usada por **N instalações**;
- o número máximo permitido é definido por `limiteInstalacao`;
- o número de instalações já feitas é controlado por `instalacoesUsadas`;
- a cada nova instalação, o SIGMA deve verificar:
  - se a chave está `ATIVA`;
  - se ainda não expirou;
  - se `instalacoesUsadas < limiteInstalacao`.
- se a instalação for válida:
  - registar o dispositivo;
  - incrementar `instalacoesUsadas`;
  - associar a instalação à chave do produto.
- se `instalacoesUsadas` atingir `limiteInstalacao`, novas instalações não devem ser permitidas.

---

## 8. Controlo anti-pirataria e identificação da máquina

O controlo anti-pirataria deve usar **obrigatoriamente e unicamente** estes parâmetros:

- número de série de componentes físicos;
- endereço MAC;
- IP público real atribuído pelo ISP.

### Regras
- esses dados devem ser preenchidos na **primeira autenticação de cada instalação**;
- esses dados devem ficar associados à chave do produto por meio do registo do dispositivo/instalação;
- uma chave pode ter vários dispositivos associados, respeitando `limiteInstalacao`;
- nenhuma mudança dos dados do dispositivo pode ser aceite sem validação;
- usar a chave para instalar em outro dispositivo deve gerar alerta;
- mudança de dispositivo deve ser tratada como tentativa suspeita;
- a forma de diferenciar uso legítimo de tentativa de pirataria é:
  - a primeira autenticação de uma instalação válida regista oficialmente o dispositivo;
  - qualquer autenticação com dados divergentes para uma instalação já conhecida é suspeita;
  - qualquer novo dispositivo acima do limite é inválido.

### Regras adicionais
- o sistema deve permitir no máximo **5 tentativas inválidas**;
- cada tentativa inválida deve ser registada;
- antes do bloqueio definitivo, o SIGMA deve enviar email de alerta ao cliente;
- ao atingir o limite, a chave deve ser marcada como **BLOQUEADA**;
- toda mudança automática para `BLOQUEADA` deve gerar registo em `HistoricoStatusChave` com `origemAlteracao = ANTI_PIRATARIA`.

---

## 9. Consulta diária do cliente

O software cliente deve consultar o SIGMA diariamente para validar o seu uso.

Essa consulta deve permitir:

- validar a chave do produto;
- validar o dispositivo;
- retornar token JWT;
- retornar status da licença;
- retornar dias usados;
- retornar total de dias permitidos;
- retornar resultado da validação do dispositivo;
- permitir que o software saiba se continua ativo ou deve ser bloqueado.

### Resposta mínima esperada
- token;
- status;
- id da chave;
- id do cliente;
- id do software;
- dias usados;
- total de dias permitidos;
- resultado da validação do dispositivo.

---

## 10. Expiração automática e controlo do scheduler

O SIGMA deve verificar diariamente as licenças ativas.

### Regras
- o campo `diasUsados` deve ser incrementado por scheduler;
- antes de incrementar, o sistema deve verificar `ultimaVerificacaoEm`;
- o sistema deve calcular quantos dias se passaram desde a última verificação;
- deve adicionar exatamente a quantidade de dias em falta para manter a integridade mesmo que o scheduler falhe;
- quando `diasUsados` for igual ou maior que `totalDiasPermitidos`, a licença deve passar para `EXPIRADA`;
- licenças expiradas não devem gerar novo token válido;
- o software cliente deve ser informado da expiração;
- a transição para `EXPIRADA` deve ser registada em `HistoricoStatusChave` com `origemAlteracao = SISTEMA`.

### Requisito técnico
- usar **ShedLock** para impedir execução concorrente do scheduler em múltiplas instâncias.

---

## 11. Alertas por email

O SIGMA deve enviar emails em formato **HTML**.

### Casos obrigatórios
1. quando faltarem **15 dias** para a licença expirar;
2. quando houver tentativa suspeita de uso em outro dispositivo;
3. antes do bloqueio definitivo por tentativas inválidas;
4. quando uma chave for ativada manualmente.

### Conteúdo mínimo do email
- nome do cliente;
- nome do software;
- identificação da chave;
- status atual;
- dias restantes, quando aplicável;
- descrição do alerta;
- orientação para regularização.

### Regra especial para ativação
Quando uma chave mudar para `ATIVA`, o SIGMA deve enviar automaticamente email para:
- o **Super Administrador**;
- todos os **Administradores** ativos.

O email deve informar:
- quem fez a alteração;
- cliente afetado;
- software associado;
- chave alterada;
- status anterior;
- status novo;
- data/hora da alteração;
- motivo da alteração, quando existir.

---

## 12. Fluxo de envio de email com mensageria

O envio de email deve ser **assíncrono**, executado em **thread separada** da requisição principal.

### Fluxo obrigatório
1. o sistema identifica o evento;
2. publica a mensagem em um tópico Kafka;
3. o consumidor lê a mensagem de forma assíncrona;
4. o template HTML é processado com Thymeleaf;
5. o email é enviado ao destinatário.

### Política de retry
- o consumo/envio deve ter política de retry no Kafka;
- o sistema deve tentar reenviar/processar a mensagem **até 4 vezes**;
- após o limite de tentativas, o evento deve ser registado como falha de envio.

---

## 13. Recuperação de palavra-passe

A autenticação e autorização por perfil deve permitir recuperação de palavra-passe.

### Regras
- todo pedido de recuperação de palavra-passe deve ser visto pelo Super Administrador;
- apenas o Super Administrador pode alterar a palavra-passe de um Administrador;
- o sistema deve registar histórico dessas operações.

---

## 14. Filtros e visão geral para Administrador e Super Administrador

O SIGMA deve fornecer filtros, pesquisa, paginação, ordenação e dashboards para visão geral de clientes, softwares, licenças e histórico.

### Filtros para clientes
- por `id`;
- por `nome`;
- por `email`;
- por `telefone`;
- por `status`;
- por `dataCriacao`;
- por intervalo de datas;
- por software associado;
- por quantidade de chaves;
- por chaves ativas;
- por chaves expiradas;
- por chaves bloqueadas.

### Filtros para softwares
- por `id`;
- por `nome`;
- por `versao`;
- por `status`;
- por cliente associado;
- por quantidade de clientes;
- por quantidade de chaves emitidas;
- por quantidade de chaves ativas;
- por quantidade de chaves expiradas;
- por quantidade de chaves bloqueadas.

### Filtros para chaves/licenças
- por `status`;
- por `cliente`;
- por `software`;
- por `diasRestantes`;
- por `dataAtivacao`;
- por `dataCriacao`;
- por `totalDiasPermitidos`;
- por `diasUsados`;
- por `limiteInstalacao`;
- por `instalacoesUsadas`;
- por `quantidadeTentativasInvalidas`.

### Filtros para histórico de status
- por chave;
- por cliente;
- por software;
- por `statusAnterior`;
- por `statusNovo`;
- por `alteradoPor`;
- por `origemAlteracao`;
- por intervalo de datas.

### View geral do Administrador
O Administrador deve ter acesso a dashboard com:
- total de clientes;
- total de softwares;
- total de chaves;
- chaves ativas;
- chaves expiradas;
- chaves bloqueadas;
- licenças prestes a expirar;
- clientes com tentativas inválidas;
- softwares mais usados;
- clientes com mais instalações.

### View geral do Super Administrador
O Super Administrador deve ter acesso a visão global com:
- todos os indicadores do Administrador;
- total de administradores;
- pedidos de recuperação de palavra-passe;
- ações auditadas dos administradores;
- falhas de envio de email;
- estatísticas globais de ativações;
- chaves bloqueadas por suspeita de pirataria;
- histórico completo de mudanças de status.

### Recursos obrigatórios nas consultas
- paginação;
- ordenação ascendente e descendente;
- busca textual;
- filtros compostos;
- filtros por intervalo de datas;
- filtros por múltiplos status.

---

## 15. Tecnologias obrigatórias

Quero usar:

- **Java 21**
- **Spring Boot**
- **Maven**
- **Spring Security**
- **JWT**
- **OAuth2**
- **PostgreSQL**
- **Redis**
- **Kafka**
- **Maildev**
- **Actuator**
- **Job Scheduler**
- **ShedLock**
- **Docker Compose**
- **OpenAPI / Swagger UI**
- **Thymeleaf**

---

## 16. Entidades principais

O sistema deve ter, no mínimo, as seguintes entidades:

- **User** (`SUPER_ADMINISTRADOR` ou `ADMINISTRADOR`)
- **Cliente**
- **Software**
- **ChaveProduto**
- **HistoricoStatusChave**
- **Ativacao**
- **DispositivoCliente**
- **HistoricoAutenticacao**
- **EmailNotificacao**

---

## 17. Requisitos técnicos esperados

A solução deve incluir:

- autenticação e autorização por perfil;
- recuperação de palavra-passe;
- documentação Swagger/OpenAPI;
- monitorização com Actuator;
- persistência em PostgreSQL;
- cache com Redis;
- integração com Kafka;
- envio assíncrono de email;
- scheduler com ShedLock;
- scheduler para incremento de dias usados;
- scheduler para deteção de expiração;
- scheduler para alerta de 15 dias;
- logs de auditoria;
- validação de dados;
- tratamento global de exceções;
- DTOs de entrada e saída;
- arquitetura em camadas;
- versionamento de API.

---

## 18. O que quero que a solução proponha

Quero que a solução proponha:

- modelação das entidades;
- relacionamentos entre tabelas;
- regras de negócio;
- endpoints REST;
- fluxo de ativação da chave;
- fluxo de consulta diária;
- fluxo de expiração;
- fluxo de bloqueio por pirataria;
- fluxo de recuperação de palavra-passe;
- fluxo assíncrono de envio de email;
- estrutura do projeto;
- configuração base do Docker Compose;
- exemplos de payload JSON;
- roadmap de implementação.

---

## 19. Observação de modelagem importante

A entidade `ChaveProduto` deve conter apenas os campos definidos na sua própria secção e **não deve armazenar dados de identificação do dispositivo**.

Os dados usados no controlo anti-pirataria, como:
- número de série de componentes físicos;
- endereço MAC;
- IP público real;

devem ficar exclusivamente numa entidade própria chamada **DispositivoCliente**, associada à chave do produto e à instalação.

A entidade `HistoricoStatusChave` deve ser usada exclusivamente para guardar o histórico de mudança de status da licença/chave, contendo apenas:
- `id`
- `chaveProduto`
- `statusAnterior`
- `statusNovo`
- `alteradoPor`
- `dataAlteracao`
- `motivoAlteracao`
- `origemAlteracao`

Nenhuma informação de dispositivo deve ser armazenada em `HistoricoStatusChave`.

---
