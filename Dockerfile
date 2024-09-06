FROM elixir:1.16.3-otp-26-alpine

COPY . /tigela-db

WORKDIR /tigela-db

RUN mix escript.build

CMD ["sh", "-c", "./tigela"]