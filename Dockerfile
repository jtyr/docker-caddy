FROM golang AS builder

ARG caddy_version=0.10.14
ARG elfkickers_version=3.1

ADD http://www.muppetlabs.com/~breadbox/pub/software/ELFkickers-${elfkickers_version}.tar.gz /tmp
RUN tar -C /tmp -xf /tmp/ELFkickers-${elfkickers_version}.tar.gz
RUN make -C /tmp/ELFkickers-${elfkickers_version}/

RUN go get github.com/mholt/caddy/caddy
WORKDIR /go/src/github.com/mholt/caddy/caddy
RUN git checkout v${caddy_version}
RUN go get -d ./...
RUN go get -d github.com/caddyserver/builds
RUN go run build.go
RUN /tmp/ELFkickers-${elfkickers_version}/sstrip/sstrip -z caddy


FROM scratch
MAINTAINER Jiri Tyr

COPY --from=builder /go/src/github.com/mholt/caddy/caddy/caddy /
ADD data /data
ADD Caddyfile /Caddyfile
ADD .caddy /.caddy
ADD ca-IdenTrust.crt /etc/ssl/certs/ca-certificates.crt

VOLUME /.caddy

EXPOSE 2015 80 443

ENTRYPOINT ["/caddy", "-conf", "/Caddyfile", "-root", "/data"]
