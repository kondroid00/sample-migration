FROM alpine:3.10.2

# install sqldef
WORKDIR /tmp
RUN wget -q https://github.com/k0kubun/sqldef/releases/download/v0.4.14/mysqldef_linux_amd64.tar.gz \
 && tar -zxvf mysqldef_linux_amd64.tar.gz \
 && rm mysqldef_linux_amd64.tar.gz \
 && mkdir -p /go/bin \
 && mv mysqldef /go/bin/mysqldef

ADD . /go/src/github.com/kondroid00/sample-migration
WORKDIR /go/src/github.com/kondroid00/sample-migration

RUN chmod +x ./scripts/migrate.sh
