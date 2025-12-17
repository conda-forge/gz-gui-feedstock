#!/bin/sh

if [[ "${target_platform}" == osx-* ]]; then
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

if [[ "${target_platform}" == linux-* ]]; then
  CMAKE_ARGS="${CMAKE_ARGS} -DOPENGL_egl_LIBRARY:FILEPATH=${PREFIX}/lib/libEGL.so.1"
  CMAKE_ARGS="${CMAKE_ARGS} -DEGL_opengl_LIBRARY:FILEPATH=${PREFIX}/lib/libGL.so.1"
  CMAKE_ARGS="${CMAKE_ARGS} -DOPENGL_opengl_LIBRARY:FILEPATH=${PREFIX}/lib/libGL.so.1"
fi

rm -rf build
mkdir build
cd build

cmake ${CMAKE_ARGS} -GNinja \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=True \
      -DBUILD_SHARED_LIBS=ON \
      -DBUILD_TESTING=OFF \
      -DGZ_ENABLE_RELOCATABLE_INSTALL:BOOL=ON ^\
      ..

cmake --build . --config Release
cmake --build . --config Release --target install
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
ctest --output-on-failure -C Release
fi
