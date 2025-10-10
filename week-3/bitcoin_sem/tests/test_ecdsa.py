from bitcoinlib.ecdsa import sign, verify
from bitcoinlib.ecc import bitcoin_gen

def test_sign_verify():
    private_key = 1312341234234
    private_key_2 = 1312341234234234
    public_key = private_key * bitcoin_gen.G
    public_key_2 = private_key_2 * bitcoin_gen.G

    message = b"Hello!"

    signature = sign(private_key, message)
    signature2 = sign(private_key_2, message)

    assert verify(public_key, message, signature)

    assert verify(public_key_2, message, signature2)

    assert not verify(public_key_2, message, signature)

    assert not verify(public_key, message, signature2)

    assert not verify(public_key_2, b"blablabla", signature2)





