from cryptos.ecc import bitcoin_gen
from cryptos.keys import PublicKey
from cryptos.transaction import TxIn, TxOut, Tx, Script
from cryptos.ecdsa import sign

from_sk = int.from_bytes(b"Suuuuuus", "big")
from_pk = from_sk * bitcoin_gen.G
from_address = PublicKey.from_point(from_pk).address(net="test", compressed=True)

to_sk = int.from_bytes(b"Saaaaaaas", "big")
to_pk = to_sk * bitcoin_gen.G
to_address = PublicKey.from_point(to_pk).address(net="test", compressed=True)

print(f"{from_address} -> {to_address}")

out1_pkb_hash = PublicKey.from_point(to_pk).encode(compressed=True, hash160=True)
out1_script = Script([118, 169, out1_pkb_hash, 136, 172])
tx_out1 = TxOut(
    amount=1000,
    script_pubkey=out1_script
)

out2_pkb_hash = PublicKey.from_point(from_pk).encode(compressed=True, hash160=True)
out2_script = Script([118, 169, out2_pkb_hash, 136, 172])
tx_out2 = TxOut(
    amount=4125,
    script_pubkey=out1_script
)

tx_in = TxIn(
    prev_tx = bytes.fromhex("bd87d32364c8cca27ce9f3d530cf7af9133ecfd8b636a8e712a2bc22aa431b44"),
    prev_index = 0,
    script_sig = None
)

tx_in.prev_tx_script_pubkey = out2_script

tx = Tx(
    tx_ins=[tx_in],
    tx_outs=[tx_out1, tx_out2]
)

message = tx.encode(sig_index=0)
signature = sign(from_sk, message)

# @todo


