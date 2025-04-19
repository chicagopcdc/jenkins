#!/bin/bash
sudo apt-get update -y
sudo apt-get upgrade -y
echo "Update system is finished." > /home/ubuntu/step_1.log

sudo apt-get install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io -y
echo "Install Docker is finished." > /home/ubuntu/step_2.log

sudo systemctl enable docker
sudo systemctl start docker
echo "Docker started." > /home/ubuntu/step_3.log

LOG_FILE="/home/ubuntu/jenkins_setup.log"
echo "==== PULL Jenkins Dockerfile ====" >> "$LOG_FILE"
git clone https://github.com/chicagopcdc/jenkins.git
cd jenkins

echo "==== Build Docker Image ====" >> "$LOG_FILE"
sudo docker build -t myjenkins-blueocean:2.440.1 . >> "$LOG_FILE" 2>&1
if [ $? -eq 0 ]; then
  echo "[✓] Docker image built successfully" >> "$LOG_FILE"
else
  echo "[✗] Failed to build Docker image" >> "$LOG_FILE"
fi

echo -e "\n==== Create Docker Network ====" >> "$LOG_FILE"
sudo docker network create jenkins >> "$LOG_FILE" 2>&1
if [ $? -eq 0 ]; then
  echo "[✓] Docker network 'jenkins' created" >> "$LOG_FILE"
else
  echo "[!] Docker network may already exist or creation failed" >> "$LOG_FILE"
fi

echo -e "\n==== Run Jenkins Container ====" >> "$LOG_FILE"
sudo docker run --name jenkins-blueocean --restart=on-failure --detach \
  --network jenkins --publish 8080:8080 --publish 50000:50000 \
  --volume jenkins-data:/var/jenkins_home \
  myjenkins-blueocean:2.440.1 >> "$LOG_FILE" 2>&1
if [ $? -eq 0 ]; then
  echo "[✓] Jenkins container started" >> "$LOG_FILE"
else
  echo "[✗] Failed to start Jenkins container" >> "$LOG_FILE"
fi

echo -e "\n[✔] Docker setup script completed at $(date)" >> "$LOG_FILE"