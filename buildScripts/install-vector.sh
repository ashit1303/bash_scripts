#!/data/data/com.termux/files/usr/bin/bash

# Step 1: Install dependencies
pkg update -y
pkg install -y wget tar curl

# Step 2: Detect architecture
ARCH=$(uname -m)
if [ "$ARCH" == "aarch64" ]; then
    VECTOR_ARCH="aarch64-unknown-linux-musl"
elif [ "$ARCH" == "armv7l" ]; then
    VECTOR_ARCH="armv7-unknown-linux-musleabihf"
elif [ "$ARCH" == "x86_64" ]; then
    VECTOR_ARCH="x86_64-unknown-linux-musl"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

# Step 3: Download Vector binary
VECTOR_VERSION="0.35.0"  # Update to latest if needed
VECTOR_URL="https://packages.timber.io/vector/$VECTOR_VERSION/vector-$VECTOR_ARCH.tar.gz"
wget "$VECTOR_URL" -O vector.tar.gz

# Step 4: Extract and move binary
tar -xzf vector.tar.gz
mkdir -p ~/.vector
mv vector-*/bin/vector ~/.vector/vector
chmod +x ~/.vector/vector

# Step 5: Create a basic config file
cat > ~/.vector/vector.toml <<EOF
[sources.stdin]
type = "stdin"

[sinks.console]
type = "console"
inputs = ["stdin"]
encoding.codec = "json"
EOF

# Step 6: Add Vector to PATH
echo 'export PATH=$HOME/.vector:$PATH' >> ~/.bashrc
source ~/.bashrc

# Step 7: Verify installation
vector --version

echo "Vector installed successfully!"