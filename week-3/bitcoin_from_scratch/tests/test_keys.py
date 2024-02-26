from cryptos.keys import PublicKey
from cryptos.ecc import Curve, Point, Generator

bitcoin_curve = Curve(
    a = 0x0000000000000000000000000000000000000000000000000000000000000000,
    b = 0x0000000000000000000000000000000000000000000000000000000000000007,
    p = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F
)

G = Point(
    curve = bitcoin_curve,
    x = 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798,
    y = 0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8
)

bitcoin_gen = Generator(
    G = G,
    n = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141
)

INF = Point(None, None, None)

def test_address_gen_compressed():
    private_key = 0x18e14a7b6a307f426a94f8114701e7c8e774e7f9a47e2c2035db29a206321725
    assert private_key < bitcoin_gen.n

    public_key = private_key * G

    address = PublicKey.from_point(public_key).address(net="main", compressed=True)

    assert address == "1PMycacnJaSqwwJqjawXBErnLsZ7RkXUAs"

def test_address_gen_not_compressed():
    tests = [
        (0xB689D9616C07AD146B2638497A7F088C4D8084BE87EBEFC40C63FDA57E50EE1B, "1DnY86B1okPGWPEnMWxNkz4o2bt1iY6X2v"),
        (0x846EC5E62530E1DC74CCB5AA1D783AB0B76AD54DC0F826888DBFAAA73439A830, "1iMtQqMrX5DPMFLyE54QVrWUeS1QLPfQP"),
        (0xAB89338B7D0B7C4BF467D61AC5128F2C8E5EF5E7CD70279C9BF5739FD5E86A3A, "18mXpx7NgHqKpH7t5AcXteZV4DDpkUQ5W")
    ]

    for private_key, correct_address in tests:
        assert private_key < bitcoin_gen.n
        public_key = private_key * G
        address = PublicKey.from_point(public_key).address(net="main", compressed=False)

        assert address == correct_address




