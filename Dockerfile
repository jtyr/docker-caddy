FROM golang AS builder

ARG caddy_version=0.11.0
ARG elfkickers_version=3.1
ARG plugins

ADD http://www.muppetlabs.com/~breadbox/pub/software/ELFkickers-${elfkickers_version}.tar.gz /tmp
RUN tar -C /tmp -xf /tmp/ELFkickers-${elfkickers_version}.tar.gz
RUN make -C /tmp/ELFkickers-${elfkickers_version}/

RUN go get github.com/jtyr/caddy/caddy
RUN rm -fr /go/src/github.com/mholt/caddy
RUN mv /go/src/github.com/jtyr/caddy /go/src/github.com/mholt/caddy
WORKDIR /go/src/github.com/mholt/caddy/caddy
RUN for N in $(echo ${plugins}); do echo "Adding plugin $N"; sed -i -r 's,(\s*)(// This is where.*),\1_ "'$N'"\n\1\2",' caddymain/run.go; done
RUN go get -d ./...
RUN go get -d github.com/caddyserver/builds
RUN grep tls_client_escaped_cert ../caddyhttp/httpserver/replacer.go
RUN go run build.go
RUN /tmp/ELFkickers-${elfkickers_version}/sstrip/sstrip -z caddy


FROM scratch
MAINTAINER Jiri Tyr

COPY --from=builder /go/src/github.com/mholt/caddy/caddy/caddy /
ADD data /data
ADD Caddyfile /Caddyfile
ADD .caddy /.caddy
ADD DST_Root_CA_X3.pem /etc/ssl/certs/ca-certificates.crt

VOLUME /.caddy

EXPOSE 2015 80 443

ENTRYPOINT ["/caddy", "-conf", "/Caddyfile", "-root", "/data"]
