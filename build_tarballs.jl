# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "SFML"
version = v"2.5.1"

# Collection of sources required to build SFML
sources = [
    "https://www.sfml-dev.org/files/SFML-2.5.1-linux-gcc-64-bit.tar.gz" =>
    "34ad106e4592d2ec03245db5e8ad8fbf85c256d6ef9e337e8cf5c4345dc583dd",

    "https://github.com/SFML/SFML.git" =>
    "192eb968a4e938f36948e97f97ddc354a8a470fe",

    "https://github.com/SFML/CSFML.git" =>
    "61f17e3c1d109b65ef7e3e3ea1d06961da130afc",

]

# Bash recipe for building across all platforms
script = raw"""
# build SFML
cd ${WORKSPACE}/srcdir

if [[ "${target}" == *linux* ]]; then

cd SFML-2.5.1/
mv ./include $WORKSPACE/destdir/
mv ./lib $WORKSPACE/destdir/

else

cd SFML
mkdir build && cd build

CMAKE_FLAGS="-DCMAKE_INSTALL_PREFIX=${prefix} -DCMAKE_TOOLCHAIN_FILE=/opt/${target}/${target}.toolchain"

if [[ "${target}" == *apple* ]]; then
CMAKE_FLAGS="${CMAKE_FLAGS} -DSFML_DEPENDENCIES_INSTALL_PREFIX=${WORKSPACE}/destdir/Frameworks"
fi

if [[ "${target}" == *mingw* ]] && [[ ${nbits} == 64 ]]; then
CMAKE_FLAGS="${CMAKE_FLAGS} -DOPENAL_LIBRARY=${WORKSPACE}/srcdir/SFML/extlibs/bin/x64/openal32.dll"
fi

if [[ "${target}" == *mingw* ]] && [[ ${nbits} == 32 ]]; then
CMAKE_FLAGS="${CMAKE_FLAGS} -DOPENAL_LIBRARY=${WORKSPACE}/srcdir/SFML/extlibs/bin/x86/openal32.dll"
fi

cmake .. ${CMAKE_FLAGS}
make
make install

fi

# build CSFML
cd ${WORKSPACE}/srcdir
cd CSFML
mkdir build && cd build

CMAKE_FLAGS="-DCMAKE_INSTALL_PREFIX=${prefix} -DCMAKE_TOOLCHAIN_FILE=/opt/${target}/${target}.toolchain"
CMAKE_FLAGS="${CMAKE_FLAGS} -DSFML_DIR=${WORKSPACE}/destdir/lib/cmake/SFML"

if [[ "${target}" == *mingw* ]]; then
CMAKE_FLAGS="${CMAKE_FLAGS} -DCSFML_LINK_SFML_STATICALLY=false"
fi

cmake .. ${CMAKE_FLAGS}
make
make install

"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Linux(:x86_64; libc=:glibc, compiler_abi=CompilerABI(:gcc7)),
    MacOS(:x86_64),
    Windows(:x86_64; compiler_abi=CompilerABI(:gcc7)),
    Windows(:i686; compiler_abi=CompilerABI(:gcc7)),
]


# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, ["libcsfml-graphics", "csfml-graphics-2"], :libcsfml_graphics),
    LibraryProduct(prefix, ["libsfml-window", "sfml-window-2"], :libsfml_window),
    LibraryProduct(prefix, ["libsfml-audio", "sfml-audio-2"], :libsfml_audio),
    LibraryProduct(prefix, ["libsfml-network", "sfml-network-2"], :libsfml_network),
    LibraryProduct(prefix, ["libsfml-system", "sfml-system-2"], :libsfml_system),
    LibraryProduct(prefix, ["libsfml-graphics", "sfml-graphics-2"], :libsfml_graphics),
    LibraryProduct(prefix, ["libcsfml-system", "csfml-system-2"], :libcsfml_system),
    LibraryProduct(prefix, ["libcsfml-network", "csfml-network-2"], :libcsfml_network),
    LibraryProduct(prefix, ["libcsfml-window", "csfml-window-2"], :libcsfml_window),
    LibraryProduct(prefix, ["libcsfml-audio", "csfml-audio-2"], :libcsfml_audio)
]

# Dependencies that must be installed before this package can be built
dependencies = [

]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)
