FROM ruby:2.5.1

RUN mkdir /app
WORKDIR /app

COPY . /app

RUN ./build/psql.sh \
    && apt-get update -qq \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y netcat build-essential libpq-dev apt-utils nodejs postgresql-client-9.6 \
    && rm -rf /var/lib/apt/lists/*

RUN bundle install --jobs 20 --retry 5
