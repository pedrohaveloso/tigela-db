# TigelaDB

![Banner do TigelaDB](./banner.png)

O TigelaDB é um banco de dados de chave/valor, com suporte para operações
básicas e transações recursivas. É construído em Elixir, sem nenhuma dependência
externa.

# Sumário

- [**Como rodar**](#como-rodar)
  - [Rodando com Elixir/Erlang](#rodando-com-elixirerlang)
  - [Rodando com Docker](#rodando-com-docker)
- [**Funcionalidades**](#funcionalidades)
  - [SET](#set)
  - [GET](#get)
  - [BEGIN](#begin)
  - [ROLLBACK](#rollback)
  - [COMMIT](#commit)
- [**Considerações finais**](#consideracoes-finais)
- [**Contatos e links**](#contatos-e-links)

# Como rodar

Existem duas maneiras de rodar o projeto, utilizando Docker ou o próprio Elixir/Erlang instalado em sua máquina. Veremos as duas formas.

Primeiramente, clone o repositório em seu computador com:

```bash
λ git clone https://github.com/pedrohaveloso/tigela-db.git
```

Após, entre na pasta do projeto:

```bash
λ cd ./tigela-db
```

## Rodando com Elixir/Erlang

Espera-se que, para rodar dessa maneira, você tenha uma versão do Elixir superior a
1.16 instalada em sua máquina, além do Erlang.

Dentro da pasta, faça:

```bash
λ mix escript.build
```

Agora, basta rodar o executável criado:

```bash
λ ./tigela
```

Para rodar a bateria de testes, execute:

```bash
λ mix test
```

## Rodando com Docker

Espera-se que, para rodar dessa maneira, você tenha o Docker instalado em sua máquina.

Dentro da pasta, rode o comando abaixo para construir a imagem:

```bash
λ  docker build -t tigela-db .
```

Agora, inicie o container com a imagem:

```bash
λ docker run --init -it tigela-db
```

O programa estará rodando no Docker.

Para rodar a bateria de testes, execute:

```bash
λ docker run --rm tigela-db mix test
```

# Funcionalidades

O TigelaDB possui cinco comandos, sendo eles: `SET`, `GET`, `BEGIN`, `ROLLBACK` e `COMMIT`. Veja, abaixo, uma definição mais apropriada e detalhada de cada comando disponível.

## SET

Insere ou modifica o valor de uma chave no banco. A chave e o valor são persistentes por padrão, sendo armazenado em memória ao iniciar uma transação.

**Sintaxe**: `SET` \<key\> \<value\>

- Onde \<key\> deve ser uma sequência de caracteres ou dígitos, podendo conter espaços caso seja envolvido entre aspas simples (').
- Onde \<value\> pode ser um valor numérico, um valor booleano (TRUE ou FALSE) ou um texto, sendo o texto qualquer outro valor sem espaços, podendo conter espaços ao ser envolvido entre aspas duplas (").

Após executado, uma saída ocorre, contendo um valor booleano (TRUE ou FALSE) que representa se a chave já existia anteriormente, e o valor inserido.

Exemplos:

```bash
> SET x 10
FALSE 10

> SET 'x' 10
TRUE 10

> SET last name "Pedro"
ERR "SET <key> <value> - Syntax error"

> SET 'last name' "Pedro"
FALSE "Pedro"

> SET 'last name' Pedro
TRUE Pedro

> SET 'full name' Pedro Veloso
ERR "SET <key> <value> - Syntax error"

> SET 'full name' "Pedro Veloso"
FALSE "Pedro Veloso"
```

## GET

Obtém o valor de uma chave salvo no banco.

**Sintaxe**: `GET` \<key\>

- Onde \<key\> obedece as mesmas regras de `SET`.

Após ser executado, uma saída contendo o valor ocorre. Em casos onde o valor não exista, a saída é `NIL`.

Exemplos:

```bash
> GET name name
ERR "GET <key> - Syntax error"

> GET name
NIL

> SET name "Juan"
FALSE "Juan"

> GET name
"Juan"
```

## BEGIN

Inicia uma nova transação.

**Sintaxe**: `BEGIN`

Após ser executado, uma saída ocorre contendo o nível atual de transação (quantidade de transações ativas).

Exemplos:

```bash
> BEGIN
1

> BEGIN
2
```

## ROLLBACK

Desfaz uma transação e descarta todos os dados modificados ou adicionados durante ela.

**Sintaxe**: `ROLLBACK`

Após ser executado, uma saída ocorre contendo o nível atual de transação.

Exemplos:

```bash
> BEGIN
1
> SET x 10
FALSE 10
> BEGIN
2
> SET x 20
TRUE 20
> ROLLBACK
1
> ROLLBACK
0
> GET x
NIL
```

## COMMIT

Completa uma transação e salva todos os seus dados e modificações. Caso hajam outras transações anteriores a atual, os dados são salvos nela. Caso a transação atual seja única, os dados são salvos de maneira persistente.

**Sintaxe**: `COMMIT`

Após ser executado, uma saída ocorre contendo o nível atual de transação.

Exemplos:

```bash
> SET x 10
FALSE 10
> BEGIN
1
> SET x 20
TRUE 20
> COMMIT
0
> GET x
20
```

# Considerações finais

# Contatos e links

Endereço de e-mail: <a href="mailto:contatopedrohalves@gmail.com">contatopedrohalves@gmail.com</a>.

Telefone celular: <a href="tel:+5514920021247">14 92002-1247</a>.

Banner (Figma): [www.figma.com/design/tigela-db](https://www.figma.com/design/q8KGVvP3kutnkk4KcEVrLG/Desafio---TigelaDB?node-id=0-1&t=tx9PvPkAq2fjLVXk-1).
