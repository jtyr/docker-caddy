FROM scratch
MAINTAINER Jiri Tyr

ADD caddy /
ADD data /data
ADD Caddyfile /Caddyfile
ADD .caddy /.caddy

VOLUME /.caddy

EXPOSE 2015 80 443

ENTRYPOINT ["/caddy", "-conf", "/Caddyfile", "-root", "/data"]
