FROM golang:1.27 as builder

ENV WARP_VERSION=1.0.8

WORKDIR /go/src/github.com/minio/warp/
RUN git clone --depth 1 --branch "v$WARP_VERSION" https://github.com/minio/warp .

RUN go mod download

ENV CGO_ENABLED=0

RUN go build -ldflags '-w -s' -a -o warp .

FROM debian:13

COPY --from=builder /go/src/github.com/minio/warp/warp /usr/local/bin/warp

WORKDIR /app

ENV KEEP_ALIVE_AFTER_TEST=false

COPY ./entrypoint.sh /app/entrypoint.sh

RUN apt-get update && apt-get install -y ca-certificates && \
    rm -rf /var/lib/apt/lists/* && update-ca-certificates && \
    mkdir /app/out && chmod +x /app/entrypoint.sh

CMD ["/app/entrypoint.sh"]