FROM kalilinux/kali-rolling

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update and install basic utilities + openssh-server + curl (for sshx) + headless Kali tools
RUN apt update -qq && \
    apt upgrade -y -qq && \
    apt install -y --no-install-recommends \
        openssh-server \
        curl \
        ca-certificates \
        procps \
        iproute2 \
        nano \
        wget \
        kali-linux-headless && \
    # Clean up to keep image size smaller
    apt clean && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/* /tmp/* /var/tmp/*

# Configure SSH (for fallback / direct ssh if you ever need it)
RUN mkdir -p /var/run/sshd && \
    echo 'root:change-me-please' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    # SSH login fix (common requirement in Docker)
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# Create a simple startup script
RUN echo '#!/bin/bash' > /start.sh && \
    echo 'set -e' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# Optional: start normal sshd in background if you want direct ssh too' >> /start.sh && \
    echo '# /usr/sbin/sshd -D &' >> /start.sh && \
    echo '' >> /start.sh && \
    echo 'echo "Launching sshx..."' >> /start.sh && \
    echo 'echo "When you see the sshx link → copy & open it in your browser"' >> /start.sh && \
    echo 'sleep 2  # Short wait for network stability' >> /start.sh && \
    echo 'exec curl -sSf https://sshx.io/get | sh' >> /start.sh && \
    chmod +x /start.sh

# Expose SSH port (optional — only if you want direct ssh -p <hostport> root@<hostip>)
EXPOSE 22

# Start sshx by default
CMD ["/start.sh"]
