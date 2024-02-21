#! /bin/bash

REPOS=("coppeliaSimClient" "coppeliaSimClientPython" "wsRemoteApi" "legacyRemoteApi" "zmqRemoteApi")

for REPO in $REPOS; do
    pushd /v-rep/programming/$REPO
    
    cmake -DCMAKE_BUILD_TYPE=Release -B build -S .
    cmake --build build
    cmake --install build

    if [ $? -eq 0 ]; then
        echo "$REPO -- Success" >> /v-rep/result.txt
    else    
        echo "$REPO -- Failed" >> /v-rep/result.txt
    fi

    popd
done