# Build and run the SanjayMart C++17/Drogon web application.
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install the compiler, CMake, and development libraries required by CMakeLists.txt.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        cmake \
        libdrogon-dev \
        libjsoncpp-dev \
        uuid-dev \
        zlib1g-dev \
        libsqlite3-dev \
        libmariadb-dev-compat \
        libcurl4-openssl-dev \
        libpq-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Keep the frontend beside the executable because main.cc serves it from ".".
COPY CMakeLists.txt main.cc sanjaymart.html ./

RUN cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
    && cmake --build build --parallel 2

# Render supplies PORT at runtime; main.cc reads it and binds to 0.0.0.0.
EXPOSE 10000
CMD ["/app/build/SanjayMart"]
