FROM alpine:3.8

ARG ID=1000

RUN apk add --no-cache ruby ruby-dev make gcc musl-dev g++ zlib zlib-dev && \
 gem install rdoc; exit 0
RUN gem install bundler

RUN mkdir /var/www
WORKDIR /var/www

COPY Gemfile /var/www
RUN bundle install

RUN apk del ruby-dev make gcc musl-dev g++ zlib-dev isl gmp-dev 

VOLUME /var/www
EXPOSE 4000

RUN adduser -D -u ${ID} usuario
USER usuario

CMD bundle exec jekyll serve --host $(ip addr | grep -oE '172(\.\w+)+') -c _config.yml,_config_dev.yml
