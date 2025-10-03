from dataclasses import dataclass

def bin_pow(a, n, m):
    if n == 0:
        return 1
    if n % 2 == 0:
        r = bin_pow(a, n // 2, m)
        return (r**2) % m
    return (bin_pow(a, n - 1, m) * a) % m

def inv(a, p):
    return bin_pow(a, p-2, p)


@dataclass
class Curve:
    """
    y^2 = x^3 + ax + b (mod p)
    """
    p: int
    a: int
    b: int


@dataclass
class Point:
    """
    y^2 = x^3 + ax + b (mod p)
    2ydy = 3x^2dx + a
    dy/dx = (3x^2 + a) / 2y
    """
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
            m = ((3 * self.x**2 + self.curve.a) * inv(2 * self.y, self.curve.p)) % self.curve.p
        else:
            m = ((self.y - other.y) * inv(self.x - other.x, self.curve.p)) % self.curve.p
        rx = (m**2 - self.x - other.x) % self.curve.p
        ry = -(m * (rx - self.x) + self.y) % self.curve.p
        return Point(curve=self.curve, x=rx, y=ry)
    
    def __rmul__(self, k: int):
        result = INF
        append = self
        while k:
            if k & 1:
                result += append
            append += append
            k >>= 1
        return result
    
    def __eq__(self, other):
        return (self.x == other.x) and (self.y == other.y)


INF = Point(None, None, None)

@dataclass
class Generator:
    G: Point
    n: int

bitcoin_curve = Curve(
    p=0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F,
    a=0,
    b=7
)

G = Point(
    curve=bitcoin_curve,
    x=0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798,
    y=0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8
)

bitcoin_gen = Generator(
    G=G,
    n=0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141
)

