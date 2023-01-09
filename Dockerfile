FROM ubuntu:20.04 as builder

# Setup timezone
RUN echo 'Etc/UTC' > /etc/timezone \
    && ln -s /usr/share/zoneinfo/Etc/UTC /etc/localtime \
    && apt-get update && apt-get install -q -y tzdata \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    debhelper \
    fakeroot \
    git \
    cmake \
    pkg-config \
    libjsoncpp-dev \
    libcurl4-openssl-dev \
    libtinyxml2-dev \
    libjsoncpp1 \
    libcurl4 \
    libtinyxml2-6a \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
    apt-transport-https ca-certificates gnupg software-properties-common wget
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | apt-key add - \
    && apt-add-repository 'deb https://apt.kitware.com/ubuntu/ bionic main' \
    && apt-get update \
    && apt-get install -y \
       cmake \
       ruby-dev

RUN gem i fpm -f

WORKDIR /build

COPY . .

RUN cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_MAVSDK_SERVER=OFF -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX=install -DWERROR=OFF -Bbuild/release -H.
RUN cmake --build build/release --target install -- -j2
RUN tools/create_packages.sh ./install . amd64

WORKDIR /artifacts
RUN cp /build/*.deb .

#  ▲               runtime ──┐
#  └── build                 ▼

FROM busybox

COPY --from=builder /artifacts /artifacts
