# RAK833-LoRaGateway-RPi - conf for loraserver

based on the latest SX1301 driver [lora_gateway](https://github.com/Lora-net/lora_gateway) v5.0.1 and semtech [packet_forwarder](https://github.com/Lora-net/packet_forwarder) v4.0.1  

Note: This project is only used for USB interface of RAK833 + Raspberry Pi, if you want to use SPI interface of RAK833 + Raspberry Pi, please use this project:
https://github.com/RAKWireless/RAK831-LoRaGateway-RPi. But you should notice the reset GPIO pin definition which is the value of SX1301_RESET_BCM_PIN macro in the start.sh file, it is pin17 now, and you can modify this value according to your hardware.

##	Installation procedure

step1 : Download and install [Raspbian Stretch LITE](https://www.raspberrypi.org/downloads/raspbian/) 


step2 : Clone the installer and start the installation

      $ git clone https://github.com/RAKWireless/RAK833-LoRaGateway-RPi.git ~/rak833-loragateway
      $ cd ~/rak833-loragateway
      $ sudo ./install.sh

step3 : Now you have a running gateway after restart! in additon you can check the log info at /var/log/syslog.
