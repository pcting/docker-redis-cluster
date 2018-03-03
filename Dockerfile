FROM redis:4.0.8

MAINTAINER Patrick Ting <pcting@gmail.com>

ENV REDIS_VERSION 4.0.8
ENV REDIS_DOWNLOAD_URL http://download.redis.io/releases/redis-4.0.8.tar.gz
ENV REDIS_DOWNLOAD_SHA ff0c38b8c156319249fec61e5018cf5b5fe63a65b61690bec798f4c998c232ad

RUN set -ex; \
	\
	buildDeps=' \
		wget \
		\
		gcc \
		libc6-dev \
		make \
	'; \
	apt-get update; \
	apt-get install -y $buildDeps --no-install-recommends; \
	rm -rf /var/lib/apt/lists/*; \
	\
	wget -O redis.tar.gz "$REDIS_DOWNLOAD_URL"; \
	echo "$REDIS_DOWNLOAD_SHA *redis.tar.gz" | sha256sum -c -; \
	mkdir -p /usr/src/redis; \
	tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1; \
	rm redis.tar.gz; \
	cp /usr/src/redis/src/redis-trib.rb /usr/local/bin/redis-trib.rb; \
	chmod +x /usr/local/bin/redis-trib.rb; \
	\
	rm -r /usr/src/redis

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -yqq \
      net-tools supervisor locales gettext-base git ruby ruby-gems ruby-redis && \
    apt-get clean -yqq

# RUN git clone https://github.com/rbenv/ruby-build.git && \
# 	PREFIX=/usr/local ./ruby-build/install.sh

COPY ./docker-data/redis-cluster.tmpl /redis-conf/redis-cluster.tmpl
COPY ./docker-data/redis.tmpl /redis-conf/redis.tmpl

# Add supervisord configuration
COPY ./docker-data/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Add startup script
COPY ./docker-data/docker-entrypoint.sh /usr/local/bin/docker-entrypoint-redis-cluster.sh
RUN chmod 755 /usr/local/bin/docker-entrypoint-redis-cluster.sh

EXPOSE 7000 7001 7002 7003 7004 7005 7006 7007

ENTRYPOINT ["/usr/local/bin/docker-entrypoint-redis-cluster.sh"]
CMD ["redis-cluster"]
