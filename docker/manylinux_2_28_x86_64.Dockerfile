FROM quay.io/pypa/manylinux_2_28_x86_64:latest

ENV PYTHON3=/opt/python/cp312-cp312/bin/python3
ENV PATH="/opt/python/cp312-cp312/bin:${PATH}"

RUN dnf -y update && \
    dnf -y install \
        libicu-devel \
        libpsl-devel \
        libnghttp2-devel \
        gnutls-devel \
        nettle-devel \
        libunistring-devel \
        brotli-devel \
        bzip2-devel \
        gperf \
        make \
        autoconf \
        automake \
        libtool \
        wget \
        xz && \
    dnf clean all

WORKDIR /tmp
RUN wget https://curl.se/download/curl-8.6.0.tar.xz && \
    tar -xf curl-8.6.0.tar.xz && \
    cd curl-8.6.0 && \
    ./configure --with-gnutls --prefix=/usr && \
    make -j$(nproc) && \
    make install

RUN curl-config --ssl-backends

RUN $PYTHON3 -m pip install --upgrade pip meson ninja

WORKDIR /tmp
RUN git clone https://github.com/plutoprint/plutobook.git && \
    cd plutobook && \
    meson setup build --buildtype=release --prefix=/usr && \
    meson compile -C build && \
    meson install -C build --strip

RUN pkg-config --modversion plutobook
