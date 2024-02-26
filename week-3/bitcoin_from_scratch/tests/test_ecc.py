from cryptos.ecc import Curve, Point

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

n = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141

INF = Point(None, None, None)

def test_generator_point():
    assert (G.y**2 - G.x**3 - bitcoin_curve.a * G.x - bitcoin_curve.b) % bitcoin_curve.p == 0

def test_addition():
    # private_key = 2
    public_key = G + G
    assert (public_key.y**2 - public_key.x**3 - bitcoin_curve.a * public_key.x - bitcoin_curve.b) % bitcoin_curve.p == 0

    # private_key = 3
    public_key = G + G + G
    assert (public_key.y**2 - public_key.x**3 - bitcoin_curve.a * public_key.x - bitcoin_curve.b) % bitcoin_curve.p == 0

    # private_key = 4
    public_key = G + G + G + G
    assert (public_key.y**2 - public_key.x**3 - bitcoin_curve.a * public_key.x - bitcoin_curve.b) % bitcoin_curve.p == 0

def test_multiplication():

    private_key = 1
    public_key = G
    assert private_key * G == public_key

    private_key = 2
    public_key = G + G
    assert private_key * G == public_key

    private_key = 3
    public_key = G + G + G
    assert private_key * G == public_key

    private_key = 228
    public_key = private_key * G
    assert (public_key.y**2 - public_key.x**3 - bitcoin_curve.a * public_key.x - bitcoin_curve.b) % bitcoin_curve.p == 0

    assert n * G == INF

