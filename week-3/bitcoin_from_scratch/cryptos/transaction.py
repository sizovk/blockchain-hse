from dataclasses import dataclass
import hashlib
from typing import List, Union

sha256 = lambda x : hashlib.sha256(x).digest()

def encode_int(x, nbytes, encoding="little"):
    return x.to_bytes(nbytes, encoding)

def encode_varint(x):
    if x <= 0xFD:
        return encode_int(x, 1)
    if x <= 0xFFFF:
        return b'\xfd' + encode_int(x, 2)
    if x <= 0xFFFFFFFF:
        return b'\xfe' + encode_int(x, 4)
    if x <= 0xFFFFFFFFFFFFFFFF:
        return b'\xff' + encode_int(x, 8)
    raise ValueError("too large number")

@dataclass
class Script:
    cmds: List[Union[int, bytes]]

    def encode(self):
        out = []
        for cmd in self.cmds:
            if isinstance(cmd, int):
                out += [encode_int(cmd, 1)]
            else:
                length = len(cmd)
                assert length < 75
                out += [encode_int(length, 1), cmd]
        res = b"".join(out)
        return encode_varint(len(res)) + res

@dataclass
class TxIn:
    prev_tx: bytes
    prev_index: int
    script_sig: Script
    sequence: int = 0xFFFFFFFF

    def encode(self, script_override=None):
        out = []
        out += [self.prev_tx[::-1]]
        out += [encode_int(self.prev_index, 4)]

        if script_override is True:
            out += [self.prev_tx_script_pubkey.encode()]
        else:
            out += [self.script_sig.encode()]

        out += [encode_int(self.sequence)]



@dataclass
class TxOut:
    amount: int
    script_pubkey: Script

    def encode(self):
        out = []
        out += [encode_int(self.amount, 8)]
        out += [self.script_pubkey.encode()]
        return b"".join(out)


@dataclass
class Tx:
    version: int = 1
    tx_ins: List[TxIn]
    tx_outs: List[TxOut]
    locktime: int = 0
    
    def encode(self, sig_index=None):
        out = []
        out += [encode_int(self.version, 4)]

        out += [encode_varint(len(self.tx_ins))]
        if sig_index is None:
            out += [tx_in.encode() for tx_in in self.tx_ins]
        else:
            out += [tx_in.encode(script_override=(i == sig_index)) for i, tx_in in enumerate(self.tx_ins)]
        
        out += [encode_varint(len(self.tx_outs))]
        out += [tx_out.encode() for tx_out in self.tx_outs]
        out += [encode_int(self.locktime, 4)]
        out += [b"" if sig_index is None else encode_int(1, 4)]
        return b"".join(out)
    
    def tx_id(self) -> str:
        return sha256(sha256(self.encode()))[::-1].hex()
