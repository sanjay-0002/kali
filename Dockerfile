FROM kalilinux/kali-rolling

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update -qq && \
    apt upgrade -y -qq && \
    apt install -y --no-install-recommends \
        curl \
        ca-certificates \
        procps \
        iproute2 \
        nano \
        wget \
        busybox \
        kali-linux-headless && \
    # Install sshx binary once during build
    curl -sSf https://sshx.io/get | sh && \
    # Clean up
    apt clean && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/* /tmp/* /var/tmp/*

# Optional SSH fallback config
RUN mkdir -p /var/run/sshd && \
    echo 'root:change-me-please' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# Startup script: launch sshx in background + keep-alive HTTP server
RUN echo '#!/bin/bash' > /start.sh && \
    echo 'set -e' >> /start.sh && \
    echo 'echo "Kali VPS is ready!"' >> /start.sh && \
    echo 'echo "Launching sshx session... (check logs for the link)"' >> /start.sh && \
    echo 'sshx &' >> /start.sh && \
    echo 'echo "Container alive - waiting for connections (HTTP on port 10000 for Render)"' >> /start.sh && \
    echo 'exec busybox httpd -f -p 10000 -h /dev/null' >> /start.sh && \
    chmod +x /start.sh

EXPOSE 10000

CMD ["/start.sh"]
