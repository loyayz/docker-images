FROM postgres:15-bullseye

LABEL maintainer="loyayz - https://loyayz.com"

ENV PG_WORK_USER ""
ENV PG_WORK_PASSWORD ""
ENV PG_WORK_DB ""

# postgis https://github.com/postgis/docker-postgis/blob/master/15-3.3/Dockerfile

RUN apt-get update \
      && apt-get install -y --no-install-recommends \
           ca-certificates \
           wget bzip2 make gcc libc6-dev postgresql-server-dev-$PG_MAJOR \
           \
           postgresql-$PG_MAJOR-postgis-3 \
           postgresql-$PG_MAJOR-postgis-3-scripts \
           postgresql-$PG_MAJOR-hll \
           postgresql-$PG_MAJOR-repack \
           postgresql-$PG_MAJOR-pgrouting \
           postgresql-$PG_MAJOR-rum \
      \
      # zhparser
      && cd / && wget -q -O - http://www.xunsearch.com/scws/down/scws-1.2.3.tar.bz2 | tar xjf - \
      && cd / && wget -q -O - https://github.com/amutu/zhparser/archive/refs/heads/master.tar.gz | tar xzf - \
      && cd /scws-1.2.3 && ./configure && make install \
      && cd /zhparser-master && make install \
      # pg_stat_monitor
      && cd / && wget -q -O - https://github.com/percona/pg_stat_monitor/archive/refs/heads/main.tar.gz | tar xzf - \
      && cd /pg_stat_monitor-main && make USE_PGXS=1 && make USE_PGXS=1 install \
      \
      # pgroonga https://pgroonga.github.io
      && cd / && wget https://packages.groonga.org/debian/groonga-apt-source-latest-bullseye.deb \
      && apt install -y -V ./groonga-apt-source-latest-bullseye.deb \
      && apt update && apt install -y -V postgresql-$PG_MAJOR-pgdg-pgroonga \
      # clean
      && apt-get purge -y \
            wget bzip2 make gcc libc6-dev postgresql-server-dev-$PG_MAJOR \
      && apt-get autoremove --purge -y \
      && rm -rf /scws-1.2.3 \
            /zhparser-master \
            /pg_stat_monitor-main \
            /groonga-apt-source-latest-bullseye.deb \
            /var/lib/apt/lists/*

COPY init.sh /docker-entrypoint-initdb.d/20_init.sh
RUN chmod 755 /docker-entrypoint-initdb.d/20_init.sh
