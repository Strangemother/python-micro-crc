import pytest
import anycrc


test_data = b"hello world"


@pytest.mark.benchmark(group="crc_32")
def test_anycrc_32(benchmark):
    crc32 = anycrc.Model('CRC32-MPEG-2')
    benchmark(crc32.calc, test_data)
