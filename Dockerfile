FROM postgres:11.3
ARG CI_PROJECT_PATH
ENV POSTGRES_USER ref_admin
ENV POSTGRES_PASSWORD ref_admin
ENV POSTGRES_DB refdata
COPY config /docker-entrypoint-initdb.d/
COPY /builds/${CI_PROJECT_PATH}/mnt /mnt

