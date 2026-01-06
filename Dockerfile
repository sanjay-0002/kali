FROM kalilinux/kali-rolling

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update -qq && \
    apt upgrade -y -qq && \
    apt install -y --no-install-recommends \
        openssh-server \
        curl \
        kali-linux-headless && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /var/run/sshd && \
    echo 'root:root' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd

RUN echo '#!/bin/bash' > /start.sh && \
    echo 'echo "Kali VPS is ready!"' >> /start.sh && \
    echo 'echo "Your browser terminal link (open it now):"' >> /start.sh && \
    echo 'exec sshx' >> /start.sh && \
    chmod +x /start.sh

CMD ["/start.sh"]
