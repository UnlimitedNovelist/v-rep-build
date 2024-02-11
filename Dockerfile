FROM debian:12 AS builder
LABEL Description="This image is used to build V-Rep (CoppeliaSim) for Linux" Vendor="n/a" Version="0.0.0"

ENV DEBIAN_FRONTEND=noninteractive

# Update packages
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    tree \
    cmake \
    qt5-qmake \
    qtbase5-dev

WORKDIR /v-rep
ADD programming ./programming
RUN cat programming/readme.txt | grep -Eo "(http|https)://[a-zA-Z0-9./?=_%:-]*" | sort -u > /v-rep/cloning-url.txt
RUN cat cloning-url.txt && sed -i '1d;$d' cloning-url.txt && cat cloning-url.txt

# Getting source code for v-rep
ARG version=coppeliasim-v4.6.0-rev14
RUN URLS=$(cat cloning-url.txt) && \
    cd programming && \
    for URL in $URLS; do git clone --depth 1 --branch $version --recursive "$URL.git"; done && \
    mv coppeliaSimLib ../  && \
    mkdir -p ros_packages ros2_packages && \
    mv simROS ros_bubble_rob ros_packages && \
    mv simROS2 ros2_bubble_rob ros2_packages 

# Show folder structure
RUN tree -d -L 3

# Build qscintilla 
RUN git clone --depth 1 --branch v2.11.6 --recursive https://github.com/opencor/qscintilla.git
 
#RUN cd qscintilla/Qt4Qt5 && mkdir release && \
#    cd release && \
#    qmake ../qscintilla.pro "CONFIG+=release" && make && make install

# Install dependencies to build v-rep
RUN apt-get install -y \
    liblua5.3-dev \
    libtinyxml2-dev \
    libboost-all-dev

#SHELL ["/bin/bash", "-c"]

#RUN echo 'deb-src http://httpredir.debian.org/debian bookworm main non-free contrib' >> /etc/apt/sources.list
#RUN apt-get update && apt-get source libqscintilla2-qt5-15
RUN cd programming && find . -type d -maxdepth 1 > /v-rep/cloning-dir.txt
RUN REPOS=$(cat /v-rep/cloning-dir.txt) && \
    cd programming && \
    for REPO in $REPOS; do bash -xc "pushd $REPO && cmake -B build -S . && cmake --build build && popd"; done
#RUN cd coppeliaSimLib && cmake -DQSCINTILLA_DIR:PATH=/v-rep/qscintilla -B build -S . && cmake --build build

RUN mkdir -p /release
RUN find /v-rep/ -type f -name '*.so'

# Clean up to reduce image size
#RUN apt-get clean && \
#    rm -rf \
#        /var/lib/apt/lists/* \
#        /tmp/* \
#        /var/tmp/*

ENTRYPOINT ["/bin/bash"]
