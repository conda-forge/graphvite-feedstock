@echo on

mkdir build
cd build

SetLocal EnableDelayedExpansion

REM for documentation see e.g.
REM docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html#building-for-maximum-compatibility
REM docs.nvidia.com/cuda/cuda-compiler-driver-nvcc/index.html#ptxas-options-gpu-name
REM docs.nvidia.com/cuda/cuda-compiler-driver-nvcc/index.html#gpu-feature-list

REM for -real vs. -virtual, see cmake.org/cmake/help/latest/prop_tgt/CUDA_ARCHITECTURES.html
REM this is to support PTX JIT compilation; see first link above or cf.
REM devblogs.nvidia.com/cuda-pro-tip-understand-fat-binaries-jit-caching

REM %MY_VAR:~0,2% selects first two characters
if "%cuda_compiler_version:~0,2%"=="11" (
    if "%cuda_compiler_version:~0,4%"=="11.0" (
        REM cuda 11.0 deprecates arches 35, 50
        set "CMAKE_CUDA_ARCHS=52-real;60-real;61-real;70-real;75-real;80"
    ) else (
        set "CMAKE_CUDA_ARCHS=52-real;60-real;61-real;70-real;75-real;80-real;86"
    )
)

REM cmake does not generate output for the call below; echo some info
echo Set up CUDA arches: CMAKE_CUDA_ARCHITECTURES=!CUDA_CONFIG_ARGS!

set GLOG_LIBRARY=%LIBRARY_BIN:\=/%/glog.dll
set GFLAGS_LIBRARY=%LIBRARY_BIN:\=/%/gflags.dll

cmake -G "Ninja" ^
    %CMAKE_ARGS% ^
    -DPROJECT_BINARY_DIR=%LIBRARY_PREFIX:\=/% ^
    -Dglog_ROOT=%LIBRARY_LIB:\=/%/cmake/glog/ ^
    -Dgflags_ROOT=%LIBRARY_LIB:\=/%/cmake/gflags/ ^
    -DFAISS_PATH=%LIBRARY_PREFIX:\=/%/bin/faiss.dll ^
    -DGLOG_LIBRARY=%LIBRARY_PREFIX:\=/%/bin/glog.dll ^
    -DGFLAGS_LIBRARY=%LIBRARY_PREFIX:\=/%/bin/gflags.dll ^
    -DCMAKE_INSTALL_LIBDIR=%LIBRARY_LIB:\=/% ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_LIB:\=/%/cmake;%LIBRARY_LIB:\=/%/cmake/glog;%LIBRARY_LIB:\=/%/cmake/gflags" ^
    -DCMAKE_MODULE_PATH="%LIBRARY_LIB:\=/%/cmake;%LIBRARY_LIB:\=/%/cmake/glog;%LIBRARY_LIB:\=/%/cmake/gflags" ^
    -DCMAKE_CUDA_ARCHITECTURES="!CMAKE_CUDA_ARCHS!" ^
    ..
if %ERRORLEVEL% neq 0 exit 1

cmake --build . --config Release -j %CPU_COUNT%
if %ERRORLEVEL% neq 0 exit 1
cmake --install . --config Release --prefix "%LIBRARY_PREFIX:\=/%"
if %ERRORLEVEL% neq 0 exit 1

cd ../python
%PYTHON% setup.py install
if %ERRORLEVEL% neq 0 exit 1
