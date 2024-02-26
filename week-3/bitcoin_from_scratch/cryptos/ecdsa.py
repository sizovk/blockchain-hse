from dataclasses import dataclass
import hashlib
import random

from .ecc import bitcoin_gen, inv, Point

sha256 = lambda x : hashlib.sha256(x).digest()

@dataclass
class Signature:
    r: int
    s: int

    def encode(self, sighash_flag=b"\x01"):
        # @todo


def sign(secret_key: int, message: bytes) -> Signature:
    z = int.from_bytes(sha256(sha256(message)), "big")
    n = bitcoin_gen.n

    while True:
        k = random.randrange(1, n)
        P = k * bitcoin_gen.G
        r = P.x % n
        if r == 0:
            continue

        s = inv(k, n) * (z + r * secret_key) % n

        if s == 0:
            continue

        break

    return Signature(r, s)


def verify(message: bytes, signature: Signature, public_key: Point):
    z = int.from_bytes(sha256(sha256(message)), "big")
    n = bitcoin_gen.n

    r, s = signature.r, signature.s

    w = inv(s, n)

    u1 = (w * z) % n
    u2 = (w * r) % n

    P = u1 * bitcoin_gen.G + u2 * public_key

    if (r % n) == (P.x % n):
        return True
    else:
        return False

