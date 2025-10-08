FROM alpine:latest

ARG TARGETARCH

WORKDIR /app

RUN apk update \
    && apk upgrade --no-cache \
    && apk add --no-cache ca-certificates ca-certificates-bundle unzip curl bash dos2unix tzdata iptables redsocks \
    && update-ca-certificates

RUN curl -fsSL -A "Mozilla/5.0" https://download.castarsdk.com/linux.zip -o linux.zip \
    && unzip linux.zip -d /app \
    && if [ "$TARGETARCH" = "amd64" ]; then \
           mv /app/linux-sdk/CastarSdk_amd64 /app/CastarSdk; \
       elif [ "$TARGETARCH" = "arm64" ]; then \
           mv /app/linux-sdk/CastarSdk_arm /app/CastarSdk; \
       else \
           echo "Unsupported architecture: $TARGETARCH" && exit 1; \
       fi \
    && rm -rf linux.zip /app/linux-sdk \
    && chmod +x /app/CastarSdk

COPY entrypoint.sh /entrypoint.sh

RUN dos2unix /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]