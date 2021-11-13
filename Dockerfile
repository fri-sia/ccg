FROM bitwalker/alpine-elixir-phoenix:latest as base



RUN mkdir /app
WORKDIR /app
ADD mix.exs mix.lock ./
RUN mix do deps.get, deps.compile
COPY . .

RUN mix do compile
