FROM postgres:11.3
ENV POSTGRES_USER ref_admin
ENV POSTGRES_PASSWORD ref_admin
ENV POSTGRES_DB refdata
ENV PGDATA /var/lib/postgresql/data/pgdata
ADD config /docker-entrypoint-initdb.d/

