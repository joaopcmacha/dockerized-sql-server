FROM mcr.microsoft.com/mssql/server:2017-latest
USER root

VOLUME /usr/config
# Create a config directory
RUN mkdir -p /usr/config
WORKDIR /usr/config

# Create database directory
RUN mkdir -p /db_files

# Bundle config source
COPY ./entrypoint.sh /usr/config
COPY ./configure-db.sh /usr/config

# Grant permissions for to our scripts to be executable
RUN chmod +x /usr/config/entrypoint.sh
RUN chmod +x /usr/config/configure-db.sh

ENTRYPOINT ["./entrypoint.sh"]