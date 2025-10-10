from dataclasses import dataclass

def encode_varint(n: int) -> bytes:
    if n < 0xFD:
        return n.to_bytes(1, "little")
    if n < 0xFFFF:
        return b'\xfd' + n.to_bytes(2, "little")
    if n < 0xFFFFFFFF:
        return b'\xfe' + n.to_bytes(4, "little")
    return b'\xff' + n.to_bytes(8, "little")

@dataclass
class Script:
    cmds: list[int | bytes]

    def encode(self):
        out = []
        for cmd in self.cmds:
            if isinstance(cmd, int):
                out.append(cmd.to_bytes(1, "little")) # @todo check
            else:
                assert isinstance(cmd, bytes)
                length = len(cmd)
                out.append(encode_varint(length) + cmd) # @todo check
        outb = b''.join(out)
        return encode_varint(len(outb)) + outb # @todo check


@dataclass
class TxIn:
    prev_tx: bytes
    prev_index: int
    script_sig: Script
    sequence: int = 0xFFFFFFFF

    def encode(self, script_override: Script | None = None):
        out = []
        out.append(self.prev_tx)
        out.append(self.prev_index.to_bytes(4, "little"))
        if script_override:
            out.append(script_override.encode())
        else:
            out.append(self.script_sig.encode())
        
        out.append(self.sequence.to_bytes(4, "little"))
        return b"".join(out) # @todo check

@dataclass
class TxOut:
    value: int
    script_pubkey: Script

    def encode(self):
        return self.value.to_bytes(8, "little") + self.script_pubkey.encode()


@dataclass
class Tx:
    version: int
    tx_ins: list[TxIn]
    tx_outs: list[TxOut]
    locktime: int = 0

    def encode(self, sig_index=-1, script_override=None) -> bytes:
        out = []

        out.append(self.version.to_bytes(4, "little"))
        out.append(encode_varint(len(self.tx_ins)))

        if sig_index==-1:
            out += [tx_in.encode() for tx_in in self.tx_ins]
        else:
            for i, tx_in in enumerate(self.tx_ins):
                if i == sig_index:
                    out.append(tx_in.encode(script_override))
                else:
                    out.append(tx_in.encode())
        
        out.append(encode_varint(len(self.tx_outs)))
        out += [tx_out.encode() for tx_out in self.tx_outs]

        return out.append(self.locktime.to_bytes(4, "little"))

        

