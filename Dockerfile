# 6.2.6
FROM redis@sha256:f7ee67d8d9050357a6ea362e2a7e8b65a6823d9b612bc430d057416788ef6df9

# Some Environment Variables
ENV HOME /root

# Install dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -yqq \
      net-tools supervisor ruby rubygems locales gettext-base wget gcc make g++ build-essential libc6-dev tcl && \
    apt-get clean -yqq

# default version is 6.2.6, may be overwriten by docker-compose.yml
ARG redis_version=6.2.6

RUN wget -qO redis.tar.gz https://github.com/redis/redis/tarball/${redis_version} \
    && tar xfz redis.tar.gz -C / \
    && mv /redis-* /redis

RUN (cd /redis && make)

RUN mkdir /redis-data && mkdir /redis-config

COPY ./redis-config/redis-cluster.tmpl /redis-config/redis-cluster.tmpl
COPY ./redis-config/start-redis-cluster.sh /redis-config/start-redis-cluster.sh

# add more ports if needed to be exposed to host
EXPOSE 7000 7001 7002 7003 7004 7005 7006 7007 5000 5001 5002

RUN chmod 755 /redis-config/start-redis-cluster.sh

ENTRYPOINT ["/redis-config/start-redis-cluster.sh"]
