
import dist.crc as MODULE

NAME = "crc32"
TEST_STRING = "The quick brown fox jumps over the lazy dog"
EXPECTED = 0x414FA339

SUCCESS = f"function: {NAME} passed tests."

assert hasattr(MODULE, NAME)
func = getattr(MODULE, NAME)
assert callable(func)
assert func(TEST_STRING) == EXPECTED

print(SUCCESS)