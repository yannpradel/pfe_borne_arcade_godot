import socket
import serial
from serial.tools import list_ports
import gpiod
import time
import select
import re

# Configuration des GPIO
LASER_PINS = [17, 27, 22, 26]  # Exemple : GPIO 17, 27, 22
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

# Port série pour les lasers
PORT_LASERS = '/dev/serial/by-id/usb-FTDI_FT232R_USB_UART_B001WVA8-if00-port0'
BAUD_RATE_LASERS = 9600

# Port série pour la DUE
PORT_DUE = '/dev/serial/by-id/usb-Arduino_www.arduino.cc_0043_4343935353635111F101-if00'
BAUD_RATE_DUE = 9600


print(f"Initialisation du port série : {PORT_DUE} à {BAUD_RATE_DUE} bauds")

# Initialisation du port série pour les lasers
try:
    laser_ser = serial.Serial(PORT_LASERS, BAUD_RATE_LASERS, timeout=0.1)
    print("Port série pour les lasers initialisé avec succès.")
except serial.SerialException as e:
    print(f"Erreur lors de l'initialisation du port série pour les lasers : {e}")
    exit(1)

# Initialisation du port série pour la DUE
'''
try:
    ser_due = serial.Serial(PORT_DUE, BAUD_RATE_DUE, timeout=0.1)
    print("Port série pour la DUE initialisé avec succès.")
except serial.SerialException as e:
    print(f"Erreur lors de l'initialisation du port série pour la DUE : {e}")
    laser_ser.close()
    exit(1)
    '''


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
    ser_due.close()
    exit(1)

try:
    while True:
        # Utiliser select pour gérer les entrées sans bloquer
        ready_to_read, _, _ = select.select([sock], [], [], 0.1)
        
        for ready in ready_to_read:
            if ready == sock:
                # Données disponibles du serveur Godot
                try:
                    data_from_godot = sock.recv(1024).decode('utf-8').strip()
                    if data_from_godot:
                        print(f"Reçu de Godot : {data_from_godot}")

                        if data_from_godot == "MinusLife":
                            # Allumer la pin 26 puis éteindre
                            pin_26 = chip.get_line(26)
                            pin_26.set_value(1)
                            print("Pin 26 activée.")
                            time.sleep(0.1)  # Temporisation
                            pin_26.set_value(0)
                            print("Pin 26 désactivée.")

                        elif re.match(r'^[0-5]$', data_from_godot):
                            # Envoie la configuration au port série
                            laser_command = f"{data_from_godot}\n"  # Format de la commande
                            laser_ser.write(laser_command.encode('utf-8'))
                            print(f"Commande envoyée au laser : {laser_command.strip()}")
                        else:
                            print(f"Données invalides reçues : {data_from_godot}")

                except socket.error:
                    print("Erreur de lecture du socket.")

        # Vérification de l'état de la ligne GPIO d'entrée
        gpio_value = input_line.get_value()
        
        if gpio_value == 1:
            print("Signal détecté sur le GPIO d'entrée ! Envoi de 'jump' à Godot.")
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
    #ser_due.close()
    sock.close()
    print("GPIO, port série et connexion TCP libérés.")
