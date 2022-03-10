#!/bin/bash
# 
# 
# 
# 

function INSTALL() {
apt update -y && apt upgrade -y;
apt install -y apt-transport-https ca-certificates curl software-properties-common;
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - && \
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable";
apt update && \
  apt-cache policy docker-ce && \
  apt install -y docker-ce;
  
curl -L "https://github.com/docker/compose/releases/download/1.26.0/docker-compose-$(uname -s)-$(uname -m)"  -o /usr/local/bin/docker-compose && \
  mv /usr/local/bin/docker-compose /usr/bin/docker-compose && \
  chmod +x /usr/bin/docker-compose;
apt install git && \
  git clone https://github.com/Arriven/db1000n.git;
cd db1000n;
  
#-----------------------------
cd openvpn && \
  provider01.txt && \
  provider01.endpoint01.conf && \
  provider01.endpoint02.conf
  
read -p "Login VPN: " VPNUser && ${VPNUser} >> provider01.txt
read -p "Login VPN: " VPNPass && ${VPNPass} >> provider01.txt

echo "VPN TCP"; sleep 5
if [ -f "./*.tcp.ovpn" ]; then
  cat "./*.tcp.ovpn" > provider01.endpoint01.conf
else
  cat "./*.tcp.ovpn"> provider01.endpoint01.conf <<EOF
# ==============================================================================
# Copyright (c) 2016-2020 Proton Technologies AG (Switzerland)
# Email: contact@protonvpn.com
#
# The MIT License (MIT)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR # OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.
# ==============================================================================

# The server you are connecting to is using a circuit in order to separate entry IP from exit IP
# The same entry IP allows to connect to multiple exit IPs in the same data center.

# If you want to explicitly select the exit IP corresponding to server NL-FREE#12 you need to
# append a special suffix to your OpenVPN username.
# Please use "ql28QnPs2pZqUdAd+b:0" in order to enforce exiting through NL-FREE#12.

# If you are a paying user you can also enable ProtonVPN ad blocker (NetShield).
# Use: "ql28QnPs2pZqUdAd+b:0+f1" to enable anti-malware filtering
# Use: "ql28QnPs2pZqUdAd+b:0+f2" to additionally enable ad-blocking filtering.

#==================================
# <<<<<<<<<CODE HEARE>>>>>>>>>>>>>>
#==================================
EOF;
fi;

echo "VPN UDP"; sleep 5
if [ -f "./*.udp.ovpn" ]; then
  cat ./*.udp.ovpn > provider01.endpoint02.conf
else
  cat> provider01.endpoint02.conf <<EOF
#==============================================================================
# Copyright (c) 2016-2020 Proton Technologies AG (Switzerland)
# Email: contact@protonvpn.com
#
# The MIT License (MIT)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR # OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.
# ==============================================================================

# The server you are connecting to is using a circuit in order to separate entry IP from exit IP
# The same entry IP allows to connect to multiple exit IPs in the same data center.

# If you want to explicitly select the exit IP corresponding to server NL-FREE#12 you need to
# append a special suffix to your OpenVPN username.
# Please use "ql28QnPs2pZqUdAd+b:0" in order to enforce exiting through NL-FREE#12.

# If you are a paying user you can also enable ProtonVPN ad blocker (NetShield).
# Use: "ql28QnPs2pZqUdAd+b:0+f1" to enable anti-malware filtering
# Use: "ql28QnPs2pZqUdAd+b:0+f2" to additionally enable ad-blocking filtering.
#==================================
# <<<<<<<<<CODE HEARE>>>>>>>>>>>>>>
#==================================
EOF;
fi;


cd ../ && \
  mv docker-compose.yml docker-compose.yml.init && \
  docker-compose.yml;
cat>> ./docker-compose.yml <<EOF
version: "3.3"

services:
  # creates OpenVPN Docker container to first provider, endpoint #1
  ovpn_01:
    image: ghcr.io/wfg/openvpn-client
    cap_add:
      - NET_ADMIN
    security_opt:
      - label:disable
    restart: unless-stopped
    volumes:
      - /dev/net:/dev/net:z
      - ./openvpn/:/data/vpn:z
    sysctls:
      - net.ipv6.conf.all.disable_ipv6=1
    environment:
      KILL_SWITCH: "on"
      HTTP_PROXY: "off"
      VPN_AUTH_SECRET: provider01_secret
      VPN_CONFIG_FILE: provider01.endpoint01.conf
    secrets:
      - provider01_secret

  # creates OpenVPN Docker container to first provider, endpoint #2
  ovpn_02:
    image: ghcr.io/wfg/openvpn-client
    cap_add:
      - NET_ADMIN
    security_opt:
      - label:disable
    restart: unless-stopped
    volumes:
      - /dev/net:/dev/net:z
      - ./openvpn/:/data/vpn:z
    sysctls:
      - net.ipv6.conf.all.disable_ipv6=1
    environment:
      KILL_SWITCH: "on"
      HTTP_PROXY: "off"
      VPN_AUTH_SECRET: provider01_secret
      VPN_CONFIG_FILE: provider01.endpoint02.conf
    secrets:
      - provider01_secret

 

  # this Docker container will use VPN 01
  db1000n_01:
    image: ghcr.io/arriven/db1000n-advanced
    restart: unless-stopped
    depends_on:
      - ovpn_01
    network_mode: "service:ovpn_01"

  # this Docker container will use VPN 02
  db1000n_02:
    image: ghcr.io/arriven/db1000n-advanced
    restart: unless-stopped
    depends_on:
      - ovpn_02
    network_mode: "service:ovpn_02"



secrets:
  provider01_secret:
    file: ./openvpn/provider01.txt
EOF;

}

INSTALL

# docker-compose up -d






#####################################################
# 
## Як перевірити, що все ок
## 1. Перевіряємо, що софт запущено
# docker ps
# 
## 1. Перевіряємо, що атака проходить успішно
# docker logs db1000n_db1000n_01_1
# 
#####################################################





