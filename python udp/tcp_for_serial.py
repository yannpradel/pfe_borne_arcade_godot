import socket
import serial
import gpiod

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
serial_port = '/dev/serial/by-id/usb-Arduino__www.arduino.cc__0043_4343935353635111F101-if00'  # Port série correct pour Arduino Leonardo
baud_rate = 9600

print(f"Initialisation du port série : {serial_port} à {baud_rate} bauds")
# Initialisation du port série
try:
    ser = serial.Serial(serial_port, baud_rate, timeout=1)
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
    sock.connect((SERVER_IP, SERVER_PORT))
    print("Connexion au serveur TCP réussie.")
except socket.error as e:
    print(f"Erreur lors de la connexion au serveur TCP : {e}")
    ser.close()
    exit(1)

try:
    while True:
        # Envoi des données depuis le port série à Godot
        if ser.in_waiting > 0:
            # Lire les données du port série
            data_from_serial = ser.readline().decode('utf-8').strip()
            print(f"DEBUG - Données brutes reçues du port série : {data_from_serial}")
            
            # Envoyer les données à Godot
            sock.sendall(data_from_serial.encode('utf-8'))
            print(f"Envoyé à Godot : {data_from_serial}")

        # Vérification de l'état de la ligne GPIO d'entrée
        if input_line.get_value() == 1:
            print("Signal détecté sur le GPIO d'entrée ! Envoi de 'jump' à Godot.")
            sock.sendall("jump\n".encode('utf-8'))

        # Réception des données envoyées par Godot
        if sock.recv(1024):
            data_from_godot = sock.recv(1024).decode('utf-8').strip()
            print(f"Données reçues de Godot : {data_from_godot}")

            # Vérification si les données sont valides (exactement 3 caractères, composées uniquement de 0 et 1)
            if len(data_from_godot) == 3 and all(c in '01' for c in data_from_godot):
                for i, value in enumerate(data_from_godot):
                    if value == '1':
                        lines[i].set_value(1)  # Activer le GPIO correspondant
                        print(f"Laser {i} activé")
                    else:
                        lines[i].set_value(0)  # Désactiver le GPIO correspondant
                        print(f"Laser {i} désactivé")
            else:
                print(f"Données invalides reçues : {data_from_godot}")

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
    print("GPIO, port série et connexion TCP libérés.")
