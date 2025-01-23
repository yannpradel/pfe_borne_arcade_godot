#!/bin/sh
git pull
sleep 3
chmod +x ./export/BillieBustUpArcade.arm64
chmod +x ./export/BillieBustUpArcade.sh
chmod +x ./export/BillieBustUpArcade.pck
./export/BillieBustUpArcade.sh
python ../python\ udp/tcp_for_serial.py