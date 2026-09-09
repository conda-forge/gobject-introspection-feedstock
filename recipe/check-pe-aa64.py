import glob
import struct
import sys


AA64 = 0xAA64


def machine(path):
    with open(path, "rb") as stream:
        if stream.read(2) != b"MZ":
            raise ValueError("missing MZ header")
        stream.seek(0x3C)
        pe_offset_data = stream.read(4)
        if len(pe_offset_data) != 4:
            raise ValueError("truncated DOS header")
        pe_offset = struct.unpack("<I", pe_offset_data)[0]
        stream.seek(pe_offset)
        if stream.read(4) != b"PE\0\0":
            raise ValueError("missing PE signature")
        machine_data = stream.read(2)
        if len(machine_data) != 2:
            raise ValueError("truncated COFF header")
        return struct.unpack("<H", machine_data)[0]


if len(sys.argv) < 2:
    raise SystemExit("usage: check-pe-aa64.py PATH_OR_GLOB [...]")

for pattern in sys.argv[1:]:
    matches = glob.glob(pattern)
    if not matches:
        raise SystemExit(f"no files matched: {pattern}")
    for path in matches:
        try:
            actual = machine(path)
        except (OSError, ValueError) as error:
            raise SystemExit(f"{path}: {error}") from error
        if actual != AA64:
            raise SystemExit(f"{path}: expected PE machine 0x{AA64:04X}, got 0x{actual:04X}")
        print(f"{path}: PE machine AA64")
