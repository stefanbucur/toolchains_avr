#!/usr/bin/env bash
set -euo pipefail

# Top-level configuration variables.
export BINUTILS_VERSION="2.46.0"
export GCC_VERSION="15.2.0"
export AVR_LIBC_VERSION="2.3.1"

# Where the actual files are built and installed.
export AVR_WORKDIR="/tmp/avr-workdir"
export INSTALL_DIR="${AVR_WORKDIR}/install"
export BUILD_DIR="${AVR_WORKDIR}/build"

# This will not be used anywhere.
export PREFIX="/usr/local/avr"
export PATH="${INSTALL_DIR}${PREFIX}/bin:$PATH"

mkdir -p "${INSTALL_DIR}" "${BUILD_DIR}" "${AVR_WORKDIR}/src"

# Download and extract the source code for binutils, gcc, and avr-libc.
################################################################################

cd "${AVR_WORKDIR}/src"

if [[ ! -f "binutils-${BINUTILS_VERSION}.tar.bz2" ]]; then
    wget -c https://sourceware.org/pub/binutils/releases/binutils-${BINUTILS_VERSION}.tar.bz2
else
    echo "==> binutils tarball present, skipping download"
fi

if [[ ! -f "gcc-${GCC_VERSION}.tar.xz" ]]; then
    wget -c https://ftpmirror.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.xz
else
    echo "==> gcc tarball present, skipping download"
fi

if [[ ! -f "avr-libc-${AVR_LIBC_VERSION}.tar.bz2" ]]; then
    wget -c https://github.com/avrdudes/avr-libc/releases/download/avr-libc-2_3_1-release/avr-libc-${AVR_LIBC_VERSION}.tar.bz2
else
    echo "==> avr-libc tarball present, skipping download"
fi

if [[ ! -d "binutils-${BINUTILS_VERSION}" ]]; then
    tar -xjf binutils-${BINUTILS_VERSION}.tar.bz2
else
    echo "==> binutils source already extracted, skipping"
fi

if [[ ! -d "gcc-${GCC_VERSION}" ]]; then
    tar -xf gcc-${GCC_VERSION}.tar.xz
else
    echo "==> gcc source already extracted, skipping"
fi

if [[ ! -d "avr-libc-${AVR_LIBC_VERSION}" ]]; then
    tar -xjf avr-libc-${AVR_LIBC_VERSION}.tar.bz2
else
    echo "==> avr-libc source already extracted, skipping"
fi

cd "${AVR_WORKDIR}/src/gcc-${GCC_VERSION}"
./contrib/download_prerequisites

# Build and install binutils.
################################################################################

mkdir -p "${BUILD_DIR}/binutils"
cd "${BUILD_DIR}/binutils"
if [[ -f "${INSTALL_DIR}${PREFIX}/bin/avr-as" ]]; then
    echo "==> binutils already installed in ${INSTALL_DIR}${PREFIX}, skipping"
else
    ../../src/binutils-${BINUTILS_VERSION}/configure \
        --prefix=$PREFIX \
        --target=avr \
        --disable-nls \
        --disable-sim \
        --disable-gdb \
        --disable-werror \
        --disable-shared \
        --enable-static
    echo "==> binutils configuration complete, now compiling"
    make -j$(nproc)
    make DESTDIR=${INSTALL_DIR} install
fi

# Build and install gcc.
################################################################################

mkdir -p "${BUILD_DIR}/gcc"
cd "${BUILD_DIR}/gcc"
if [[ -f "${INSTALL_DIR}${PREFIX}/bin/avr-gcc" ]]; then
    echo "==> gcc already installed in ${INSTALL_DIR}${PREFIX}, skipping"
else
    # ensure binutils from DESTDIR are visible for configure/make
    export PATH="${INSTALL_DIR}${PREFIX}/bin:$PATH"

    ../../src/gcc-${GCC_VERSION}/configure \
        --prefix=$PREFIX \
        --target=avr \
        --enable-languages=c,c++ \
        --disable-nls \
        --disable-libssp \
        --disable-libcc1 \
        --with-gnu-as \
        --with-gnu-ld \
        --with-dwarf2 \
        --disable-shared \
        --enable-static \
        --with-system-zlib  # Needed on MacOS.
    echo "==> gcc configuration complete, now compiling"
    make -j$(nproc)
    make DESTDIR=${INSTALL_DIR} install-strip
fi

# Build and install avr-libc.
################################################################################

mkdir -p "${BUILD_DIR}/avr-libc"
cd "${BUILD_DIR}/avr-libc"
if [[ -f "${INSTALL_DIR}${PREFIX}/avr/include/avr/io.h" || -f "${INSTALL_DIR}${PREFIX}/include/avr/io.h" ]]; then
    echo "==> avr-libc already installed in ${INSTALL_DIR}${PREFIX}, skipping"
else
    mkdir -p "${BUILD_DIR}/avr-libc"
    cd "${BUILD_DIR}/avr-libc"
    ../../src/avr-libc-${AVR_LIBC_VERSION}/configure \
        --prefix=$PREFIX \
        --build=$(../../src/avr-libc-${AVR_LIBC_VERSION}/config.guess) \
        --host=avr
    echo "==> avr-libc configuration complete, now compiling"
    make -j$(nproc)
    make DESTDIR=${INSTALL_DIR} install
fi

# Create a redistributable archive and clean up the working directory.
# Archive contains the contents of the install DESTDIR so it can be extracted
# preserving the ${PREFIX} path (e.g. usr/local/avr/...).
ARCHIVE_NAME="avr-gcc${GCC_VERSION}-libc${AVR_LIBC_VERSION}-binutils${BINUTILS_VERSION}.tar.xz"
echo "==> Creating redistributable archive ${AVR_WORKDIR}/${ARCHIVE_NAME}"
tar -C "${INSTALL_DIR}" -cJf "${AVR_WORKDIR}/${ARCHIVE_NAME}" .
echo "==> Archive created: ${AVR_WORKDIR}/${ARCHIVE_NAME}"

echo "==> Cleaning up working directory ${AVR_WORKDIR} (removing build, src, install)"
rm -rf "${BUILD_DIR}" "${AVR_WORKDIR}/src" "${INSTALL_DIR}"
echo "==> Cleanup complete"
