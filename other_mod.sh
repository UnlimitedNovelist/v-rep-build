#! /bin/bash

cd /v-rep/programming && find . -type d -maxdepth 1 -mindepth 1 | sort -u > /v-rep/cloning-dir.txt && cat /v-rep/cloning-dir.txt

# Ignore some repo in this run
sed '/include/d' /v-rep/cloning-dir.txt
sed '/simExtCam/d' /v-rep/cloning-dir.txt
sed '/simExtJoystick/d' /v-rep/cloning-dir.txt
sed '/simCodeEditor/d' /v-rep/cloning-dir.txt

REPOS=$(cat /v-rep/cloning-dir.txt)

for REPO in $REPOS
do
    pushd /v-rep/programming/$REPO
    cmake -DCMAKE_BUILD_TYPE=Release -B build -S .
    cmake --build build
    cmake --install build
    popd
done

rm /v-rep/cloning-dir.txt 

#RUN rm -r -v programming/simPovRay/binaries/
#RUN find /v-rep/ -type f -name '*.so' | xargs cp -t /release
#RUN find /v-rep/ -type f -name '*.so.*' | xargs cp -t /release
#RUN ls /release