SET "target_app_name=crc"
ECHO "Compiling %target_app_name% "
nim c --opt:speed -d:release --app:lib --out:dist/%target_app_name%.pyd --threads:on --tlsEmulation:off --passL:-static src/%target_app_name%
ECHO "Testing"
py tests.py
