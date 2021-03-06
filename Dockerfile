FROM golang AS builder

ARG caddy_version=v1.0.1
ARG elfkickers_version=3.1
ARG plugins

ADD http://www.muppetlabs.com/~breadbox/pub/software/ELFkickers-${elfkickers_version}.tar.gz /tmp
RUN tar -C /tmp -xf /tmp/ELFkickers-${elfkickers_version}.tar.gz
RUN make -C /tmp/ELFkickers-${elfkickers_version}/

RUN go get github.com/caddyserver/caddy/caddy
WORKDIR /go/src/github.com/caddyserver/caddy/caddy
RUN git checkout ${caddy_version}
RUN for N in $(echo ${plugins}); do echo "Adding plugin $N"; sed -i -r 's,(\s*)(// This is where.*),\1_ "'$N'"\n\1\2",' caddymain/run.go; done
RUN go get -d ./...
RUN go get -d github.com/caddyserver/builds
RUN go run build.go
RUN /tmp/ELFkickers-${elfkickers_version}/sstrip/sstrip -z caddy


FROM scratch
MAINTAINER Jiri Tyr

COPY --from=builder /go/src/github.com/caddyserver/caddy/caddy/caddy /
ADD data /data
ADD Caddyfile /Caddyfile
ADD .caddy /.caddy
ADD DST_Root_CA_X3.pem /etc/ssl/certs/ca-certificates.crt

VOLUME /.caddy

EXPOSE 2015 80 443

ENTRYPOINT ["/caddy", "-conf", "/Caddyfile", "-root", "/data"]
