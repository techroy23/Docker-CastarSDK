FROM alpine:latest

ARG TARGETARCH

WORKDIR /app

RUN apk update \
    && apk upgrade --no-cache \
    && apk add --no-cache ca-certificates ca-certificates-bundle unzip curl bash dos2unix tzdata iptables redsocks \
    && update-ca-certificates

RUN echo ">>> Starting Castar SDK setup..." \
    && echo ">>> Checking /app before extraction..." \
    && ls -R /app || echo "/app is empty" \
    && echo ">>> Downloading linux.zip..." \
    && curl -fsSL -A "Mozilla/5.0" https://file.castarsdk.net/linux.zip -o linux.zip \
    && echo ">>> Checking if linux.zip exists..." \
    && ls -lh linux.zip || (echo "linux.zip not found!" && exit 1) \
    && echo ">>> Listing contents of linux.zip..." \
    && unzip -l linux.zip \
    && echo ">>> Extracting linux.zip into /app..." \
    && unzip linux.zip -d /app \
    && echo ">>> Checking /app after extraction..." \
    && ls -R /app \
    && echo ">>> TARGETARCH is: $TARGETARCH" \
    && case "$TARGETARCH" in \
         amd64) echo ">>> Moving amd64 SDK..." && mv /app/linux-sdk/CastarSdk_amd64 /app/CastarSdk ;; \
         arm64) echo ">>> Moving arm64 SDK..." && mv /app/linux-sdk/CastarSdk_arm /app/CastarSdk ;; \
         *) echo "Unsupported architecture: $TARGETARCH" && exit 1 ;; \
       esac \
    && echo ">>> Checking /app before cleanup..." \
    && ls -R /app \
    && echo ">>> Setting executable permissions..." \
    && chmod +x /app/CastarSdk \
    && echo ">>> Cleaning up temporary files..." \
    && rm -rf linux.zip /app/linux-sdk \
    && echo ">>> Checking /app after cleanup..." \
    && ls -R /app \
    && echo ">>> Castar SDK setup complete."

COPY entrypoint.sh /entrypoint.sh

RUN dos2unix /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
