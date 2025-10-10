import hashlib
from .ecc import bitcoin_gen, inv
import secrets

from dataclasses import dataclass

@dataclass
class Signature:
    r: int
    s: int

    def encode(self, sighash_flag=b'\x01') -> bytes:
        def encode_number(n):
            nb = n.to_bytes(32, "big")
            nb = nb.lstrip(b'\x00')
            nb = (b'\x00' if nb[0] >= 0x80 else b'') + nb
            return nb
        
        rb = encode_number(self.r)
        sb = encode_number(self.s)

        res = b''.join([b'\x02', len(rb).to_bytes(1), rb, b'\x02', len(sb).to_bytes(1), sb])
        res2 = b''.join([b'\x30', len(res).to_bytes(1), res, sighash_flag])
        return res2


sha256 = lambda x : hashlib.sha256(x).digest()

def sign(secret_key: int, message: bytes):
    z = int.from_bytes(sha256(sha256(message)), "big")
    n = bitcoin_gen.n

    k = secrets.randbelow(n) + 1
    P = k * bitcoin_gen.G

    r = P.x % n
    if r == 0:
        return sign(secret_key, message)
    
    s = (inv(k, n) * (z + r * secret_key)) % n
    if s == 0:
        return sign(secret_key, message)
    
    if s > n / 2:
        s = n - s
    
    return Signature(r, s)

def verify(public_key, message, signature):
    z = int.from_bytes(sha256(sha256(message)), "big")
    n = bitcoin_gen.n

    r, s = signature.r, signature.s

    sm = inv(s, n)

    u1 = (sm * z) % n
    u2 = (sm * r) % n

    P = u1 * bitcoin_gen.G + u2 * public_key

    r1 = P.x % n

    return r == r1

