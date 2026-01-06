FROM kalilinux/kali-rolling

ENV DEBIAN_FRONTEND=noninteractive

# Install essentials + busybox (for httpd) + Kali headless tools
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
    # Download and install sshx binary during build (cached, fast)
    curl -sSf https://sshx.io/get | sh && \
    # Clean up to minimize size
    apt clean && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/* /tmp/* /var/tmp/*

# Optional: SSH config for fallback direct access
RUN mkdir -p /var/run/sshd && \
    echo 'root:root' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# Startup script
RUN echo '#!/bin/bash' > /start.sh && \
    echo 'set -e' >> /start.sh && \
    echo 'echo "Kali VPS is ready!"' >> /start.sh && \
    echo 'echo "Launching sshx session... (check logs for the https://sshx.io/s/... link)"' >> /start.sh && \
    echo 'sshx &' >> /start.sh && \
    echo 'echo "Container alive - HTTP server running on port 10000 (for Render health check)"' >> /start.sh && \
    echo '# Busybox httpd in foreground, no -h flag needed (uses cwd /)' >> /start.sh && \
    echo 'exec busybox httpd -f -p 10000' >> /start.sh && \
    chmod +x /start.sh

# Tell Render the port (though it auto-detects)
EXPOSE 10000

CMD ["/start.sh"]
