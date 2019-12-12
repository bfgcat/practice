#!/bin/bash
sudo yum install docker -y
sudo systemctl enable docker.service
sudo systemctl start docker.service


cat << EOF > start-website
aws ecr get-login --no-include-email --region us-east-1 | bash
sudo docker run -p 3000:3000 [ADD_SERVER_ADDRESS_HERE]/example-webapp:release
EOF
sudo mv start-website /var/lib/cloud/scripts/per-boot/start-website
sudo chmod +x /var/lib/cloud/scripts/per-boot/start-website
/var/lib/cloud/scripts/per-boot/start-website
