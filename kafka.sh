#!/bin/bash
sudo apt-get update
if ! dpkg -l | grep -q "python3"; then
  sudo apt-get install -y python3
else
  echo "Package 'python3' is already installed"
fi
if ! dpkg -l | grep -q "python3-pip"; then
  sudo apt-get install -y python3-pip
else
  echo "Package 'python3-pip' is already installed"
fi
if ! dpkg -l | grep -q "docker"; then
  sudo apt-get install -y docker
else
  echo "Package 'docker' is already installed"
fi
if ! dpkg -l | grep -q "docker-compose"; then
  sudo apt-get install -y docker-compose
else
  echo "Package 'docker-compose' is already installed"
fi
cd /home/osboxes/kafka-docker
sudo python3  -m venv venv
sudo source venv/bin/activate
if ! pip3 show kafka-python > /dev/null; then
  sudo pip3 install kafka-python
else
  echo "Package 'kafka-python' is already installed"
fi

if [ -d "kafka-docker" ]; then
  sudo rm -rf kafka-docker
fi
sudo git clone https://github.com/wurstmeister/kafka-docker.git
cd kafka-docker/
filename="docker-compose-expose.yml"
cat << EOF > $filename
version: '2'
services:
  zookeeper:
    image: wurstmeister/zookeeper:3.4.6
    ports:
     - "2181:2181"
  kafka:
    image: wurstmeister/kafka
    depends_on:
    - zookeeper
    ports:
     - "9092:9092"
    expose:
     - "9093"
    environment:
      KAFKA_ADVERTISED_LISTENERS: INSIDE://kafka:9093,OUTSIDE://localhost:9092
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: INSIDE:PLAINTEXT,OUTSIDE:PLAINTEXT
      KAFKA_LISTENERS: INSIDE://0.0.0.0:9093,OUTSIDE://0.0.0.0:9092
      KAFKA_INTER_BROKER_LISTENER_NAME: INSIDE
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_CREATE_TOPICS: "topic_test:1:1"
    volumes:
     - /var/run/docker.sock:/var/run/docker.sock   k
EOF
echo "YAML file $filename has been created."
sudo docker-compose -f docker-compose-expose.yml up


