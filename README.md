# Como Rodar o Projeto Construído

## Como Executar o Projeto

### Requisitos
- Docker  
- Docker Compose
### Dependências
- ruby 3.3.1
- rails 7.1.3.2
- postgres 16
- redis 7.0.15


### Configuração e Execução

1. Clone o repositório:  
   ```sh
   git clone <URL_DO_REPOSITORIO>
   cd <NOME_DO_PROJETO>
   ```

Construa e inicie os containers:

```sh
docker-compose up --build
```
Configure o banco de dados:
```sh
docker-compose run web rails db:setup
```

### Containers Disponíveis
O projeto utiliza 4 containers principais:

- web: Aplicação Rails (porta 3000)
- db: PostgreSQL 16 (porta 5432)
- redis: Redis 7.0.15 (porta 6379)
s- idekiq: Processamento de jobs em background
### Rotas Disponíveis
- POST /cart – Adiciona produto ao carrinho
- GET /cart – Lista itens do carrinho
- PATCH /cart/add_item – Atualiza quantidade do produto
- DELETE /cart/:product_id – Remove produto do carrinho
### Estrutura do Projeto

**Models**
- Cart: Gerencia carrinhos e suas regras de negócio (abandono/remoção)
- CartItem: Associação entre Cart e Product
- Product: Produtos disponíveis

**Jobs**
- MarkCartAsAbandonedJob: Gerencia carrinhos abandonados
- Marca como abandonado após 3h de inatividade
- Remove após 7 dias de abandono

**Services**
- CreateCartItemService: Adiciona produtos ao carrinho
- UpdateCartItemService: Atualiza quantidade de produtos
- RemoveCartItemService: Remove produtos do carrinho

## Rodando os testes

Para rodar os testes:
```sh
docker-compose run web rspec
```

## Monitoramento
Acesse o dashboard do Sidekiq::
```sh
http://localhost:3000/sidekiq
```

## Docker Stack
- Dockerfile: Configuração do ambiente Ruby
- docker-compose.yml: Orquestração dos serviços
### Volumes persistentes para:
- Dados do PostgreSQL
- Cache do Bundler
- Comandos Úteis

## Comandos Úteis
```sh
docker-compose down # Para parar e remover os containers
docker-compose logs -f # Para visualizar logs em tempo real
docker-compose ps # Para listar os containers ativos
```

# Desafio Técnico E-commerce - Requisitos Implementados

## Requisitos Obrigatórios ✅

### Endpoints da API
Implementadas todas as 4 rotas necessárias com respostas apropriadas:
- **POST** `/cart`: Adiciona produto ao carrinho
- **GET** `/cart`: Lista itens do carrinho
- **PATCH** `/cart/add_item`: Atualiza quantidade do produto
- **DELETE** `/cart/:product_id`: Remove produto do carrinho

### Gestão de Carrinhos Abandonados
- Implementado **job Sidekiq** para gerenciamento
- Adicionado **controle de status** do carrinho (ativo/abandonado)
- Implementada lógica de negócio para:
  - Marcar carrinhos como **abandonados** após **3 horas**
  - Remover carrinhos abandonados após **7 dias**

### Testes
- Implementados **todos os testes pendentes**
- Corrigidos **testes com falha**
- Utilizado **RSpec** para testes
- Adicionada **cobertura de testes** para novas funcionalidades

---

## Requisitos Adicionais ✅

### Dockerização
Ambiente Docker completo com:
- **Container** para aplicação **Rails**
- **Banco de dados PostgreSQL**
- **Redis** para Sidekiq
- **Worker Sidekiq**
- **Volumes persistentes** para:
  - Dados do banco
  - Cache do Bundle

### Qualidade de Código
- Implementado padrão de **Service Objects**
- Adicionado **tratamento de erros apropriado**
- Utilizadas **factories** com **FactoryBot**
- Adicionadas **validações nos models**
- Seguido o princípio da **Responsabilidade Única**

### Tratamento de Erros
- Implementadas validações para:
  - **Existência do produto**
  - **Validação de quantidade**
  - **Transições de status do carrinho**
- Mensagens de erro para **operações inválidas**

---

## Detalhes Técnicos
- **Ruby** 3.3.1
- **Rails** 7.1.3.2
- **PostgreSQL** 16
- **Redis** 7.0.15
- **Sidekiq** para jobs em background
- **RSpec** para testes
- **Factory Bot** para dados de teste

> Convention over Configuration

