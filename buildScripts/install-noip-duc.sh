#!/bin/bash

# Exit on error
set -e

# Variables
NOIP_VERSION="2.1.9-1"
INSTALL_DIR="$PREFIX/bin"
BUILD_DIR="$PREFIX/tmp/noip-duc"
CONF_DIR="$PREFIX/etc"
INSTALL_DIR="/usr/local/bin"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root"
    exit 1
fi

# Install dependencies
echo "Installing dependencies..."
if command -v apt-get >/dev/null; then
    apt-get update
    apt-get install -y make gcc
elif command -v yum >/dev/null; then
    yum install -y make gcc
else
    echo "Unsupported package manager"
    exit 1
fi

# Create build directory
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Download and extract
echo "Downloading No-IP DUC..."
wget "http://www.no-ip.com/client/linux/noip-duc-linux.tar.gz"
tar xzf noip-duc-linux.tar.gz
cd "noip-$NOIP_VERSION"

# Build
echo "Building No-IP DUC..."
make

# Install
echo "Installing No-IP DUC..."
make install

# Create systemd service
cat > /etc/systemd/system/noip-duc.service <<EOF
[Unit]
Description=No-IP Dynamic Update Client
After=network.target

[Service]
Type=forking
ExecStart=/usr/local/bin/noip2
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd
systemctl daemon-reload

# Configure No-IP
echo "Configuring No-IP DUC..."
/usr/local/bin/noip2 -C

# Start service
echo "Starting No-IP DUC service..."
systemctl enable noip-duc
systemctl start noip-duc

# Cleanup
echo "Cleaning up..."
cd /
rm -rf "$BUILD_DIR"

# Verify installation
if systemctl is-active --quiet noip-duc; then
    echo "No-IP DUC installed and running successfully"
    echo "Service status:"
    systemctl status noip-duc
else
    echo "Installation completed but service failed to start"
    echo "Check logs with: journalctl -u noip-duc"
    exit 1
fi