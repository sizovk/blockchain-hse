import hashlib

from .ecc import Point

sha256 = lambda x : hashlib.sha256(x).digest()

def ripemd160(x):
    h = hashlib.new("ripemd160")
    h.update(x)
    return h.digest()

def b58encode(b: bytes) -> str:
    code_string = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
    n = int.from_bytes(b, "big")
    output = []

    while n > 0:
        n, r = divmod(n, 58)
        output.append(code_string[r])
    
    num_leading_zeros = len(b) - len(b.lstrip(b'\x00'))
    output += ["1"] * num_leading_zeros

    return "".join(output[::-1])



class PublicKey(Point):

    @classmethod
    def from_point(cls, pt):
        return cls(pt.curve, pt.x, pt.y)

    def encode(self, compressed, hash160=False):
        if compressed:
            prefix = b'\x02' if self.y % 2 == 0 else b'\x03'
            res = prefix + self.x.to_bytes(32, "big")
        else:
            res = b'\x04' + self.x.to_bytes(32, "big") + self.y.to_bytes(32, "big")
        return ripemd160(sha256(res)) if hash160 else res


    def address(self, net, compressed):

        version = b'\x00' if net == "main" else b'\x6F'

        pkv_hash = version + ripemd160(sha256(self.encode(compressed)))

        checksum = sha256(sha256(pkv_hash))[:4]

        conc = pkv_hash + checksum

        return b58encode(conc)
