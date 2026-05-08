# Dockerfile для розробки — лабораторна робота №4
FROM ruby:3.1.2-slim

# Системні залежності: pg для PostgreSQL, pkg-config для компіляції нативних гемів
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      pkg-config \
      libpq-dev \
      postgresql-client \
      nodejs \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /rails

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 3000
# Видаляємо server.pid щоб уникнути помилки при повторному запуску
CMD ["bash", "-c", "rm -f tmp/pids/server.pid && bundle exec rails server -b 0.0.0.0"]
