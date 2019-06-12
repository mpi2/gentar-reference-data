FROM postgres:11.3
ENV POSTGRES_USER ref_admin
ENV POSTGRES_PASSWORD ref_admin
ENV POSTGRES_DB refdata
COPY config /docker-entrypoint-initdb.d/
