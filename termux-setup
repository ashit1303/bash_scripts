#!/data/data/com.termux/files/usr/bin/bash

# INSTALL NODEJS MARIADB ZINCSEARCH

# Function to print messages
print_message() {
    echo -e "\n\e[1;32m$1\e[0m\n"
}

# Update and upgrade packages
print_message "Updating and upgrading packages..."
pkg update -y && pkg upgrade -y

# Install necessary packages
print_message "Installing necessary packages..."
pkg install root-repo -y
pkg install tsu figlet openssh git curl tree wget nano nodejs termux-services iptables -y
# Install MariaDB
print_message "Installing MariaDB..."
pkg install -y mariadb

#Setting up termux
print_message "Setting up termux..."

# installing zincsearch 
curl -L https://raw.githubusercontent.com/ashit1303/termux-zincsearch-install/main/termux-zincsearch-install.sh > termux-zincsearch-install.sh
chmod +x termux-zincsearch-install.sh
./termux-zincsearch-install.sh
INC_FIRST_ADMIN_USER=admin ZINC_FIRST_ADMIN_PASSWORD=your_password zincsearch


echo "figlet -f slant 'Termux'" >> ../bash.bashrc
echo "PS1='\[\e[1;32m\]\u@\h:\[\e[0m\]\[\e[1;34m\]$(if [[ "$PWD" == "$HOME/" ]]; then echo "~/"; else echo "~/\W"; fi)\[\e[0m\]\$' " >> ../bash.bashrc

# Initialize Mariadb data directory
print_message "Initializing Mariadb data directory..."
mariadb_install_db

# Install termux-services
print_message "Installing termux-services..."
pkg install -y termux-services

# Create boot directory if it doesn't exist
BOOT_DIR="$HOME/.termux/boot"
print_message "Creating boot directory if it doesn't exist..."
mkdir -p "$BOOT_DIR"

sshd
termux-wake-lock
termux-setup-storage

# Create the startup script
STARTUP_SCRIPT="$BOOT_DIR/start-servers.sh"
print_message "Creating startup script..."
cat > "$STARTUP_SCRIPT" <<EOF
#!/data/data/com.termux/files/usr/bin/bash
termux-wake-lock  # Prevent device from sleeping
sshd & # Start SSH server
mariadbd_safe & # Start Mariadb
zincsearch & # Start ZincSearch
EOF


# Make the script executable
print_message "Making the script executable..."
chmod +x "$STARTUP_SCRIPT"

# Test the script
print_message "Testing the startup script..."
"$STARTUP_SCRIPT"

# Verify Mariadb is running
print_message "Verifying Mariadb is running..."
if mariadb-admin ping &>/dev/null; then
    echo "Mariadb is running successfully!"
else
    echo "Mariadb failed to start. Check the script and logs."
fi

print_message "Setup complete! Reboot your device to confirm automatic startup."

# exposing 3306 & 4080 port if root access avaialable
print_message "Exposing 3306 port..."
sudo iptables -A INPUT -p tcp --dport 3306 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 4080 -j ACCEPT
