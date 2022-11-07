FROM loyayz/postgres-zhparser:15

LABEL maintainer="loyayz - https://loyayz.com"

# postgis https://github.com/postgis/docker-postgis/blob/master/15-3.3/Dockerfile
ENV POSTGIS_MAJOR 3
ENV POSTGIS_VERSION 3.3.1+dfsg-1.pgdg110+1
# pg_stat_monitor https://github.com/percona/pg_stat_monitor
ENV PGSM_URL https://github.com/percona/pg_stat_monitor/archive/refs/heads/main.tar.gz

RUN apt-get update \
      && apt-get install -y --no-install-recommends \
           ca-certificates \
           wget make gcc libc6-dev postgresql-server-dev-$PG_MAJOR \
           \
           postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR=$POSTGIS_VERSION \
           postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR-scripts \
           postgresql-$PG_MAJOR-hll \
           postgresql-$PG_MAJOR-repack \
           postgresql-$PG_MAJOR-pgrouting \
           postgresql-$PG_MAJOR-rum \
      \
      # pg_stat_monitor
      && wget -q -O - $PGSM_URL | tar xzf - \
      && cd pg_stat_monitor-main && make USE_PGXS=1 && make USE_PGXS=1 install \
      # clean
      && apt-get purge -y \
            wget make gcc libc6-dev postgresql-server-dev-$PG_MAJOR \
      && apt-get autoremove --purge -y \
      && rm -rf /pg_stat_monitor-main \
            /var/lib/apt/lists/*

RUN mkdir -p /docker-entrypoint-initdb.d
COPY ./load-extensions.sh /docker-entrypoint-initdb.d/load-extensions.sh
COPY ./update-postgis.sh /usr/local/bin
RUN chmod 755 /docker-entrypoint-initdb.d/load-extensions.sh /usr/local/bin/update-postgis.sh
