FROM golang:1.12-alpine as builder

RUN apk add --update --no-cache git

ENV GO111MODULE=on

WORKDIR /go/src/caddy/

COPY go.mod go.sum ./
RUN go mod download

COPY main.go ./
COPY plugin/ ./plugin/

ENV CGO_ENABLED=0
RUN go build -v

FROM alpine:3.7 as alpine
RUN apk add --update --no-cache ca-certificates

# Image starts here
FROM scratch
LABEL maintainer "Lucas Lorentz <lucaslorentzlara@hotmail.com>"

EXPOSE 80 443 2015
ENV HOME /root

WORKDIR /
COPY --from=alpine /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

COPY --from=builder /go/src/caddy/caddy-docker-proxy /bin/caddy

ENTRYPOINT ["/bin/caddy"]
