FROM ubuntu:24.04

# Set working directory
WORKDIR /app

# Install required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        unzip \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Download and extract only the amd64 binary
RUN curl -fsSL https://download.castarsdk.com/linux.zip -o linux.zip \
    && unzip linux.zip -d /app \
    && mv /app/linux-sdk/CastarSdk_amd64 /app/ \
    && rm -rf linux.zip /app/linux-sdk \
    && chmod +x /app/CastarSdk_amd64

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Default entrypoint
ENTRYPOINT ["/entrypoint.sh"]
