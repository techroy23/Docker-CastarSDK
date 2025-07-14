FROM alpine:latest

WORKDIR /app

RUN apk update && apk add --no-cache curl unzip

RUN curl -fsSL https://download.castarsdk.com/linux.zip -o linux.zip \
    && unzip linux.zip -d /app \
    && rm linux.zip \
    && chmod +x /app/CastarSdk_amd64

CMD ["sh", "-c", "echo \"APPKEY=$APPKEY\" && exec /app/CastarSdk_amd64 -key=$APPKEY"]
