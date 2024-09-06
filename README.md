# TigelaDB

---

TODOZAO MASSA:

- ADICIONAR DOCKER
- MELHORAR O PARSER, SÓ POR DEUS AQUELE CÓDIGO...

---

O TigelaDB é um banco de dados de chave/valor, com suporte para operações
básicas e transações recursivas. É construído em Elixir, sem nenhuma dependência
externa.

# Como rodar

Espera-se que, para rodar o projeto, você tenha uma versão do Elixir superior a
1.16 instalada em sua máquina, além do Erlang.

Primeiramente, clone o repositório em seu computador com:

```bash
$ git clone https://github.com/pedrohaveloso/tigela-db.git
```

Após, entre na pasta do projeto e construa o executável usando o `mix escript.build`:

```bash
$ cd ./tigela-db

$ mix escript.build
```

Agora, basta rodar o executável criado:

```bash
$ ./tigela
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
