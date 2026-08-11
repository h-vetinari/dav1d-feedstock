@echo on

if "%target_platform%" == "win-arm64" (
    rem gas-preprocessor.pl preprocesses GAS-format ARM64 assembly for
    rem armasm64.exe.  Copy it and the cpp wrapper into the MSYS2 bin dir
    rem so that MSYS2 perl can find and exec them as POSIX scripts.
    copy /Y "%RECIPE_DIR%\gas-preprocessor.pl" "%BUILD_PREFIX%\Library\usr\bin\" && copy /Y "%RECIPE_DIR%\cpp" "%BUILD_PREFIX%\Library\usr\bin\cpp"
    if errorlevel 1 exit 1
)

meson setup builddir           ^
    %MESON_ARGS%               ^
    --prefix=%LIBRARY_PREFIX%  ^
    -Denable_tests=false
if errorlevel 1 exit 1

meson compile -C builddir
if errorlevel 1 exit 1

meson install -C builddir --no-rebuild
if errorlevel 1 exit 1
