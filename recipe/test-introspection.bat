@echo on
setlocal

set "SMOKE_BUILD=%CD%\gi-smoke-build"
set "PATH=%SMOKE_BUILD%;%PREFIX%\Library\bin;%PATH%"
set "PKG_CONFIG_PATH=%PREFIX%\Library\lib\pkgconfig;%PREFIX%\Library\share\pkgconfig;%PKG_CONFIG_PATH%"

cmake -S "%~dp0." -B "%SMOKE_BUILD%" -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH="%PREFIX%\Library"
if errorlevel 1 exit /b 1

cmake --build "%SMOKE_BUILD%" --config Release --verbose
if errorlevel 1 exit /b 1

python "%PREFIX%\Library\bin\g-ir-scanner" ^
  --no-libtool ^
  --compiler=msvc ^
  --namespace=CondaGISmoke ^
  --nsversion=1.0 ^
  --identifier-prefix=CondaGISmoke ^
  --symbol-prefix=conda_gi_smoke ^
  --warn-all ^
  --warn-error ^
  --include=GObject-2.0 ^
  --add-include-path="%PREFIX%\Library\share\gir-1.0" ^
  --pkg=gobject-2.0 ^
  --library=condagismoke ^
  --library-path="%SMOKE_BUILD%" ^
  --c-include=condagismoke.h ^
  --output="%SMOKE_BUILD%\CondaGISmoke-1.0.gir" ^
  -I"%~dp0." ^
  "%~dp0condagismoke.h" ^
  "%~dp0condagismoke.c"
if errorlevel 1 exit /b 1

"%PREFIX%\Library\bin\g-ir-compiler.exe" ^
  --includedir="%PREFIX%\Library\share\gir-1.0" ^
  --output="%SMOKE_BUILD%\CondaGISmoke-1.0.typelib" ^
  "%SMOKE_BUILD%\CondaGISmoke-1.0.gir"
if errorlevel 1 exit /b 1

set "GI_TYPELIB_PATH=%SMOKE_BUILD%;%PREFIX%\Library\lib\girepository-1.0"

"%PREFIX%\Library\bin\g-ir-inspect.exe" ^
  --version=1.0 ^
  --print-shlibs ^
  --print-typelibs ^
  CondaGISmoke > "%SMOKE_BUILD%\inspect.txt"
if errorlevel 1 exit /b 1

type "%SMOKE_BUILD%\inspect.txt"
findstr /L /C:"shlib: condagismoke.dll" "%SMOKE_BUILD%\inspect.txt"
if errorlevel 1 exit /b 1
findstr /L /C:"typelib: GObject-2.0" "%SMOKE_BUILD%\inspect.txt"
if errorlevel 1 exit /b 1

"%PREFIX%\Library\bin\g-ir-generate.exe" ^
  --output="%SMOKE_BUILD%\CondaGISmoke-roundtrip.gir" ^
  "%SMOKE_BUILD%\CondaGISmoke-1.0.typelib"
if errorlevel 1 exit /b 1
if not exist "%SMOKE_BUILD%\CondaGISmoke-roundtrip.gir" exit /b 1

"%SMOKE_BUILD%\gi-repository-consumer.exe"
if errorlevel 1 exit /b 1

python check-pe-aa64.py ^
  "%SMOKE_BUILD%\condagismoke.dll" ^
  "%SMOKE_BUILD%\gi-repository-consumer.exe"
if errorlevel 1 exit /b 1
