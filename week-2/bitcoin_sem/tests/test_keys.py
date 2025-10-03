from bitcoinlib.ecc import bitcoin_gen
from bitcoinlib.keys import PublicKey

def test_address_from_private():
    private_key = 0xEE908955DDE54D0FCA61D38BB2C488E135ADBFAE50C83EEABAEE7582975B5F3D

    public_key = private_key * bitcoin_gen.G

    pk = PublicKey.from_point(public_key)

    address = pk.address(net="main", compressed=False)

    assert address == "1MK1VULYSc6ZXjshGsyrxM4f3mNYDa2okR"


