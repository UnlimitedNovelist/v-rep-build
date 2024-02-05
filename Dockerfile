FROM debian:12
LABEL Description="This image is used to build V-Rep (CoppeliaSim) for Linux" Vendor="n/a" Version="0.0.0"

ENV DEBIAN_FRONTEND=noninteractive

# Update packages
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    cmake \
    qt5-qmake \
    qtbase5-dev

WORKDIR /v-rep

# Build qscintilla 
RUN git clone --depth 1 --branch v2.11.6 --recursive https://github.com/opencor/qscintilla.git
 
RUN cd qscintilla/Qt4Qt5 && mkdir release && \
    cd release && \
    qmake ../qscintilla.pro "CONFIG+=release" && make && make install

# Getting source code for v-rep
RUN mkdir -p programming
RUN cd programming && \
    git clone --depth 1 --branch coppeliasim-v4.6.0-rev14 --recursive https://github.com/CoppeliaRobotics/include.git && \
    git clone --depth 1 --branch coppeliasim-v4.6.0-rev14 --recursive https://github.com/CoppeliaRobotics/coppeliaKinematicsRoutines.git && \
    git clone --depth 1 --branch coppeliasim-v4.6.0-rev14 --recursive https://github.com/CoppeliaRobotics/coppeliaGeometricRoutines.git
RUN git clone --depth 1 --branch coppeliasim-v4.6.0-rev14 --recursive https://github.com/CoppeliaRobotics/CoppeliaSimLib.git

# Install dependencies to build v-rep
RUN apt-get install -y \
    liblua5.3-dev \
    libtinyxml2-dev \
    libboost-all-dev

#RUN echo 'deb-src http://httpredir.debian.org/debian bookworm main non-free contrib' >> /etc/apt/sources.list
#RUN apt-get update && apt-get source libqscintilla2-qt5-15

RUN cd CoppeliaSimLib && cmake -DQSCINTILLA_DIR:PATH=/v-rep/qscintilla -B build -S . && cmake --build build

# Clean up to reduce image size
RUN apt-get clean && \
    rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/*

ENTRYPOINT ["/bin/bash"]
