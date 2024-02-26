from dataclasses import dataclass

def extended_euclid(a, b):
    """ax + by = (a, b)"""
    # ax + by = z
    # x = 1, y = 0, z = a
    # x = 0, y = 1, z = b
    # x = 1, y = -k, z = a - k * b = a % b

    x1, y1, z1 = 1, 0, a
    x2, y2, z2 = 0, 1, b

    while z2 != 0:
        k = z1 // z2
        x1, x2 = x2, x1 - k * x2
        y1, y2 = y2, y1 - k * y2
        z1, z2 = z2, z1 - k * z2
    
    return z1, x1, y1


def inv(a, n):
    _, x, _ = extended_euclid(a, n)
    return x % n

@dataclass
class Curve:
    """y^2 = x^3 + ax + b (mod p)"""

    a: int
    b: int
    p: int

@dataclass
class Point:
    curve: Curve
    x: int
    y: int

    def __add__(self, other):
        if self == INF:
            return other
        if other == INF:
            return self
        if self.x == other.x and self.y != other.y:
            return INF
        
        if self.x == other.x:
            """m = (3x^2 + a) / 2y"""
            m = (3 * self.x ** 2 + self.curve.a) * inv(2 * self.y, self.curve.p)
        else:
            m = ((self.y - other.y) * inv(self.x - other.x, self.curve.p)) % self.curve.p
        xr = (m**2 - self.x - other.x) % self.curve.p
        yr = (-(m * (xr - self.x) + self.y)) % self.curve.p
        
        return Point(self.curve, xr, yr)
    
    def __rmul__(self, k: int):
        if k == 0:
            return INF
        if k % 2 == 0:
            t = (k // 2) * self
            return t + t
        return self + (k - 1) * self



INF = Point(None, None, None)

@dataclass
class Generator:
    G: Point
    n: int

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
