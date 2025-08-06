import serial
import time

PORT = 'COM91'
BAUDRATE = 115200
DELAY = 0.09  # 90 ms
HEX_FILE = 'temp.hex'

try:
    with serial.Serial(PORT, BAUDRATE, timeout=0.1) as ser:
        print(f'✅ Port {PORT} ouvert à {BAUDRATE} bauds')

        with open(HEX_FILE, 'r') as f:
            for line in f:
                line = line.strip()
                if line:
                    # ↪️ Envoi de la ligne
                    ser.write((line + '\r\n').encode('ascii'))
                    #print(f'↪️ Envoyé : {line}')

                    time.sleep(DELAY)

                    # 📥 Lecture du retour (si dispo)
                    response = ser.read_all().decode(errors='replace')
                    if response:
                        print(f'📩 Reçu : {response.strip()}')

        print('✅ Transfert terminé.')

except FileNotFoundError:
    print(f'❌ Fichier introuvable : {HEX_FILE}')
except serial.SerialException as e:
    print(f'❌ Erreur série : {e}')
