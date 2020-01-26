# Reference:
# https://linux-tips.com/t/how-to-build-a-freebsd-toolchain-for-linux/288/1
# https://gist.github.com/samm-git/7470fbfedcc61f67af31e2df042e3810

FROM ubuntu:latest
RUN dpkg --add-architecture i386 && apt-get update && apt upgrade -y

# Install dependencies
RUN apt-get install -y gcc g++ gcc-multilib libssl-dev:i386 bison make libssl-dev wget xz-utils vim file

# Create folders
RUN mkdir -p /build /opt/cross-freebsd /compile

# Compile binutils
RUN cd /build && \
    wget https://ftp.gnu.org/gnu/binutils/binutils-2.33.1.tar.xz && \
    tar xf binutils-2.33.1.tar.xz && \
    cd binutils-2.33.1 && \
    ./configure --enable-libssp --enable-gold --enable-ld \
        --target=x86_64-pc-freebsd10 --prefix=/opt/cross-freebsd && \
    make -j4 && \
    make install

# Get FreeBSD libs and headers
RUN cd /build && \
    mkdir base && \
    cd base && \
    wget http://ftp.plusline.de/FreeBSD/releases/amd64/12.1-RELEASE/base.txz && \
    tar -xf base.txz && \
    mv base.txz /build/. && \
    cp -r usr/include /opt/cross-freebsd/x86_64-pc-freebsd10 && \
    cp usr/lib/crt1.o /opt/cross-freebsd/x86_64-pc-freebsd10/lib && \
    cp usr/lib/crti.o /opt/cross-freebsd/x86_64-pc-freebsd10/lib && \
    cp usr/lib/crtn.o /opt/cross-freebsd/x86_64-pc-freebsd10/lib && \
    cp usr/lib/libc.a /opt/cross-freebsd/x86_64-pc-freebsd10/lib && \
    cp usr/lib/libm.a /opt/cross-freebsd/x86_64-pc-freebsd10/lib && \
    cp usr/lib/libpthread.so /opt/cross-freebsd/x86_64-pc-freebsd10/lib && \
    cp usr/lib/crtbeginT.o /opt/cross-freebsd/x86_64-pc-freebsd10/lib && \
    cp usr/lib/libcrypto.a /opt/cross-freebsd/x86_64-pc-freebsd10/lib && \
    cp usr/lib/libcrypto.so /opt/cross-freebsd/x86_64-pc-freebsd10/lib && \
    cp lib/libthr.so.3 /opt/cross-freebsd/x86_64-pc-freebsd10/lib && \
    cp lib/libc.so.7 /opt/cross-freebsd/x86_64-pc-freebsd10/lib && \
    cp lib/libm.so.5 /opt/cross-freebsd/x86_64-pc-freebsd10/lib && \
    cd /opt/cross-freebsd/x86_64-pc-freebsd10/lib && \
    ln -s libm.so.5 libm.so && \
    ln -s libc.so.7 libc.so

# Compile GMP
RUN cd /build && \
    wget https://ftp.gnu.org/gnu/gmp/gmp-6.2.0.tar.xz && \
    tar -xf gmp-6.2.0.tar.xz && \
    cd gmp-6.2.0 && \
    ./configure --prefix=/opt/cross-freebsd --enable-shared --enable-static \
      --enable-fft --enable-cxx --host=x86_64-pc-freebsd10 && \
    make -j4 && \
    make install

# Compile MPFR
RUN cd /build && \
    wget https://ftp.gnu.org/gnu/mpfr/mpfr-4.0.2.tar.xz && \
    tar -xf mpfr-4.0.2.tar.xz && \
    cd mpfr-4.0.2 && \
    ./configure --prefix=/opt/cross-freebsd --with-gnu-ld  --enable-static \
      --enable-shared --with-gmp=/opt/cross-freebsd --host=x86_64-pc-freebsd10 && \
    make -j4 && \
    make install

# Compile MPC
RUN cd /build && \
    wget https://ftp.gnu.org/gnu/mpc/mpc-1.1.0.tar.gz && \
    tar -xf mpc-1.1.0.tar.gz && \
    cd mpc-1.1.0 && \
    ./configure --prefix=/opt/cross-freebsd --with-gnu-ld --enable-static \
      --enable-shared --with-gmp=/opt/cross-freebsd \
      --with-mpfr=/opt/cross-freebsd --host=x86_64-pc-freebsd10 && \
    make -j4 && \
    make install

# Set LD_LIBRARY_PATH ENV
ENV LD_LIBRARY_PATH=/opt/cross-freebsd/lib

# 1. Configure GCC
# 2. Build and install
RUN cd /build && \
    wget https://ftp.gnu.org/gnu/gcc/gcc-9.1.0/gcc-9.1.0.tar.xz && \
    tar -xf gcc-9.1.0.tar.xz && \
    cd gcc-9.1.0 && \
    mkdir build && \
    cd build && \
    ../configure --without-headers --with-gnu-as --with-gnu-ld --disable-nls \
      --enable-languages=c,c++ --enable-libssp --enable-gold --enable-ld \
      --disable-libitm --disable-libquadmath --target=x86_64-pc-freebsd10 \
      --prefix=/opt/cross-freebsd --with-gmp=/opt/cross-freebsd \
      --with-mpc=/opt/cross-freebsd --with-mpfr=/opt/cross-freebsd --disable-libgomp && \
    make -j4 && \
    make install

# Clean
RUN rm -rf /build

CMD ["/bin/bash"]
