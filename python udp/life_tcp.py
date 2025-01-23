import RPi.GPIO as GPIO
import time

# Configuration du GPIO
GPIO.setmode(GPIO.BCM)  # Utilisation de la numérotation BCM
GPIO.setup(26, GPIO.OUT)  # Configuration du GPIO 26 comme sortie

try:
    # Envoi de la valeur 1 sur le GPIO 26
    GPIO.output(26, GPIO.HIGH)
    time.sleep(0.5)  # Maintenir la valeur haute pendant 0,5 seconde
    
    # Remettre le GPIO à 0
    GPIO.output(26, GPIO.LOW)

finally:
    # Nettoyage des configurations GPIO
    GPIO.cleanup()
