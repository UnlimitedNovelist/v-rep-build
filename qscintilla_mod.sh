#! /bin/bash

pushd /v-rep/coppeliaSimLib && cmake -DCMAKE_BUILD_TYPE=Release -DQSCINTILLA_DIR:PATH=/v-rep/qscintilla -B build -S . && cmake --build build && cmake --install build
popd

pushd /v-rep/programming/simCodeEditor && cmake -DCMAKE_BUILD_TYPE=Release -DQSCINTILLA_DIR:PATH=/v-rep/qscintilla -B build -S . && cmake --build build && cmake --install build
popd
