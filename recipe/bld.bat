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
    echo [binaries]
    echo ar = 'lib'
    echo windres = 'rc'
    echo.
    echo [properties]
    echo needs_exe_wrapper = true) > cross_file.ini
    if errorlevel 1 exit 1
    set "MESON_CROSS=--cross-file cross_file.ini"
    rem gas-preprocessor.pl preprocesses GAS-format ARM64 assembly for
    rem armasm64.exe.  Copy it and the cpp wrapper into the MSYS2 bin dir
    rem so that MSYS2 perl can find and exec them as POSIX scripts.
    copy /Y "%RECIPE_DIR%\gas-preprocessor.pl" "%BUILD_PREFIX%\Library\usr\bin\" && copy /Y "%RECIPE_DIR%\cpp" "%BUILD_PREFIX%\Library\usr\bin\cpp"
    if errorlevel 1 exit 1
) else (
    set "MESON_CROSS="
)

meson setup builddir           ^
    %MESON_ARGS%               ^
    --prefix=%LIBRARY_PREFIX%  ^
    -Denable_tests=false       ^
    %MESON_CROSS%
if errorlevel 1 exit 1

meson compile -C builddir
if errorlevel 1 exit 1

meson install -C builddir --no-rebuild
if errorlevel 1 exit 1
