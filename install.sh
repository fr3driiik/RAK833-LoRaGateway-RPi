#!/bin/bash

# Stop on the first sign of trouble
set -e

if [ $UID != 0 ]; then
    echo "ERROR: Operation not permitted. Forgot sudo?"
    exit 1
fi

SCRIPT_DIR=$(pwd)
pushd $SCRIPT_DIR

INSTALL_DIR="$SCRIPT_DIR/LoRa"
if [ ! -d "$INSTALL_DIR" ]; then mkdir $INSTALL_DIR; fi
pushd $INSTALL_DIR

echo "LoRaWAN Gateway installer"

GATEWAY_EUI=$(cat /sys/class/net/eth0/address | sed 's/://g') #mac from miips
GATEWAY_EUI="effe$GATEWAY_EUI"
#GATEWAY_EUI=${GATEWAY_EUI^^} # toupper

echo "USING $GATEWAY_EUI as gateway EUI."

# Check dependencies
echo "Installing dependencies..."
apt-get -y install git libftdi-dev libusb-dev

# Build libraries

git clone https://github.com/devttys0/libmpsse.git
pushd libmpsse/src
./configure --disable-python
make
make install
ldconfig
popd

# Build LoRa gateway app

git clone https://github.com/Lora-net/lora_gateway.git

pushd lora_gateway

cp ./libloragw/99-libftdi.rules /etc/udev/rules.d/99-libftdi.rules
cp $SCRIPT_DIR/loragw_spi.ftdi.c ./libloragw/src/
cp $SCRIPT_DIR/Makefile-gw-lib ./libloragw/Makefile
cp $SCRIPT_DIR/Makefile-lbt-test ./util_lbt_test/Makefile
cp $SCRIPT_DIR/Makefile-pkt-logger ./util_pkt_logger/Makefile
cp $SCRIPT_DIR/Makefile-spectral-scan ./util_spectral_scan/Makefile
cp $SCRIPT_DIR/Makefile-spi-stress ./util_spi_stress/Makefile
cp $SCRIPT_DIR/Makefile-tx-continuous ./util_tx_continuous/Makefile
cp $SCRIPT_DIR/Makefile-tx-test ./util_tx_test/Makefile
cp $SCRIPT_DIR/library.cfg ./libloragw/
cp $SCRIPT_DIR/Makefile-gw ./Makefile

make
popd

# Build packet forwarder

git clone https://github.com/Lora-net/packet_forwarder.git
pushd packet_forwarder

cp $SCRIPT_DIR/Makefile-pk ./lora_pkt_fwd/Makefile

make

popd


LOCAL_CONFIG_FILE=$INSTALL_DIR/packet_forwarder/lora_pkt_fwd/local_conf.json

#config local_conf.json
echo -e "{\n\t\"gateway_conf\": {\n\t\t\"gateway_ID\": \"$GATEWAY_EUI\",\n\t\t\"server_address\": \"server_address\",\n\t\t\"serv_port_up\": 1700,\n\t\t\"serv_port_down\": 1700\n\t}\n}" >$LOCAL_CONFIG_FILE

echo "Installation completed."

#update service file
WORKING_DIR="$INSTALL_DIR/packet_forwarder/lora_pkt_fwd/"
EXEC_START="$INSTALL_DIR/packet_forwarder/lora_pkt_fwd/lora_pkt_fwd"

sed -i -e "s/WORKING_DIRECTORY/$WORKING_DIR/g" $SCRIPT_DIR/lora-packet-forwarder.service
sed -i -e "s/EXEC_START/$EXEC_START/g" $SCRIPT_DIR/lora-packet-forwarder.service

cp $SCRIPT_DIR/lora-packet-forwarder.service /lib/systemd/system/
systemctl enable lora-packet-forwarder.service
