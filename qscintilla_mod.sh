#! /bin/bash

pushd /v-rep/coppeliaSimLib && cmake -DQSCINTILLA_DIR:PATH=/v-rep/qscintilla -B build -S . && cmake --build build && cmake --install build
popd

pushd /v-rep/programming/simCodeEditor && cmake -DQSCINTILLA_DIR:PATH=/v-rep/qscintilla -B build -S . && cmake --build build && cmake --install build
popd
