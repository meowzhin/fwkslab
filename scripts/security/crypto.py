import os
import argparse
import base64
from cryptography.fernet import Fernet
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC

def build_cipher(encryption_key):
    if (os.path.isfile(encryption_key)):
        with open(encryption_key, 'r') as file:
            encryption_key = file.read()
    
    kdf = PBKDF2HMAC(hashes.SHA256(), 32, '974e42a0-46aa-45c0-9edb-96a5e11edb43'.encode(), 100000, default_backend())
    key = kdf.derive(encryption_key.encode())
    key = base64.urlsafe_b64encode(key)
    return Fernet(key)

def encrypt(value, encryption_key):
    return build_cipher(encryption_key).encrypt(value.encode()).decode()

def decrypt(value, encryption_key):
    return build_cipher(encryption_key).decrypt(value.encode()).decode()

if __name__ == '__main__':
    
    try:
        parser = argparse.ArgumentParser()

        parser.add_argument('value', help='The string to be encrypted/decrypted.')
        parser.add_argument('-d', '--decrypt', action='store_true', help='Signals to decryption instead of the default encryption.')
        parser.add_argument('-k', '--encryption_key', required=True, help='Encryption Key or file be to used.')

        args = parser.parse_args()

        if (args.decrypt):
            value = decrypt(args.value, args.encryption_key)
        else:
            value = encrypt(args.value, args.encryption_key)

        print(value)

    except Exception as ex:
        print('An error occured. Check the encryption key or the encrypted value and try again.', ex)