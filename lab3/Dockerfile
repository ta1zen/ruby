FROM ruby:3.1.2-slim

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      pkg-config \
      libsqlite3-dev \
      nodejs \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

RUN RAILS_ENV=development bundle exec rails db:prepare

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
