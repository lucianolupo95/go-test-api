# ---------- build stage ----------
FROM golang:1.22-alpine AS builder

WORKDIR /app

# deps primero (mejor cache)
COPY app/go.mod ./
RUN go mod download

# código
COPY app/ ./

# build binario estático
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -o server

# ---------- runtime stage ----------
FROM alpine:3.19

WORKDIR /app

# certs para HTTPS saliente si algún día los usás
RUN apk add --no-cache ca-certificates

COPY --from=builder /app/server /app/server

EXPOSE 8080

CMD ["/app/server"]
