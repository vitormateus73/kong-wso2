from authlib.jose import JsonWebKey

import json
import sys

def read_file(filename):
  fh = open(filename, "r")
  try:
      return fh.read()
  finally:
      fh.close()

nome_arquivo = 'tst-pop-public-key.pem'
kid_jwt = 'https://poptst.ons.org.br/ons.pop.federation/'

if len(sys.argv) > 1:
    nome_arquivo = sys.argv[1] 

if len(sys.argv) > 2:
    kid_jwt = sys.argv[2]

print(nome_arquivo)
print(kid_jwt)

key_data = read_file(nome_arquivo)
key = JsonWebKey.import_key(key_data, {'kty': 'RSA'})

#key.as_dict()
jwks = json.loads(key.as_json())

jwks['kid'] = kid_jwt


print({'keys': [ jwks ]})
