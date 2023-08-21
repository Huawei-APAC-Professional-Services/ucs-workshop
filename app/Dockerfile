FROM golang:1.21 as builder
WORKDIR /src
COPY . /src/
RUN CGO_ENABLED=0 GOOS=linux go build -a -o app .

FROM alpine:3.11.3
WORKDIR /app
COPY --from=builder /src/app .
RUN chmod +x /app/app

ENTRYPOINT [ "/app/app" ]
