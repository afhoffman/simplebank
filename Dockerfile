# Build stage
FROM golang:1.19.0-alpine3.16 AS builder

WORKDIR /app
COPY . .
RUN go build -o main main.go
RUN apk add --no-cache curl
RUN curl -L https://github.com/golang-migrate/migrate/releases/download/v4.15.2/migrate.linux-amd64.tar.gz | tar xvz 
# Run stage
FROM alpine:3.16
WORKDIR /app

COPY --from=builder /app/main .
COPY --from=builder /app/doc/swagger/ ./doc/swagger
COPY --from=builder /app/app.env .
COPY --from=builder /app/start.sh .
COPY --from=builder /app/wait-for.sh .
RUN chmod +x ./start.sh && chmod +x ./wait-for.sh
COPY --from=builder /app/migrate ./migrate

COPY --from=builder /app/db/migration ./migration

ENV GIN_MODE=release

EXPOSE 8080

CMD [ "/app/main" ]
ENTRYPOINT [ "/app/start.sh" ]
