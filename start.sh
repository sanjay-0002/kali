#!/usr/bin/env bash
set -euo pipefail

# ────────────────────────────────────────────────────────────────────────────────
#  Kali (headless/no GUI) + sshx container launcher
#  (browser-based terminal via sshx.io)
# ────────────────────────────────────────────────────────────────────────────────

IMAGE_NAME="kali-sshx"
CONTAINER_NAME="kali-sshx"

echo "Kali Linux (headless) + sshx container manager"
echo "──────────────────────────────────────────────"
echo ""

# Build or rebuild the image
echo "Building/rebuilding image..."
docker build -t "${IMAGE_NAME}" .

echo "Launching container..."
echo "  • When ready → sshx will print a link like https://sshx.io/s/xxxx-xxxx"
echo "  • Open that link in any browser → instant shared terminal (root access)"
echo "  • Tip: Change root password immediately with 'passwd'"
echo ""

docker run -it --rm \
  --name "${CONTAINER_NAME}" \
  --cap-add=NET_ADMIN \
  --cap-add=SYS_PTRACE \
  --privileged \
  -v ~/kali-data:/root/shared \
  "${IMAGE_NAME}"

# If the container exits, show a short message
echo ""
echo "Container stopped."
echo "Run ./start.sh again for a new session."
