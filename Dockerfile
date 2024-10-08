FROM ruby:3.2

RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libmariadb-dev \
  nodejs \
  cron \
  vim \
  redis-server

RUN curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add - && \
    apt-get install -y apt-transport-https && \
    echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | tee /etc/apt/sources.list.d/elastic-7.x.list && \
    apt-get update && apt-get install -y elasticsearch

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

COPY wait-curl.sh /app/wait-curl.sh
RUN chmod +x /app/wait-curl.sh

EXPOSE 3000 6379 3306 9200

ENV MYSQL_HOST=db
ENV MYSQL_USERNAME=root
ENV MYSQL_PASSWORD=EL_123456
ENV MYSQL_DATABASE=chat_system

CMD /app/wait-curl.sh && \
    redis-server & \
    elasticsearch & \
    bundle exec sidekiq & \
    bundle exec rails server -b 0.0.0.0