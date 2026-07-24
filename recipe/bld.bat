@echo on

if "%target_platform%" == "win-arm64" (
    rem ARM64 cross-compilation: create a meson cross file so meson
    rem does not attempt to run the ARM64 sanity-check binary on x86_64.
    (echo [host_machine]
    echo system = 'windows'
    echo cpu_family = 'aarch64'
    echo cpu = 'aarch64'
    echo endian = 'little'
    echo.
    echo [properties]
    echo needs_exe_wrapper = true) > cross_file.ini
    if errorlevel 1 exit 1
    set "MESON_CROSS=--cross-file cross_file.ini"
    rem gas-preprocessor.pl is not yet available on conda-forge, so
    rem disable ARM64 ASM; dav1d falls back to pure-C implementations.
    set "MESON_ARM64_ASM=-Denable_asm=false"
) else (
    set "MESON_CROSS="
    set "MESON_ARM64_ASM="
)

meson setup builddir           ^
    %MESON_ARGS%               ^
    --prefix=%LIBRARY_PREFIX%  ^
    -Denable_tests=false       ^
    %MESON_ARM64_ASM%          ^
    %MESON_CROSS%
if errorlevel 1 exit 1

meson compile -C builddir
if errorlevel 1 exit 1

meson install -C builddir --no-rebuild
if errorlevel 1 exit 1
