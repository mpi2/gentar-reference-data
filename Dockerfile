FROM postgres:18
ENV POSTGRES_USER=ref_admin
ENV POSTGRES_DB=refdata
ENV PGDATA=/usr/local/lib/postgresql/data/pgdata
COPY config /docker-entrypoint-initdb.d/
RUN --mount=type=secret,id=passwd,env=POSTGRES_PASSWORD mkdir -p /usr/local/data && chown -R 999:999 /usr/local/data