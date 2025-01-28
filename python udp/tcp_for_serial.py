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

print(f"[PYTHON] Initialisation du port série : {PORT_LASERS} à {BAUD_RATE_LASERS} bauds")

# Initialisation du port série pour les lasers
try:
    laser_ser = serial.Serial(PORT_LASERS, BAUD_RATE_LASERS, timeout=0.1)
    print("[PYTHON] Port série pour les lasers initialisé avec succès.")
except serial.SerialException as e:
    print(f"[PYTHON] Erreur lors de l'initialisation du port série pour les lasers : {e}")
    exit(1)

# Configuration du serveur TCP
SERVER_IP = '0.0.0.0'  # Écoute sur toutes les interfaces
SERVER_PORT = 12345    # Port d'écoute

print(f"[PYTHON] Démarrage du serveur TCP sur {SERVER_IP}:{SERVER_PORT}...")

# Initialisation du serveur TCP
try:
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.bind((SERVER_IP, SERVER_PORT))
    server_socket.listen(5)
    server_socket.setblocking(False)
    print("[PYTHON] Serveur TCP démarré avec succès et en attente de connexions.")
except socket.error as e:
    print(f"[PYTHON] Erreur lors du démarrage du serveur TCP : {e}")
    exit(1)

clients = []

try:
    while True:
        # Accepter les nouvelles connexions
        try:
            client_socket, client_address = server_socket.accept()
            client_socket.setblocking(False)
            clients.append(client_socket)
            print(f"[PYTHON] Nouvelle connexion de {client_address}")
        except BlockingIOError:
            pass

        # Lire les données des clients existants
        for client in clients[:]:
            try:
                data = client.recv(1024).decode('utf-8').strip()
                if data:
                    print(f"[PYTHON] Reçu de {client.getpeername()} : {data}")

                    if data == "jump":
                        print("[PYTHON] Signal 'jump' reçu. Activation du GPIO 26.")
                        pin_26 = chip.get_line(26)
                        pin_26.set_value(1)
                        time.sleep(0.1)
                        pin_26.set_value(0)

                    elif re.match(r'^[0-5]$', data):
                        laser_command = f"{data}\n"
                        laser_ser.write(laser_command.encode('utf-8'))
                        print(f"[PYTHON] Commande envoyée au laser : {laser_command.strip()}")
                    else:
                        print(f"[PYTHON] Données invalides reçues : {data}")

            except BlockingIOError:
                continue
            except ConnectionResetError:
                print(f"[PYTHON] Connexion perdue avec {client.getpeername()}.")
                clients.remove(client)

        # Vérification de l'état de la ligne GPIO d'entrée
        gpio_value = input_line.get_value()
        if gpio_value == 1:
            print("[PYTHON] Signal détecté sur le GPIO d'entrée !")
            for client in clients:
                try:
                    client.sendall("jump\n".encode('utf-8'))
                except socket.error:
                    print(f"[PYTHON] Erreur d'envoi au client {client.getpeername()}.")

except KeyboardInterrupt:
    print("[PYTHON] Fermeture du serveur.")
finally:
    # Libération des ressources
    for line in lines:
        line.set_value(0)
        line.release()
    input_line.release()
    chip.close()
    laser_ser.close()
    for client in clients:
        client.close()
    server_socket.close()
    print("[PYTHON] GPIO, ports série et serveur TCP libérés.")
