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

WORKDIR /build/MAVSDK
COPY . .
RUN ./tools/generate_debian_changelog.sh > debian/changelog
RUN dpkg-buildpackage -us -uc -b

WORKDIR /artifacts
RUN cp /build/*.deb .

#  ▲               runtime ──┐
#  └── build                 ▼

FROM busybox

COPY --from=builder /artifacts /artifacts
