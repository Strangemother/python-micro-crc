# Python `microcrc.crc32`

A CRC32 checksum for python - implemented in Nim lang for lower-level language.


# Install and Use

No compilation or setup. Just a micro library for the `crc32` function

```bash
pip install microcrc
```

Usage:

```py
from microcrc import crc32

result = crc32('Hello World')
1243066710

hex(result)
'0x4a17b156'
```

That's it - use it for anything.

---

+ **Is fast fast fast**

    Using a compiled nim module under-the-hood we gain c-speed fastness. Pre-computing the CRC table ensures only XOR bit manipulation is the main task.

+ **Table-Driven Approach:**

    Precomputing a lookup table speeds up end-usage, so it's more efficent when running.

+ **Made in Nim (exported to Python)**

    Nim's `nimpy` module makes it simple to expose native Nim code to Python.

+ Matches online examples:

    Using polynomial `0xEDB88320` ensures we match JS and other online examples.


## How it works

The core function `crc32` is written in "nim-lang" and compiled into a `.pyd`, bundled into the package.

The nim module `./src/crc.nim` contains a _pre-compiled_ lookup table and the python exposed proc. To gain more speed the proc uses memory address pointers, using the pre-computed lookup-table when computing the xor.


## Benchmark

> Benchmarks mean nothing. 99% of the time they only detail the 1% of perfect cases. That said - Checkout _this_ benchmark:

Comparing against the fastest python crc library https://github.com/marzooqy/anycrc

```
Name                     Outliers  OPS (Kops/s)            Rounds
-------------------------------------------------------------------
test_anycrc_32          5906;5906      755.0418 (0.99)      79854
test_crc_32             2497;2497      759.6637 (1.0)       92799
-------------------------------------------------------------------
```

We see that `anycrc` is 1% slower!

---

### Benchmark Notes

+ Best result operations per second is 1% faster than `anycrc` (the fastest in python) - especially from cold-start.
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

+ speed runs are from cold-start, then 4 hot runs. `anycrc` is faster after warm-up.
+ This is an older version of Nim, Windows, and Python - newer will probably be faster
+ [anycrc](https://github.com/marzooqy/anycrc) is a much better product

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
v = crc32('The quick brown fox jumps over the lazy dog')
1095738169 # int

hex(v)
'0x414fa339'

oct(v)
'0o10123721471'
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

---

