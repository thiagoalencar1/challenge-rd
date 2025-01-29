# Ecommerce API
Aplicação que simula um carrinho de compras em um sistema de e-commerce.

## Features
O que a aplicação faz?
- Adiciona produtos no carrinho.
- Atualiza a quantidade de itens no carrinho.
- Remove itens de um carrinho.
- Gerenciamento de carrinhos abandonados.
- Marca carrinhos como abandonados após 3 horas de inatividade
- Limpa carrinhos abandonados após 7 dias.

## Tecnologias
- Ruby on Rails (version 7.1.5)
- PostgreSQL
- Redis
- Sidekiq
- Docker

## Como executar este projeto usando Docker
### 1. Clone o repositório, entre no diretório e execute o comando:
```bash
docker compose build
```
### 2. Renomeie o .env.example para .env

### 3. Inicie o projeto:
```bash
make up
```
### 4. Execute os testes:
```bash
make test
```
### 5. Se quiser acessar o bash dentro do container:
```bash
make bash
```
### 6. Endpoints
Os endpoints da API são os seguintes:

#### Criar um novo carrinho com itens
```bash
post http://localhost:3000/cart
```
Exemplo de payload:
```json
{
  "product_id": 1,
  "quantity": 1
}
```
#### Adicionar um item ao carrinho
```bash
post http://localhost:3000/cart/add_item
```
Exemplo de payload:
```json
{
  "product_id": 1,
  "quantity": 1
}
```
#### Remover um item do carrinho
```bash
post http://localhost:3000/cart/1 # onde 1 é o id do produto
```

#### Mostrar os itens do carrinho

```bash
get http://localhost:3000/cart
```

## Instruções do desafio
- [Descrição das instruções](docs/instructions.md)