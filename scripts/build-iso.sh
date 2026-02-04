#!/bin/bash
set -e

# Configuration
LOGFILE="${PROJECT_DIR}/iso_build.log"
exec > >(tee -a "$LOGFILE") 2>&1

ALPINE_VERSION="3.19.1"
ALPINE_ISO_URL="https://dl-cdn.alpinelinux.org/alpine/v3.19/releases/x86_64/alpine-standard-${ALPINE_VERSION}-x86_64.iso"
PROJECT_DIR="/mnt/d/Github_Projects/Simple-Server"
WORK_DIR="${PROJECT_DIR}/build-iso"
OUTPUT_ISO="${PROJECT_DIR}/simple-server-os.iso"

# Cleanup
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR/overlay/etc/local.d" "$WORK_DIR/overlay/usr/bin" "$WORK_DIR/overlay/etc/simple-server"

echo "=== Building Simple-Server OS ==="

# 1. Prepare Overlay
echo "[+] Preparing System Overlay..."
# Copy Server Binary
if [ ! -f "${PROJECT_DIR}/server" ]; then
    echo "Error: '${PROJECT_DIR}/server' not found. Run 'make build' first."
    exit 1
fi
cp "${PROJECT_DIR}/server" "$WORK_DIR/overlay/usr/bin/server"
chmod +x "$WORK_DIR/overlay/usr/bin/server"

# Copy Logo
if [ -f "${PROJECT_DIR}/Logo.png" ]; then
    cp "${PROJECT_DIR}/Logo.png" "$WORK_DIR/overlay/etc/simple-server/logo.png"
fi

# Create Boot Script
cat <<EOF > "$WORK_DIR/overlay/etc/local.d/simple-server.start"
#!/bin/sh
echo "-----------------------------------------------------"
echo "   WELCOME TO SIMPLE-SERVER OS"
echo "-----------------------------------------------------"
# Display Logo (Mockup for now, real logo is in /etc/simple-server/logo.png)
if [ -f /etc/simple-server/logo.png ]; then
    echo "Logo loaded at /etc/simple-server/logo.png"
fi
echo "Starting Simple-Server on port 80..."
# Run in background
nohup /usr/bin/server > /var/log/server.log 2>&1 &
EOF
chmod +x "$WORK_DIR/overlay/etc/local.d/simple-server.start"

# Create hostname
echo "simple-server" > "$WORK_DIR/overlay/etc/hostname"

# enable local service
mkdir -p "$WORK_DIR/overlay/etc/runlevels/default"
ln -sf /etc/init.d/local "$WORK_DIR/overlay/etc/runlevels/default/local"

# Pack the overlay (localhost.apkovl.tar.gz)
echo "[+] Packing Overlay..."
cd "$WORK_DIR/overlay"
tar -czf "$WORK_DIR/localhost.apkovl.tar.gz" .
cd "$PROJECT_DIR"

# 2. Prepare ISO
echo "[+] Downloading Alpine Linux ISO..."
if [ ! -f "${WORK_DIR}/alpine.iso" ]; then
    wget -q --show-progress -O "${WORK_DIR}/alpine.iso" "$ALPINE_ISO_URL"
fi

echo "[+] Injecting Overlay into ISO..."
# Using xorriso to create a new ISO based on the original, adding our overlay file
xorriso -indev "${WORK_DIR}/alpine.iso" \
        -outdev "$OUTPUT_ISO" \
        -boot_image any keep \
        -add "$WORK_DIR/localhost.apkovl.tar.gz" -- \
        -compliance joliet_long_names \
        -volid "SIMPLE_OS"

echo "=== Build Complete ==="
echo "ISO Image Created: $OUTPUT_ISO"
echo "Burn this to a USB drive with Rufus or Etcher."
