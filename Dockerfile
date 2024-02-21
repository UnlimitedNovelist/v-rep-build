FROM debian:12 AS install_dep
LABEL Description="This image is used to build V-Rep (CoppeliaSim) for Linux" Vendor="n/a" Version="0.0.0"

ENV DEBIAN_FRONTEND=noninteractive

# Update packages
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    tree \
    cmake \
    checkinstall \
    qt5-qmake \
    qtbase5-dev

# Install dependencies to build v-rep
RUN apt-get install -y \
    liblua5.3-dev \
    libtinyxml2-dev \
    libboost-all-dev \
    libeigen3-dev \
    cppcheck \
    swig \
    libgmp-dev \
    libmpfr-dev \
    libopenblas-dev \
    xsltproc \
    python3-xmlschema \
    libcgal-dev \
    libbullet-dev \
    clang-format \
    ruby-dev \
    libzmq3-dev

FROM debian:12 AS cloner

ENV DEBIAN_FRONTEND=noninteractive

# Update packages
RUN apt-get update && apt-get install -y \
    curl \
    git \
    tree

WORKDIR /v-rep

# Getting source code for v-rep
ARG version=coppeliasim-v4.6.0-rev14

RUN git clone --depth 1 --branch $version --recursive https://github.com/CoppeliaRobotics/helpFiles.git && \
    git clone --depth 1 --branch $version --recursive https://github.com/CoppeliaRobotics/addOns.git && \
    git clone --depth 1 --branch $version --recursive https://github.com/CoppeliaRobotics/scenes.git && \
    git clone --depth 1 --branch $version --recursive https://github.com/CoppeliaRobotics/models.git

ADD programming ./programming
RUN cat programming/readme.txt | grep -Eo "(http|https)://[a-zA-Z0-9./?=_%:-]*" | sort -u > /v-rep/cloning-url.txt
RUN cat cloning-url.txt && sed -i '1d;$d' cloning-url.txt && cat cloning-url.txt

RUN URLS=$(cat cloning-url.txt) && \
    cd programming && \
    for URL in $URLS; do git clone --depth 1 --branch $version --recursive "$URL.git"; done && \
    mv coppeliaSimLib ../  && \
    mkdir -p ros_packages ros2_packages && \
    mv simROS ros_bubble_rob ros_packages && \
    mv simROS2 ros2_bubble_rob ros2_packages 

RUN rm /v-rep/cloning-url.txt

# Show folder structure
RUN tree -d -L 3

FROM install_dep AS builder

WORKDIR /v-rep
COPY --from=cloner /v-rep .

#RUN ls /v-rep

COPY other_mod.sh /other_mod.sh
RUN bash /other_mod.sh && rm /other_mod.sh

#SHELL ["/bin/bash", "-c"]
#RUN echo 'deb-src http://httpredir.debian.org/debian bookworm main non-free contrib' >> /etc/apt/sources.list
#RUN apt-get update && apt-get source libqscintilla2-qt5-15

COPY keep_mod.sh /keep_mod.sh
RUN bash /keep_mod.sh && rm /keep_mod.sh

FROM install_dep AS qscintilla

WORKDIR /v-rep
COPY --from=cloner /v-rep .

# Build qscintilla 
RUN git clone --depth 1 --branch v2.11.6 --recursive https://github.com/opencor/qscintilla.git
 
RUN cd qscintilla/Qt4Qt5 && mkdir release && \
    cd release && \
    qmake ../qscintilla.pro "CONFIG+=release" && make && make install

COPY qscintilla_mod.sh /qscintilla_mod.sh
RUN bash /qscintilla_mod.sh && rm /qscintilla_mod.sh

FROM debian:12 AS release

WORKDIR /release

COPY --from=builder /v-rep .
COPY --from=qscintilla /v-rep .

#RUN find /v-rep/ -type f -name '*.so' # | xargs cp -t /release
RUN ls /release
RUN cat /release/result.txt

# Clean up to reduce image size
RUN apt-get clean && \
    rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/*

ENTRYPOINT ["/bin/bash"]
