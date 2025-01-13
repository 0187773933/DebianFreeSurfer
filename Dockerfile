FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

# Install GCC 4.8 and dependencies
RUN apt-get -y update && apt-get install -y \
    build-essential \
    gcc-4.8 g++-4.8 gfortran-4.8 \
    cmake \
    git \
    wget \
    tcsh \
    xxd \
    libblas-dev \
    liblapack-dev \
    zlib1g-dev \
    libxmu-dev \
    libxmu-headers \
    libxi-dev \
    libxt-dev \
    libx11-dev \
    libglu1-mesa-dev \
    libboost-all-dev \
    libarmadillo-dev \
    libopencv-dev \
    libvtk7-dev \
    qtbase5-dev \
    libgts-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libopenblas-dev \
    libeigen3-dev \
    libcrypto++-dev \
    libyaml-cpp-dev \
    libturbojpeg0-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


# Configure GCC 4.8 as the default compiler
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 48 \
    --slave /usr/bin/g++ g++ /usr/bin/g++-4.8 \
    --slave /usr/bin/gcov gcov /usr/bin/gcov-4.8 \
    --slave /usr/bin/gfortran gfortran /usr/bin/gfortran-4.8 && \
    update-alternatives --set gcc /usr/bin/gcc-4.8

# Download and build portable CMake 3.22.1+ for ITK
RUN mkdir -p /usr/local/cmake-portable && cd /usr/local && \
    wget https://github.com/Kitware/CMake/releases/download/v3.22.1/cmake-3.22.1.tar.gz && \
    tar -xzvf cmake-3.22.1.tar.gz && cd cmake-3.22.1 && \
    ./bootstrap --prefix=/usr/local/cmake-portable --parallel=$(nproc) && \
    make -j$(nproc) && make install && \
    cd .. && rm -rf cmake-3.22.1 cmake-3.22.1.tar.gz

# Download and build portable GCC
RUN mkdir -p /usr/local/gcc-portable && cd /usr/local && \
    wget http://ftp.gnu.org/gnu/gcc/gcc-11.3.0/gcc-11.3.0.tar.gz && \
    tar -xvzf gcc-11.3.0.tar.gz && cd gcc-11.3.0 && \
    ./contrib/download_prerequisites && \
    mkdir build && cd build && \
    ../configure --prefix=/usr/local/gcc-portable --enable-languages=c,c++ --disable-multilib && \
    make -j$(nproc) && make install && \
    cd ../.. && rm -rf gcc-11.3.0 gcc-11.3.0.tar.gz

# Build and install ITK using portable GCC and CMake
RUN mkdir -p /usr/src/ITK && cd /usr/src/ITK && \
    git clone https://github.com/InsightSoftwareConsortium/ITK.git --depth 1 && \
    cd ITK && \
    mkdir build && cd build && \
    CC=/usr/local/gcc-portable/bin/gcc CXX=/usr/local/gcc-portable/bin/g++ \
    /usr/local/cmake-portable/bin/cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/usr/local \
        -DCMAKE_EXE_LINKER_FLAGS="-Wl,-rpath,/usr/local/gcc-portable/lib64" \
        -DCMAKE_SHARED_LINKER_FLAGS="-Wl,-rpath,/usr/local/gcc-portable/lib64" && \
    make -j$(nproc) && make install && \
    ldconfig

# Build and install VTK from source
RUN mkdir -p /usr/src/VTK && cd /usr/src/VTK && \
    git clone --depth 1 https://github.com/Kitware/VTK.git && \
    cd VTK && \
    mkdir build && cd build && \
    CC=/usr/local/gcc-portable/bin/gcc CXX=/usr/local/gcc-portable/bin/g++ \
    /usr/local/cmake-portable/bin/cmake .. -DCMAKE_BUILD_TYPE=Release \
        -DVTK_GROUP_ENABLE_Qt=NO \
        -DVTK_GROUP_ENABLE_Imaging=YES \
        -DVTK_GROUP_ENABLE_Rendering=YES \
        -DVTK_GROUP_ENABLE_StandAlone=YES \
        -DVTK_GROUP_ENABLE_Views=YES \
        -DBUILD_SHARED_LIBS=ON \
        -DCMAKE_INSTALL_PREFIX=/usr/local \
        -DCMAKE_EXE_LINKER_FLAGS="-Wl,-rpath,/usr/local/gcc-portable/lib64" \
        -DCMAKE_SHARED_LINKER_FLAGS="-Wl,-rpath,/usr/local/gcc-portable/lib64" && \
    make -j$(nproc) && make install && \
    ldconfig

# Clone FreeSurfer repository
WORKDIR /usr/src
RUN git clone https://github.com/freesurfer/freesurfer.git --depth 1

# Set working directory
WORKDIR /usr/src/freesurfer

RUN apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository universe && \
    apt-get update

RUN apt-get install -y \
    qt5-default qttools5-dev-tools qttools5-dev libqt5x11extras5 libqt5x11extras5-dev

RUN export CMAKE_PREFIX_PATH="/usr/lib/x86_64-linux-gnu/cmake/Qt5"

# Build FreeSurfer
RUN mkdir -p build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH="/usr/local;/usr/lib/x86_64-linux-gnu/cmake" && \
    make -j$(nproc)

# Set the default command
CMD ["/bin/bash"]
