# the minimum version of CMake.
cmake_minimum_required(VERSION 3.5.0)
project(videocompress)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

set(CMAKE_POSITION_INDEPENDENT_CODE ON)
set(CMAKE_OBJECT_PATH_MAX 271)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-int-conversion -Wl,-Bsymbolic")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-int-conversion -Wl,-Bsymbolic")

if(DEFINED PACKAGE_FIND_FILE)
    include(${PACKAGE_FIND_FILE})
endif()

include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/include)

add_library(videocompress SHARED napi_init.cpp)

set(THIRD_PARTY_DIR "${CMAKE_CURRENT_SOURCE_DIR}/thirdparty")

target_include_directories(videocompress PUBLIC
    ${THIRD_PARTY_DIR}/FFmpeg/${OHOS_ARCH}/include
    ${THIRD_PARTY_DIR}/ffmpeg-kit/${OHOS_ARCH}/include
    ${THIRD_PARTY_DIR}/rapidjson/${OHOS_ARCH}/include
)

target_link_libraries(videocompress PUBLIC ${THIRD_PARTY_DIR}/FFmpeg/${OHOS_ARCH}/lib/libavcodec.so.60)
target_link_libraries(videocompress PUBLIC ${THIRD_PARTY_DIR}/FFmpeg/${OHOS_ARCH}/lib/libavdevice.so.60)
target_link_libraries(videocompress PUBLIC ${THIRD_PARTY_DIR}/FFmpeg/${OHOS_ARCH}/lib/libavfilter.so.9)
target_link_libraries(videocompress PUBLIC ${THIRD_PARTY_DIR}/FFmpeg/${OHOS_ARCH}/lib/libavformat.so.60)
target_link_libraries(videocompress PUBLIC ${THIRD_PARTY_DIR}/FFmpeg/${OHOS_ARCH}/lib/libavutil.so.58)
target_link_libraries(videocompress PUBLIC ${THIRD_PARTY_DIR}/FFmpeg/${OHOS_ARCH}/lib/libswresample.so.4)
target_link_libraries(videocompress PUBLIC ${THIRD_PARTY_DIR}/FFmpeg/${OHOS_ARCH}/lib/libswscale.so.7)

target_link_libraries(videocompress PUBLIC ${THIRD_PARTY_DIR}/ffmpeg-kit/${OHOS_ARCH}/lib/libffmpegkit.a)
target_link_libraries(videocompress PUBLIC ${THIRD_PARTY_DIR}/x264/${OHOS_ARCH}/lib/libx264.so.164)


target_link_libraries(videocompress PUBLIC libace_napi.z.so)
target_link_libraries(videocompress PUBLIC libhilog_ndk.z.so)