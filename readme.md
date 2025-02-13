# `crc.crc32`

A CRC32 checksum - implemented in a lower-level language. Here we'll explore a Nim module that calculates a CRC32 checksum using a precomputed lookup table


```py
from crc import crc32

crc32('Hello World')
0x4a17b156
```


- **Is fast fast fast**
  Using a compiled nim module under-the-hood we gain c-speed fastness. Pre-computing the CRC table ensures only XOR bit manipulation is the main task.
- **Table-Driven Approach:**
  Precomputing a lookup table transforms an algorithm that could have been computationally expensive into one that’s highly efficient.
- **Made in Nim (exported to Python)**
  Nim's `nimpy` module makes it simple to expose native Nim code to Python.
- Matches online examples:
    Using polynomial `0xEDB88320` ensures we match JS and other online examples.

---

> Benchmarks mean nothing. 99% of the time they only detail the 1% of perfect cases. That said - Checkout _this_ benchmark:


+ Best result operations per second is 1% faster than `anycrc` (the fastest) - especially from cold-start.
+ On average it's \~5% slower (AFTER WARMUP!)
+ But also; `any_crc` is 4% slower than its own fastest run

```
Name (time in ns)                                        OPS (Kops/s)            Rounds  Iterations
---------------------------------------------------------------------------------------------------
test_anycrc_32 (NOW)                                         834.4711 (1.0)       98107           1
test_anycrc_32 (windows-cpython-3.8-64bit/0030_51bb0b1)      802.7725 (0.96)      85845           1
test_crc_32 (NOW)                                            796.8278 (0.95)      78040           1
test_crc_32 (windows-cpython-3.8-64bit/0030_51bb0b1)         730.7685 (0.88)      98107           1
```

Caveats:

+ speed runs are from cold-start, then 4 hot runs. `any crc` is faster after warm-up.
+ This is an older version of Nim, Windows, and Python - newer will probably be faster
+ *This is using a custom compiled python 3.8 - for other reasons...*

Legend:

+ `test_anycrc_32`: the `anycrc` standard 32 poly model.
+ `test_crc_32`: my implementation - same poly.

> `1.0` means _the target - as the fastest_
+ `0.99` defines _1% from the target fastest_.


```

Name                     Outliers  OPS (Kops/s)            Rounds
-------------------------------------------------------------------
test_anycrc_32          5906;5906      755.0418 (0.99)      79854
test_crc_32             2497;2497      759.6637 (1.0)       92799
-------------------------------------------------------------------



Name                       Min                    Max                  Mean
--------------------------------------------------------------------------------------
test_anycrc_32        873.0000 (1.0)      80,088.0000 (1.0)      1,324.4300 (1.01)
test_crc_32           873.0000 (1.00)     95,522.0000 (1.19)     1,316.3719 (1.0)
--------------------------------------------------------------------------------------


Name                   StdDev                Median                 IQR
--------------------------------------------------------------------------------------
test_anycrc_32       676.4560 (1.11)     1,165.0000 (1.0)      291.0000 (1.00)
test_crc_32          611.1147 (1.0)      1,165.0000 (1.0)      291.0000 (1.0)
--------------------------------------------------------------------------------------


Legend:
  Outliers: 1 Standard Deviation from Mean; 1.5 IQR (InterQuartile Range) from 1st Quartile and 3rd Quartile.
  OPS: Operations Per Second, computed as 1 / Mean
```

General benchmarks:

```
Name (time in ns)              IQR             Outliers  OPS (Kops/s)            Rounds  Iterations
-----------------------------------------------------------------------------------------------------------------------------------
test_anycrc_32 (stored)   291.0000 (>1000.0)  6130;6130      864.9554 (1.0)       85845           1
test_anycrc_32 (NOW)      291.0000 (>1000.0)  1410;2646      859.3654 (0.99)      81760           1
test_crc_32 (stored)      291.0000 (>1000.0)  1786;3553      716.0017 (0.83)      83753           1
test_crc_32 (NOW)           0.0000 (1.0)     1507;23624      790.0587 (0.91)      90359           1
-----------------------------------------------------------------------------------------------------------------------------------
```


### Compatability

The results are a HEX (octet) numbers and uses the standard crc polynomial. Therefore results are compatible with [online examples](https://stackoverflow.com/questions/18638900/javascript-crc32)

Python:

```py
# python
from crc import crc32
python_result = crc32('The quick brown fox jumps over the lazy dog')
0x414FA339
```

JS:

```js
// js
let msg = 'The quick brown fox jumps over the lazy dog'
// An exact value from py
python_result = 0x414FA339
// https://www.npmjs.com/package/@tsxper/crc32
const result = crc32(msg)
1095738169 // is 0x414FA339 in integer form.
result == python_result

crc32(msg).toString(16)
'414fa339'
```


## More Info

The CRC32 (Cyclic Redundancy Check) algorithm is widely used for error-checking in data transmissions. At its core, it processes a stream of bytes to generate a unique checksum that helps detect accidental changes in the data.


```nim
type CRC32* = uint32
const initCRC32* = CRC32(0xFFFFFFFF)
```

We define a new type alias `CRC32` for a 32-bit unsigned integer. The asterisks (`*`) indicate that these definitions are exported—making them visible to Python.

### Pre Computed CRC table

One of the critical performance boosts of CRC32 is the use of a lookup table. Instead of computing the CRC value bit by bit for every character, the table lets you process one byte at a time.

For each byte, we simulate processing 8 bits (like iterating over each bit in the byte). The use of bitwise operators (`and`, `shr` for shift-right, and `xor`) is very similar to Python’s bit manipulation:

```python
  if (rem & 1) > 0:
      rem = (rem >> 1) ^ 0xedb88320
  else:
      rem = rem >> 1
```

After processing all bits, the computed value for that byte is stored in the lookup table (`result[i]` in Nim, similar to assigning to a list index in Python).

Once this function is called, the table is memoized.


```nim
var crc32table = createCRCTable()
```

### Crunching the Checksum

Now that we have our lookup table, the next step is to compute the CRC32 checksum of a given string.

```nim
proc crc32(s: string): CRC32 {.exportpy.} =
  result = initCRC32
  for c in s:
    result = (result shr 8) xor crc32table[(result and 0xff) xor uint32(ord(c))]
  result = not result
```

The function takes a string and returns a `CRC32` value. The `{.exportpy.}` pragma marks this function to be exported to Python, making it callable like any regular Python function. The CRC computation starts with a predefined constant (`0xFFFFFFFF`)

### Processing Each Character

For each character:

1. **Extract the Least Significant Byte (LSB):**
     `(result and 0xff)` which isolates the lowest 8 bits of the result.
2. **Update Using the Lookup Table:**
     The current byte value is XORed with the LSB, and the lookup table is used to retrieve the corresponding value. The CRC result is then updated by shifting right by 8 bits and applying an XOR with the looked-up value.

After processing all characters, the result is inverted using a bitwise NOT. This final step produces the completed CRC32 checksum.

