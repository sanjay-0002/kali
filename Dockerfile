FROM kalilinux/kali-rolling

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1

# Install XFCE + VNC + noVNC
RUN apt update -qq && apt upgrade -y -qq && \
    apt install -y --no-install-recommends \
    kali-linux-headless \
    kali-desktop-xfce \
    xfce4-terminal \
    tigervnc-standalone-server \
    tigervnc-common \
    novnc \
    websockify \
    dbus-x11 \
    nano wget curl procps iproute2 busybox && \
    apt clean && rm -rf /var/lib/apt/lists/*

# VNC password
RUN mkdir -p /root/.vnc && \
    echo "kali" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

# XFCE startup
RUN echo '#!/bin/sh' > /root/.vnc/xstartup && \
    echo 'unset SESSION_MANAGER' >> /root/.vnc/xstartup && \
    echo 'unset DBUS_SESSION_BUS_ADDRESS' >> /root/.vnc/xstartup && \
    echo 'exec startxfce4 &' >> /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

# Startup script
RUN echo '#!/bin/bash' > /start.sh && \
    echo 'set -e' >> /start.sh && \
    echo 'echo "Starting VNC server..."' >> /start.sh && \
    echo 'vncserver :1 -geometry 1280x800 -depth 24' >> /start.sh && \
    echo 'echo "Starting noVNC web access..."' >> /start.sh && \
    echo 'websockify --web=/usr/share/novnc/ 10000 localhost:5901 &' >> /start.sh && \
    echo 'exec busybox httpd -f -p 8080' >> /start.sh && \
    chmod +x /start.sh

EXPOSE 10000
EXPOSE 8080

CMD ["/start.sh"]
