from cryptos.ecc import bitcoin_gen
from cryptos.ecdsa import sign, verify

def test_sign_verify():
    private_key = 1337
    message = b"abacaba"
    public_key = private_key * bitcoin_gen.G
    signature = sign(private_key, message)
    assert verify(message, signature, public_key)

    assert not verify(b"caba", signature, public_key)
