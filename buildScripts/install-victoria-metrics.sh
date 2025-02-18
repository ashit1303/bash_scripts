#!/data/data/com.termux/files/usr/bin/bash

# Step 1: Install dependencies
pkg update -y
pkg install -y wget tar curl make clang golang git

# Step 2: Detect architecture
ARCH=$(uname -m)
if [ "$ARCH" == "aarch64" ]; then
    VM_ARCH="arm64"
elif [ "$ARCH" == "armv7l" ]; then
    VM_ARCH="armv7"
elif [ "$ARCH" == "x86_64" ]; then
    VM_ARCH="amd64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

# Step 3: Download VictoriaMetrics binary (if available)
VM_VERSION="v1.99.0"  # Update to the latest version if needed
VM_URL="https://github.com/VictoriaMetrics/VictoriaMetrics/releases/download/$VM_VERSION/victoria-metrics-linux-$VM_ARCH.tar.gz"

wget "$VM_URL" -O victoria-metrics.tar.gz
if [ $? -eq 0 ]; then
    echo "✅ Downloaded VictoriaMetrics binary."
    tar -xzf victoria-metrics.tar.gz
    mkdir -p ~/.victoriametrics
    mv victoria-metrics-prod ~/.victoriametrics/victoria-metrics
    chmod +x ~/.victoriametrics/victoria-metrics
else
    echo "⚠️ Binary not available for this architecture. Building from source..."
    
    # Step 4: Build VictoriaMetrics from source
    export GOPATH=$HOME/go
    export PATH=$GOPATH/bin:$PATH
    mkdir -p $GOPATH/src/github.com/VictoriaMetrics
    cd $GOPATH/src/github.com/VictoriaMetrics
    git clone --depth=1 https://github.com/VictoriaMetrics/VictoriaMetrics.git
    cd VictoriaMetrics
    make victoria-metrics
    mkdir -p ~/.victoriametrics
    mv bin/victoria-metrics ~/.victoriametrics/
fi

# Step 5: Add to PATH
echo 'export PATH=$HOME/.victoriametrics:$PATH' >> ~/.bashrc
source ~/.bashrc

# Step 6: Verify installation
victoria-metrics --version

echo "✅ VictoriaMetrics installed successfully!"
