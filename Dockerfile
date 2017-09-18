ARG ALPINE
ARG GOLANG_ALPINE

FROM ${GOLANG_ALPINE} AS builder

WORKDIR /go/src/github.com/docker/swarm
COPY vendor/ /go/src/
COPY . /go/src/github.com/docker/swarm

RUN apk add --no-cache --virtual .build-deps git

RUN CGO_ENABLED=0 go build -a -tags "netgo static_build" -installsuffix netgo \
      -ldflags "-w -X github.com/docker/swarm/version.GITCOMMIT=$(git rev-parse --short HEAD) -X github.com/docker/swarm/version.BUILDTIME=$(date -u +%FT%T%z) \
      -extldflags '-static'" \
      -o /go/bin/swarm .

FROM ${ALPINE}

RUN apk -v add --update ca-certificates && rm -rf /var/cache/apk/*

COPY --from=builder /go/bin/swarm /bin/swarm

ENV SWARM_HOST :2375
EXPOSE 2375

ENTRYPOINT ["/bin/swarm"]
CMD ["--help"]
