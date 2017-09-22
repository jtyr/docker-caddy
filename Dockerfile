FROM golang AS builder

ADD http://www.muppetlabs.com/~breadbox/pub/software/ELFkickers-3.0.tar.gz /tmp
RUN tar -C /tmp -xf /tmp/ELFkickers-3.0.tar.gz
RUN make -C /tmp/ELFkickers-3.0/

RUN go get github.com/mholt/caddy/caddy
WORKDIR /go/src/github.com/mholt/caddy/caddy
RUN git checkout v0.10.9
RUN go get -d ./...
RUN go get -d github.com/caddyserver/builds
RUN go run build.go
RUN /tmp/ELFkickers-3.0/sstrip/sstrip -z caddy


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
