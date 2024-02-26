import hashlib

from .ecc import Point

sha256 = lambda x : hashlib.sha256(x).digest()

def ripemd160(x):
    h = hashlib.new("ripemd160")
    h.update(x)
    return h.digest()

code_string = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
def base58encode(b: bytes):
    x = int.from_bytes(b, "big")

    result = ""

    while x > 0:
        x, rem = divmod(x, 58)
        result += code_string[rem]

    num_leading_zeros = len(b) - len(b.lstrip(b'\x00'))
    result += code_string[0] * num_leading_zeros

    return result[::-1]
   


class PublicKey(Point):

    @classmethod
    def from_point(cls, pt):
        return cls(pt.curve, pt.x, pt.y)
    
    def encode(self, compressed, hash160=False):
        if compressed:
            prefix = b'\x02' if self.y % 2 == 0 else b'\x03'
            pkb = prefix + self.x.to_bytes(32, "big")
        else:
            pkb = b'\x04' + self.x.to_bytes(32, "big") + self.y.to_bytes(32, "big")
        
        return ripemd160(sha256(pkb)) if hash160 else pkb
    
    def address(self, net, compressed):
        pkb_hash = self.encode(compressed=compressed, hash160=True)
        version = {"main": b'\x00', "test": b'\x6F'}

        ver_pkb_hash = version[net] + pkb_hash
        checksum = sha256(sha256(ver_pkb_hash))[:4]

        byte_address = ver_pkb_hash + checksum

        return base58encode(byte_address)




        