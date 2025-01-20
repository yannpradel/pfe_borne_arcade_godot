import socket
import gpiod
import time

# Configuration des GPIO
LASER_PINS = [17, 27, 22]  # Exemple : GPIO 17, 27, 22
CHIP_NAME = "gpiochip0"  # Nom de la puce GPIO sur Raspberry Pi 5

# Initialisation des lignes GPIO
chip = gpiod.Chip(CHIP_NAME)
lines = [chip.get_line(pin) for pin in LASER_PINS]

for line in lines:
    line.request(consumer="laser_control", type=gpiod.LINE_REQ_DIR_OUT)
    line.set_value(0)  # Éteindre tous les lasers par défaut

# Configuration du serveur TCP
HOST = '0.0.0.0'  # Écoute sur toutes les interfaces
PORT = 12345  # Port de communication

server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.bind((HOST, PORT))
server.listen(5)

print(f"Serveur TCP en écoute sur {HOST}:{PORT}...")

try:
    while True:
        client, address = server.accept()
        print(f"Connexion établie avec {address}")
        
        data = client.recv(1024).decode('utf-8').strip()  # Réception des données
        if data:
            print(f"Données reçues : {data}")
            
            # Traitement des commandes
            # Exemple de commande : "LASER_ON 0" pour allumer le laser connecté à LASER_PINS[0]
            try:
                command, value = data.split()
                pin_index = int(value)
                if command == "LASER_ON":
                    lines[pin_index].set_value(1)  # Activer le laser
                    print(f"Laser {pin_index} activé")
                elif command == "LASER_OFF":
                    lines[pin_index].set_value(0)  # Désactiver le laser
                    print(f"Laser {pin_index} désactivé")
                else:
                    print(f"Commande inconnue : {command}")
            except (ValueError, IndexError):
                print(f"Erreur dans le traitement de la commande : {data}")
        
        client.close()
except KeyboardInterrupt:
    print("Arrêt du serveur")
finally:
    # Libérer toutes les lignes GPIO
    for line in lines:
        line.set_value(0)
        line.release()
    chip.close()
    server.close()
    print("GPIO et serveur TCP nettoyés.")