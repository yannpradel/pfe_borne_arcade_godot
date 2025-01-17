import serial
import socket

# Configuration du port série et de la connexion TCP
serial_port = 'COM3'  # Port série correct pour Arduino Leonardo
baud_rate = 9600
server_ip = '127.0.0.1'
server_port = 12345

print(f"Initialisation du port série : {serial_port} à {baud_rate} bauds")
# Initialisation du port série
try:
    ser = serial.Serial(serial_port, baud_rate, timeout=1)
    print("Port série initialisé avec succès.")
except serial.SerialException as e:
    print(f"Erreur lors de l'initialisation du port série : {e}")
    exit(1)

print(f"Tentative de connexion au serveur TCP {server_ip}:{server_port}")
# Connexion au serveur TCP
try:
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect((server_ip, server_port))
    print("Connexion au serveur TCP réussie.")
except socket.error as e:
    print(f"Erreur lors de la connexion au serveur TCP : {e}")
    ser.close()
    exit(1)

try:
    while True:
        if ser.in_waiting > 0:
            # Lire les données du port série
            data = ser.readline().decode('utf-8').strip()  
            print(f"DEBUG - Données brutes reçues : {data}")
            
            # Envoyer les données brutes à Godot via TCP
            sock.sendall(data.encode('utf-8'))
            print(f"Envoyé à Godot : {data}")

except KeyboardInterrupt:
    print("Fermeture du programme.")
finally:     
    ser.close()
    sock.close()
    print("Ports série et TCP fermés.")
    