#!/bin/sh

git pull
sleep 3  # Pause de 3 secondes après le pull

chmod +x BillieBustUpArcade.arm64
chmod +x BillieBustUpArcade.sh
chmod +x BillieBustUpArcade.pck

sleep 3  # Pause de 3 secondes avant le lancement

./BillieBustUpArcade.sh
