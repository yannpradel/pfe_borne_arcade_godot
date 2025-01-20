import socket
import gpiod

# Configuration des GPIO
LASER_PINS = [17, 27, 22]  # Exemple : GPIO 17, 27, 22
CHIP_NAME = "gpiochip0"  # Nom de la puce GPIO sur Raspberry Pi 5

# Initialisation des lignes GPIO
chip = gpiod.Chip(CHIP_NAME)
lines = [chip.get_line(pin) for pin in LASER_PINS]

for line in lines:
    line.request(consumer="laser_control", type=gpiod.LINE_REQ_DIR_OUT)
    line.set_value(0)  # Éteindre tous les lasers par défaut

# Configuration du client TCP
SERVER_IP = '127.0.0.1'  # Adresse IP du serveur Godot
SERVER_PORT = 12345      # Port du serveur Godot

# Connexion au serveur TCP (Godot)
print(f"Tentative de connexion au serveur TCP Godot ({SERVER_IP}:{SERVER_PORT})...")
try:
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect((SERVER_IP, SERVER_PORT))
    print("Connexion au serveur TCP réussie.")
except socket.error as e:
    print(f"Erreur lors de la connexion au serveur TCP : {e}")
    exit(1)

try:
    while True:
        # Réception des données envoyées par Godot
        data = sock.recv(1024).decode('utf-8').strip()
        if data:
            print(f"Données reçues de Godot : {data}")
            
            # Traitement des commandes
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
                    print(f"Commande inconnue reçue : {command}")
            except (ValueError, IndexError):
                print(f"Erreur dans le traitement de la commande : {data}")

except KeyboardInterrupt:
    print("Arrêt du client TCP.")
finally:
    # Libérer toutes les lignes GPIO et fermer la connexion TCP
    for line in lines:
        line.set_value(0)
        line.release()
    chip.close()
    sock.close()
    print("GPIO libérés et connexion TCP fermée.")
