#!/bin/sh

set -ex

mkdir -p build
cd build

cmake -G Ninja \
    ${CMAKE_ARGS} \
    -DPROJECT_BINARY_DIR=$PREFIX \
    -DFAISS_PATH=$PREFIX/lib/libfaiss.so \
    ..

cmake --build .
cmake --install .

cd ../python
$PYTHON setup.py install
