#!/bin/sh

git pull
sleep 3  # Pause de 3 secondes après le pull

chmod +x export/BillieBustUpArcade.arm64
chmod +x export/BillieBustUpArcade.sh
chmod +x export/BillieBustUpArcade.pck

sleep 3  # Pause de 3 secondes avant le lancement

.export/BillieBustUpArcade.sh
