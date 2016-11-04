docker-caddy
============

This is a `Dockerfile` which helps to create Docker container with minimalist
HTTP server. The HTTP server is called [Caddy](https://github.com/mholt/caddy/caddy)
and it's written in Go. This container is using statically compiled Caddy which
means that there is only the `caddy` binarry plus the `Caddyfile` on the
container which makes the container very small:

```
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
jtyr/caddy          latest              a27aa99a7274        8 minutes ago       15.33 MB
```


Usage
-----

The `caddy` file was created by building Caddy statically:

```
$ go get github.com/mholt/caddy/caddy
$ cd $GOPATH/src/github.com/mholt/caddy/caddy
$ CGO_ENABLED=0 go build -o caddy
```

Then just copy the `caddy` file into the directory where the `Dockerfile` sits
and build the image:

```
$ docker build -t jtyr/caddy .
```

Or skipp the building part and pull the data image directly from Docker Hub:

```
$ docker pull jtyr/caddy
```

Run the container:

```
$ docker run -p 2015:2015 jtyr/caddy
```

Now it should be possible to access the HTTP server on the host's local
address:

```
$ curl http://localhost:2015
```

The default port 2015 can be changed by the Docker port mapping:

```
$ docker run -d -p 8080:2015 jtyr/caddy
$ curl http://localhost:8080
```

Content is serverd from the `/data` directory. In order to use custom content,
we have to mount custom volume:

```
$ docker run -d -p 2015:2015 -v /path/to/my/web/page:/data jtyr/caddy
```

Similarly the `.caddy` directory, containing for example the HTTPS
certificates, can be shared across multiple containers like this:

```
$ docker run -d -p 2015:2015 -v /caddy/page:/data -v /caddy/.caddy:/.caddy jtyr/caddy

```

Configuration can be changed by mapping the default `Candyfile` to local one:

```
$ docker run -d -p 2015:2015 -v /caddy/Caddyfile:/Caddyfile jtyr/caddy
```

If the automatic HTTPS is activated, both ports the 80 and the 443 can be mapped
like this:

```
$ docker run -d -p 80:80 -p 443:443 -v /caddy/Caddyfile:/Caddyfile -v /caddy/.caddy:/.caddy jtyr/caddy
```


License
-------

MIT


Author
------

Jiri Tyr
