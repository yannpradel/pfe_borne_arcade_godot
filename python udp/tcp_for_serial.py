import socket
import serial
import gpiod
import time
import select
import re

# Configuration des GPIO
LASER_PINS = [17, 27, 22]  # Exemple : GPIO 17, 27, 22
CHIP_NAME = "gpiochip0"  # Nom de la puce GPIO sur Raspberry Pi 5
INPUT_PIN = 23  # GPIO à surveiller pour détecter un "1"

# Initialisation des lignes GPIO
chip = gpiod.Chip(CHIP_NAME)
lines = [chip.get_line(pin) for pin in LASER_PINS]

for line in lines:
    line.request(consumer="laser_control", type=gpiod.LINE_REQ_DIR_OUT)
    line.set_value(0)  # Éteindre tous les lasers par défaut

# Configuration de la ligne GPIO en entrée
input_line = chip.get_line(INPUT_PIN)
input_line.request(consumer="gpio_input", type=gpiod.LINE_REQ_DIR_IN)

# Configuration du port série
PORT = '/dev/serial/by-id/usb-Arduino_www.arduino.cc_0043_4343935353635111F101-if00'  # Nom du port (à adapter si nécessaire)
BAUD_RATE = 9600  # Débit en bauds (doit correspondre à celui configuré dans le programme Arduino)

print(f"Initialisation du port série : {PORT} à {BAUD_RATE} bauds")
# Initialisation du port série
try:
    ser = serial.Serial(PORT, BAUD_RATE, timeout=0.1)  # Timeout court pour éviter de bloquer longtemps
    print("Port série initialisé avec succès.")
except serial.SerialException as e:
    print(f"Erreur lors de l'initialisation du port série : {e}")
    exit(1)

# Configuration du client TCP
SERVER_IP = '127.0.0.1'  # Adresse IP du serveur Godot
SERVER_PORT = 12345      # Port du serveur Godot

print(f"Tentative de connexion au serveur TCP Godot ({SERVER_IP}:{SERVER_PORT})...")
# Connexion au serveur TCP
try:
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.setblocking(False)  # Mettre le socket en mode non-bloquant
    
    # Tentative de connexion
    sock.connect_ex((SERVER_IP, SERVER_PORT))  # Retourne immédiatement, sans bloquer
    print("Connexion en cours...")
    
    # Attente de la connexion avec select
    ready_to_read, ready_to_write, in_error = select.select([], [sock], [], 5)  # Timeout de 5 secondes
    
    if ready_to_write:
        print("Connexion au serveur TCP réussie.")
    else:
        print("Impossible de se connecter au serveur TCP après 5 secondes.")
        sock.close()
        exit(1)

except socket.error as e:
    print(f"Erreur lors de la connexion au serveur TCP : {e}")
    ser.close()
    exit(1)

try:
    while True:
        
        # Utiliser select pour gérer les entrées sans bloquer
        ready_to_read, _, _ = select.select([ser, sock], [], [], 0.1)
        
        for ready in ready_to_read:
            if ready == ser:
                # Données disponibles sur le port série
                data_from_serial = ser.readline().decode('utf-8').strip()
                if data_from_serial:
                    #print(f"DEBUG - Données série reçues : {data_from_serial}")
                    sock.sendall(data_from_serial.encode('utf-8'))
                    #print(f"Envoyé à Godot : {data_from_serial}")
            
            elif ready == sock:
                # Données disponibles du serveur Godot
                try:
                    data_from_godot = sock.recv(1024).decode('utf-8').strip()
                    if data_from_godot:
                        data_from_godot = re.sub(r'[^0-9]', '', data_from_godot)  # Garder uniquement les chiffres
                        print(f"Données reçues de Godot : f{data_from_godot}f")

                        # Vérification si les données sont valides (exactement 3 caractères, composées uniquement de 0 et 1)
                        print(f"DEBUG: {data_from_godot} - Longueur : {len(data_from_godot)}")
                        if len(data_from_godot) == 3 and all(c in '01' for c in data_from_godot):
                            print(f"Données valides reçues de Godot : {data_from_godot}")
                            for i, value in enumerate(data_from_godot):
                                if value == '1':
                                    lines[i].set_value(1)  # Activer le GPIO correspondant
                                    print(f"Laser {i} activé")
                                else:
                                    lines[i].set_value(0)  # Désactiver le GPIO correspondant
                                    print(f"Laser {i} désactivé")
                        else:
                            print(f"Données invalides reçues : {data_from_godot}")
                except socket.error:
                    print("Erreur de lecture du socket.")
        
        # Vérification de l'état de la ligne GPIO d'entrée
        gpio_value = input_line.get_value()
        
        if gpio_value == 1:
            #print("Signal détecté sur le GPIO d'entrée ! Envoi de 'jump' à Godot.")
            sock.sendall("jump\n".encode('utf-8'))

except KeyboardInterrupt:
    print("Fermeture du programme.")
finally:
    # Libérer toutes les lignes GPIO et fermer les connexions
    for line in lines:
        line.set_value(0)
        line.release()
    input_line.release()
    chip.close()
    ser.close()
    sock.close()
    print("GPIO, port série et connexion TCP libérés.")
