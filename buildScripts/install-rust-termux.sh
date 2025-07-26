#!/data/data/com.termux/files/usr/bin/sh

# SETUP POINTLESS REPO

# Update and install required packages
apt-get update
apt-get --assume-yes upgrade
apt-get --assume-yes install coreutils gnupg apt-transport-https

# Create sources.list.d directory if it doesn't exist
mkdir -p $PREFIX/etc/apt/sources.list.d

# Write the appropriate source file based on the repository policy
if apt-cache policy | grep -q "termux.*24\|termux.org\|bintray.*24\|k51qzi5uqu5dg9vawh923wejqffxiu9bhqlze5f508msk0h7ylpac27fdgaskx"; then
  echo "deb https://its-pointless.github.io/files/24 termux extras" > $PREFIX/etc/apt/sources.list.d/pointless.list
else
  echo "deb https://its-pointless.github.io/files/21 termux extras" > $PREFIX/etc/apt/sources.list.d/pointless.list
fi

# Add the signing key from the pointless repository
if command -v curl > /dev/null; then
  curl -sLo $PREFIX/etc/apt/trusted.gpg.d/pointless.gpg --create-dirs https://its-pointless.github.io/pointless.gpg
elif command -v wget > /dev/null; then
  wget -qP $PREFIX/etc/apt/trusted.gpg.d https://its-pointless.github.io/pointless.gpg
fi

# Update apt
apt update

# Install development tools
pkg install -y rust libgcc build-essential binutils make

# Build Sonic
export RUSTFLAGS="-C link-args=-Wl,--allow-multiple-definition"
export TARGET_ARCH="aarch64-linux-android"

# Parse script arguments
while [ "$1" != "" ]; do
  argument_key=$(echo $1 | awk -F= '{print $1}')
  argument_value=$(echo $1 | awk -F= '{print $2}')
  case $argument_key in
    -g | --git)
      GIT_REPO="$argument_value"
      ;;
    *)
      echo "Unknown argument received: '$argument_key'"
      exit 1
      ;;
  esac
  shift
done

# Ensure Git repository is provided
if [ -z "$GIT_REPO" ]; then
  echo "No GitHub repository provided. Use '-g' or '--git' to specify it."
  exit 1
fi

# Extract project name from Git repository URL
project_name=$(basename "$GIT_REPO" .git)
echo "Project: $project_name"

# Clone repository if not already cloned
if [ ! -d "$project_name" ]; then
  echo "Cloning repository from $GIT_REPO..."
  git clone "$GIT_REPO"
fi

# Navigate to the project directory
pushd "$project_name" > /dev/null

# Define the release function
release_for_architecture() {
  local target_dir="target/$TARGET_ARCH/release"
  local final_tar="v${project_name}.tar.gz"

  cargo build --release --target "$TARGET_ARCH"
  mkdir -p release_output
  cp -p "$target_dir/$project_name" release_output/
  tar --owner=0 --group=0 -czvf "$final_tar" -C release_output .
  local release_result=$?

  if [ $release_result -eq 0 ]; then
    echo "Successfully packed: $final_tar"
  else
    echo "Error: Packing failed."
  fi

  return $release_result
}

# Execute the release process
echo "Building and packaging for $TARGET_ARCH..."
release_for_architecture
build_result=$?

# Clean up and exit
popd > /dev/null
exit $build_result
