import RPi.GPIO as GPIO
import socket
import time

# Configuration des GPIO
GPIO.setmode(GPIO.BCM)
BUTTON_1 = 16  # GPIO pour le bouton Droite
BUTTON_2 = 26  # GPIO pour le bouton Gauche
BUTTON_3 = 6   # GPIO pour le bouton Saut
BUTTON_4 = 5   # GPIO pour le bouton Bas

GPIO.setup(BUTTON_1, GPIO.IN, pull_up_down=GPIO.PUD_UP)
GPIO.setup(BUTTON_2, GPIO.IN, pull_up_down=GPIO.PUD_UP)
GPIO.setup(BUTTON_3, GPIO.IN, pull_up_down=GPIO.PUD_UP)
GPIO.setup(BUTTON_4, GPIO.IN, pull_up_down=GPIO.PUD_UP)

# Configuration du socket UDP
UDP_IP = "127.0.0.1"  # Adresse IP de Godot (localhost)
UDP_PORT = 12345      # Port pour communiquer avec Godot
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

# État des boutons pour éviter les envois répétés
button_states = {
    "BUTTON_DROIT": False,
    "BUTTON_GAUCHE": False,
    "BUTTON_SAUT": False,
    "BUTTON_ARRIERE": False,
}

# Dictionnaire pour relier les GPIO aux commandes
gpio_to_command = {
    BUTTON_1: "BUTTON_DROIT",
    BUTTON_2: "BUTTON_GAUCHE",
    BUTTON_3: "BUTTON_SAUT",
    BUTTON_4: "BUTTON_ARRIERE",
}

print("Init")

try:
    while True:
        for gpio, command in gpio_to_command.items():
            input_state = GPIO.input(gpio)
            if input_state == GPIO.LOW and not button_states[command]:  # Bouton pressé
                sock.sendto(command.encode(), (UDP_IP, UDP_PORT))
                button_states[command] = True
                print(f"{command} envoyé")
            elif input_state == GPIO.HIGH and button_states[command]:  # Bouton relâché
                stop_command = f"STOP_{command}"
                sock.sendto(stop_command.encode(), (UDP_IP, UDP_PORT))
                button_states[command] = False
                print(f"{stop_command} envoyé")
        time.sleep(0.01)  # Anti-rebond logiciel et limitation de la boucle
except KeyboardInterrupt:
    print("Arrêt du script.")
finally:
    GPIO.cleanup()
    sock.close()
