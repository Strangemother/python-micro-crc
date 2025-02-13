import pytest, sys
from pathlib import Path

HERE = Path(__file__).parent
dist = (HERE / 'dist').absolute()
sys.path.append(str(dist))


from crc import crc32

assert crc32 is not None, "crc.crc32 is not a found function"

test_data = b"hello world"

@pytest.mark.benchmark(group="crc_32")
def test_crc_32(benchmark):
    benchmark(crc32, test_data)
