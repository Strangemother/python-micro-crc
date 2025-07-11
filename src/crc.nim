import strutils, nimpy, system

type CRC32* = uint32
const initCRC32* = CRC32(0xFFFFFFFF)
const polyCRC32* = CRC32(0xedb88320)

# Compute the CRC32 table at compile time.
const crc32table* =
  block:
    var table: array[256, CRC32]
    for i in 0 .. 255:
      var r = CRC32(i)
      for _ in 0 ..< 8:
        if (r and 1) != 0:
          r = (r shr 1) xor polyCRC32
        else:
          r = r shr 1
      table[i] = r
    table

proc crc32(s: string): CRC32 {.exportpy, inline.} =
  {.push checks: off.}  # disable bounds and other runtime checks
  var crc = initCRC32
  if s.len > 0:
    var p = cast[ptr uint8](s[0].addr)  # pointer to the first byte
    var i = 0
    while i < s.len:
      crc = (crc shr 8) xor crc32table[(crc and 0xff) xor uint32(p[])]
      p = cast[ptr uint8](cast[uint](p) + 1)
      inc(i)
  result = not crc
  {.pop.}  # restore previous check settings

proc `$`(c: CRC32): string = int64(c).toHex(8)

assert crc32("The quick brown fox jumps over the lazy dog") == 0x414FA339
