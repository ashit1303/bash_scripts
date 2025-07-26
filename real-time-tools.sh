#!/bin/bash

set -e

USER=$(whoami)
DATA_DIR="/home/$USER/real-time-tools"
JAVA_HOME_PATH="/usr/lib/jvm/java-17-openjdk-amd64"
FLINK_VERSION="1.20.0"
FLINK_DIR="flink-$FLINK_VERSION"
KAFKA_VERSION="3.9.1"
KAFKA_DIR="kafka-$KAFKA_VERSION"
QUESTDB_VERSION="9.0.1"
QUESTDB_DIR="questdb-$QUESTDB_VERSION"

# Create log directory
sudo mkdir -p /var/log/real-time-tools
sudo apt update -y
sudo apt install python3-pip -y
sudo chown "$USER:$USER" /var/log/real-time-tools

echo "Setting up Java..."

JAVA_VERSION=$(java -version 2>&1 | head -n1 | awk -F[\".] '{print $2}')

if [ "$JAVA_VERSION" != "17" ]; then
    echo "Installing Java 17..."
    sudo apt remove --purge -y openjdk*
    sudo apt autoremove -y
    sudo rm -rf /usr/lib/jvm/java*

    sudo apt update
    sudo apt install -y openjdk-17-jdk

    if [ -f "$HOME/.bashrc" ]; then
        if ! grep -q "JAVA_HOME=" "$HOME/.bashrc"; then
            echo "export JAVA_HOME=$JAVA_HOME_PATH" >> "$HOME/.bashrc"
            echo 'export PATH="$JAVA_HOME/bin:$PATH"' >> "$HOME/.bashrc"
        fi
    elif [ -f "$HOME/.zshrc" ]; then
        if ! grep -q "JAVA_HOME=" "$HOME/.zshrc"; then
            echo "export JAVA_HOME=$JAVA_HOME_PATH" >> "$HOME/.zshrc"
            echo 'export PATH="$JAVA_HOME/bin:$PATH"' >> "$HOME/.zshrc"
        fi
    fi

    export JAVA_HOME=$JAVA_HOME_PATH
    export PATH="$JAVA_HOME/bin:$PATH"

    echo "Java 17 installed successfully"
else
    echo "Java 17 is already installed"
fi

mkdir -p "$DATA_DIR"
cd "$DATA_DIR"

setup_component() {
  local NAME=$1
  local VERSION=$2
  local DIR=$3
  local TARBALL=$4
  local BASE_URL=$5

  local TGZ="${TARBALL}.tgz"
  local SHA="${TGZ}.sha512"

  echo "Checking $NAME..."

  if [ -d "$DIR" ]; then
    echo "$NAME already installed at $DIR."
    return
  fi

  wget -q "$BASE_URL/$SHA" -O "$SHA"

  if [ "$NAME" = "Kafka" ]; then
    CHECKSUM=$(tr -d ' \n' < "$SHA" | sed 's/^.*://;s/.*/\L&/')
    echo "$CHECKSUM  $TGZ" > "$SHA"
  fi

  if [ -f "$TGZ" ]; then
    if sha512sum -c "$SHA" --status; then
      echo "$NAME archive valid, extracting..."
      tar -xzf "$TGZ"
      [ "$NAME" != "Flink" ] && mv "$TARBALL" "$DIR"
      rm "$TGZ"
      return
    else
      echo "$NAME archive checksum failed, re-downloading..."
      rm "$TGZ"
    fi
  fi

  wget --progress=bar:force "$BASE_URL/$TGZ"
  sha512sum -c "$SHA" || { echo "$NAME checksum failed"; exit 1; }

  tar -xzf "$TGZ"
  [ "$NAME" != "Flink" ] && mv "$TARBALL" "$DIR"
  rm "$TGZ"
  echo "$NAME installed successfully."
}

# Check if MongoDB is already installed
if ! command -v mongod &> /dev/null; then
    echo "Installing MongoDB..."
    curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
    sudo apt update
    sudo apt-get install -y mongodb-org

    # Start and enable MongoDB service
    sudo systemctl start mongod
    sudo systemctl enable mongod
    echo "MongoDB installed and started successfully"
else
    echo "MongoDB is already installed"
    # Ensure MongoDB is running
    if ! sudo systemctl is-active --quiet mongod; then
        echo "Starting MongoDB service..."
        sudo systemctl start mongod
        sudo systemctl enable mongod
    fi
fi


# Check if EMQX is already installed
if ! command -v emqx &> /dev/null; then
    echo "Installing EMQX..."
    #Add repo 
    sudo apt update && curl -s https://assets.emqx.com/scripts/install-emqx-deb.sh | sudo bash && sudo apt-get install emqx
    echo "EMQX installed successfully"
    # sudo systemctl enable EMQX
    sudo systemctl start emqx
    sleep 2
else
    echo "EMQX is already installed"
    # sudo systemctl enable EMQX
    sudo systemctl start emqx
    sleep 2
fi

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

export NVM_DIR="$HOME/.nvm"
# Load nvm immediately in this shell
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

nvm install 22

# Kafka
setup_component "Kafka" "$KAFKA_VERSION" "$KAFKA_DIR" "kafka_2.12-$KAFKA_VERSION" "https://dlcdn.apache.org/kafka/$KAFKA_VERSION"

# Flink
setup_component "Flink" "$FLINK_VERSION" "$FLINK_DIR" "flink-$FLINK_VERSION-bin-scala_2.12" "https://dlcdn.apache.org/flink/flink-$FLINK_VERSION"

WSL_IP=$(ip addr show eth0 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
echo "listeners=PLAINTEXT://0.0.0.0:9092" >> "$DATA_DIR/$KAFKA_DIR/config/server.properties"
echo "advertised.listeners=PLAINTEXT://$WSL_IP:9092" >> "$DATA_DIR/$KAFKA_DIR/config/server.properties"

sed -i'' -E 's/^( *address:).*/\1 0.0.0.0/' "$DATA_DIR/$FLINK_DIR/conf/config.yaml"
sed -i'' -E 's/^( *bind-host:).*/\1 0.0.0.0/' "$DATA_DIR/$FLINK_DIR/conf/config.yaml"
sed -i'' -E 's/^( *bind-address:).*/\1 0.0.0.0/' "$DATA_DIR/$FLINK_DIR/conf/config.yaml"

#Install QuestDB

# Check if QuestDB is already installed
if ! command -v questdb &> /dev/null; then
    echo "Installing QuestDB..."
    # https://github.com/questdb/questdb/releases/download/9.0.1/questdb-9.0.1-no-jre-bin.tar.gz
    curl -L "https://github.com/questdb/questdb/releases/download/$QUESTDB_VERSION/questdb-$QUESTDB_VERSION-no-jre-bin.tar.gz" -o questdb.tar.gz
    tar -xzf questdb.tar.gz
    rm questdb.tar.gz
    mv questdb-$QUESTDB_VERSION-no-jre-bin "$QUESTDB_DIR"
    echo "QuestDB installed successfully"
else
    echo "QuestDB is already installed"
fi


# Create startup script
cat <<EOF > "$DATA_DIR/start_data_pipes.sh"
#!/bin/bash
set -e
DATA_DIR="\$(dirname "\$0")"
WSL_IP=\$(ip addr show eth0 | grep 'inet ' | awk '{print \$2}' | cut -d/ -f1)
CONFIG="\$DATA_DIR/kafka-$KAFKA_VERSION/config/server.properties"
sed -i '/^listeners=/c\listeners=PLAINTEXT://0.0.0.0:9092' "\$CONFIG"
sed -i "/^advertised.listeners=/c\\advertised.listeners=PLAINTEXT://\$WSL_IP:9092" "\$CONFIG"
"\$DATA_DIR/kafka-$KAFKA_VERSION/bin/zookeeper-server-start.sh" "\$DATA_DIR/kafka-$KAFKA_VERSION/config/zookeeper.properties" &
sleep 6
"\$DATA_DIR/$QUESTDB_DIR/bin/start-questdb.sh" &
sleep 6
"\$DATA_DIR/kafka-$KAFKA_VERSION/bin/kafka-server-start.sh" "\$DATA_DIR/kafka-$KAFKA_VERSION/config/server.properties" &
sleep 6
"\$DATA_DIR/$FLINK_DIR/bin/start-cluster.sh"
$DATA_DIR/kafka-$KAFKA_VERSION/bin/kafka-topics.sh --create \
  --topic local-iot-data \
  --bootstrap-server localhost:9092 \
  --partitions 3 \
  --replication-factor 1 || true

EOF

# Create stop script
cat <<EOF > "$DATA_DIR/stop_data_pipes.sh"
#!/bin/bash
set -e
DATA_DIR="\$(dirname "\$0")"

# Resolved during file creation (global vars)
"$DATA_DIR/$FLINK_DIR/bin/stop-cluster.sh"
"$DATA_DIR/$KAFKA_DIR/bin/kafka-server-stop.sh"
"$DATA_DIR/$KAFKA_DIR/bin/zookeeper-server-stop.sh"
"$DATA_DIR/$QUESTDB_DIR/bin/stop-questdb.sh"
EOF

chmod +x "$DATA_DIR/start_data_pipes.sh"
chmod +x "$DATA_DIR/stop_data_pipes.sh"

# Create systemd service
sudo tee /etc/systemd/system/real-time-tools.service > /dev/null <<EOF
[Unit]
Description=Data Pipes Stack
After=network.target

[Service]
User=$USER
Environment=JAVA_HOME=$JAVA_HOME_PATH
WorkingDirectory=$DATA_DIR
Type=oneshot
RemainAfterExit=true
ExecStart=$DATA_DIR/start_data_pipes.sh
ExecStop=$DATA_DIR/stop_data_pipes.sh

StandardOutput=append:/var/log/real-time-tools/webserver.log
StandardError=append:/var/log/real-time-tools/webserver.err

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
# sudo systemctl enable emqx

#sudo systemctl enable real-time-tools
echo "Command summary: "
echo "To start real-time-tools: sudo systemctl start real-time-tools"
echo "To stop real-time-tools: sudo systemctl stop real-time-tools"
sleep 2

echo "Do you want to start EMQX | FLINK | KAFKA | QuestDB | MongoDB on startup? (y/n):"
read -n 1 -s start_on_startup
if [ "$start_on_startup" = "y" ]; then
    sudo systemctl enable emqx
    sudo systemctl start emqx
    sudo systemctl enable mongod
    sudo systemctl start mongod
    sudo systemctl enable real-time-tools
    sudo systemctl start real-time-tools
fi

echo "----------------------------------------------------"
echo "Real Time tools setup completed successfully."
echo "Go to http://localhost:8081 to access the flink web interface."
echo "Go to http://localhost:9000 to access the QuestDB web interface."  

set +e 
sudo apt install podman -y
sudo mkdir -p /etc/containers
echo -e "[registries.search]\nregistries = ['docker.io']" | sudo tee /etc/containers/registries.conf >/dev/null
podman run -d --name kafka-ui -p 8002:8080 -e DYNAMIC_CONFIG_ENABLED=true provectuslabs/kafka-ui
echo "podman start kafka-ui # run this to start kafka ui and use ipconfig ip to access kafka running on localhost"

echo "Download the MQTTX client from https://mqttx.app/downloads"
echo "Go to http://localhost:8082 to access the kafka web interface."