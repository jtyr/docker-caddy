FROM scratch
MAINTAINER Jiri Tyr

ADD caddy /
ADD data /data
ADD Caddyfile /Caddyfile

VOLUME /.caddy

EXPOSE 2015 80 443

CMD ["/caddy", "-conf", "/Caddyfile", "-root", "/data"]
