FROM debian:11-slim

RUN apt update \
    && apt install -y curl gnupg2 \
    && curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && echo "deb http://apt.postgresql.org/pub/repos/apt bullseye-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
    && apt update \
    && apt install -y postgresql-client-16=16.6* s3cmd unzip \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf /var/lib/apt/lists/* awscliv2.zip aws \
    && apt-get remove -y unzip

WORKDIR /app

COPY seed.sh .

RUN chmod +x seed.sh

ENTRYPOINT [ "/bin/bash", "seed.sh" ]

