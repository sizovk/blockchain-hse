from bitcoinlib.ecc import bitcoin_gen

def is_on_curve(P, curve):
    return (P.y**2) % curve.p == (P.x**3 + curve.a * P.x + curve.b) % curve.p

def test_on_curve():
    """
    y^2 = x^3 + ax + b (mod p)
    """
    assert (bitcoin_gen.G.y**2) % bitcoin_gen.G.curve.p \
    == (bitcoin_gen.G.x**3 + bitcoin_gen.G.curve.a * bitcoin_gen.G.x + bitcoin_gen.G.curve.b) % bitcoin_gen.G.curve.p

def test_addition():
    P = bitcoin_gen.G
    assert is_on_curve(P, bitcoin_gen.G.curve)

    assert is_on_curve(P+P, bitcoin_gen.G.curve)


    assert is_on_curve(P+P+P+P, bitcoin_gen.G.curve)

def test_multiplication():
    P = bitcoin_gen.G
    assert 1 * P == P

    assert 2 * P == (P + P)

    assert 6 * P == (P + P + P + P + P + P)

    assert 5 * P == (3 * P + 2 * P)

    assert is_on_curve(133712341234 * P, bitcoin_gen.G.curve)
    




