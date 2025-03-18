FROM mcr.microsoft.com/mssql/server:2022-latest
USER root

VOLUME /usr/config
# Create config and databases directory
RUN mkdir -p /usr/config && mkdir -p /db_files
WORKDIR /usr/config

# Bundle config source
COPY ./entrypoint.sh /usr/config
COPY ./configure-db.sh /usr/config

# Grant permissions for to our scripts to be executable
RUN chmod +x /usr/config/entrypoint.sh && chmod +x /usr/config/configure-db.sh

ENTRYPOINT ["./entrypoint.sh"]