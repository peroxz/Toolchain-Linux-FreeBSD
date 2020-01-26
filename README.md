# Toolchain-Linux-FreeBSD
Toolchain for cross-compiling from GNU Linux host x86_64 to FreeBSD x86_64 in a Docker container.
  ## Help
Build command to create Docker container:

    $ docker build -t peroxz:toolchain-linux-freebsd .
Run command to launch Docker container:

     $ docker run -ti --rm peroxz:toolchain-linux-freebsd /bin/bash
Compile C code:

    $ /opt/cross-freebsd/bin/x86_64-pc-freebsd10-gcc hello.c -o hello
Compile C code with static flag:

    $ /opt/cross-freebsd/bin/x86_64-pc-freebsd10-gcc hello.c -o hello -static
Compile C code with OpenSSL support:

    $ /opt/cross-freebsd/bin/x86_64-pc-freebsd10-gcc hello.c -o hello -lcrypto
  ## Software
 - FreeBSD base files from FreeBSD 12.1
 - Binutils 2.33.1
 - GMP 6.2.0
 - MPFR 4.0.2
 - MPC 1.1.0
 - GCC 9.1.0
