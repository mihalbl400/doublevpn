#!/bin/bash

###################
rm -R /root/doublevpn &> /dev/null
rm -R /root/1.sh &> /dev/null
rm -R /var/lib/openvpn &> /dev/null
###################
# Install ansible #
#if ! grep -q "ansible/ansible" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
#    echo "Adding Ansible PPA"
#    apt-add-repository ppa:ansible/ansible -y
#fi
#
#if ! hash ansible >/dev/null 2>&1; then
#    echo "Installing Ansible..."
    apt-get update
    apt-get install software-properties-common ansible git curl sshpass python-apt -y
#else
#    echo "Ansible already installed"
#fi

git clone https://github.com/mihalbl400/doublevpn.git && cd /root/doublevpn/

ansible-playbook gen_conf.yml
echo "Please wait..."
ansible-playbook main.yml

CNF=$(cat  /root/doublevpn/wg-client.conf);
MYIP=$(curl -4 https://icanhazip.com/);

#docker
curl -fsSL https://get.docker.com/ | sh
sudo systemctl start docker
sudo systemctl enable docker

sudo mkdir -p /var/lib/openvpn/mongodb
sudo docker rm -f openvpn &> /dev/null
sudo docker run \
    --name openvpn \
    --privileged \
    --detach \
    --privileged \
    --restart=always \
    --net=host \
    -v /var/lib/openvpn/mongodb:/var/lib/mongodb\
    -v /var/lib/openvpn:/var/lib/pritunl \
      jippi/pritunl

echo " If you want to use wireguard, copy this text"
echo "#####################################################################################################################"
echo "$CNF"
echo "#####################################################################################################################"
echo "If you want to use OpenVPN"
echo "open in web browser    :  https://$MYIP"
echo "Enter login/password   :  pritunl/pritunl"

rm -R /root/doublevpn &> /dev/null
rm -R /root/1.sh &> /dev/null
