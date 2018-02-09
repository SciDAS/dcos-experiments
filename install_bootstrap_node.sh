#!/usr/bin/env bash

sudo yum upgrade --assumeyes --tolerant
sudo yum update --assumeyes

sudo tee /etc/modules-load.d/overlay.conf <<-'EOF'
overlay
EOF
sudo modprobe overlay

sudo tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/$releasever/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF

sudo mkdir -p /etc/systemd/system/docker.service.d && sudo tee /etc/systemd/system/docker.service.d/override.conf <<- EOF
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd --storage-driver=overlay
EOF

sudo yum install -y docker-engine-1.13.1 docker-engine-selinux-1.13.1
sudo systemctl start docker
sudo systemctl enable docker

curl -O https://downloads.dcos.io/dcos/stable/dcos_generate_config.sh

sudo bash dcos_generate_config.sh --web
