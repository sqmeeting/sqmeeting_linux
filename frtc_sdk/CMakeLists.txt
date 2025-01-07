if (APPLE)
    message("=== === === [macOS] : set cmake_minimum_required(VERSION 3.5) on macOS === === ===")
    cmake_minimum_required(VERSION 3.5)
elseif (UNIX) #(UNIX)
    message("=== === === [UOS] : set cmake_minimum_required(VERSION 3.5) on UOS === === ===")
    cmake_minimum_required(VERSION 3.5)
elseif(WIN32)
    message("=== === === [Windows] : set cmake_minimum_required(VERSION 3.27.5) on Windows === === ===")
    cmake_minimum_required(VERSION 3.27.5)
endif()


if (APPLE)
    message("=== === === [macOS] : set Architectures on macOS === === ===")
    set(CMAKE_OSX_ARCHITECTURES arm64)
elseif (UNIX) #(UNIX)
    message("=== === === [UOS] : set Architectures on UOS === === ===")
elseif(WIN32)
    message("=== === === [Windows] : set Architectures on Windows x86_32 bit === === ===")
    #set(CMAKE_OSX_ARCHITECTURES x86_32)
endif()


if (APPLE)
    message("=== === === [macOS] : set C, C++ Compiler on macOS === === ===")
    set (CMAKE_C_COMPILER "/usr/bin/clang")
    set (CMAKE_CXX_COMPILER "/usr/bin/clang++")
elseif (UNIX) #(UNIX)
    message("=== === === [UOS] : set C, C++ Compiler on UOS === === ===")
elseif(WIN32)
    message("=== === === [Windows] : set C, C++ Compiler on Windows === === ===")
endif()

set(PROJECT_NAME "frtc_sdk")
project(${PROJECT_NAME} CXX)

message("=== === === CMAKE_PROJECT_NAME ${CMAKE_PROJECT_NAME} === === ===")
message("PROJECT_NAME ${PROJECT_NAME}")

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

if (APPLE)
    set(CMAKE_CXX_STANDARD 17)
elseif (UNIX) #(UNIX)
    set(CMAKE_CXX_STANDARD 17)
elseif (WIN32)
    set(CMAKE_CXX_STANDARD 17)
endif()



set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c99")

set(CMAKE_CXX_STANDARD_REQUIRED ON)


if(APPLE)
    message("this operation platform is APPLE")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wl, -std=c++17 -pthread -D_GNU_ -DLOG_ON")
elseif(UNIX) #UOS
    message("this operation platform is UOS/UNIX")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DUOS -Wl,-Bdynamic -std=c++17 -pthread -D_GNU_ -DLOG_ON -no-pie -fPIC")
    set(CMAKE_POSITION_INDEPENDENT_CODE ON)
elseif(WIN32)
    message("this operation platform is Windows")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Zc:__cplusplus /permissive- -D_WINDOWS_COMPILE_ ")
endif()

add_definitions(-fPIC)

#close build warning.
add_definitions(-w)

if(APPLE)
    message("this operation platform is APPLE")
elseif(UNIX) #UOS
    message("this operation platform is UOS/UNIX")
elseif(WIN32)
    message("this operation platform is Windows")
    #add_definitions(-D_HAS_STD_BYTE=0)
endif()

# 1.1. For include files of *.a.

if(!WIN32)
    set(SYSTEM_HEADER   "${CMAKE_SYSROOT}/usr/include/")
    include_directories(${SYSTEM_HEADER})

    set(SYSTEM_PTHREAD_HEADER   "${CMAKE_SYSROOT}/usr/include/pthread/")
    include_directories(${SYSTEM_PTHREAD_HEADER})

    set(SYSTEM_USR_LIB_DIST_DIR    "${CMAKE_SYSROOT}/usr/lib")
    link_directories(${SYSTEM_USR_LIB_DIST_DIR})

    # set(3RDPARTY_CPR_INC_DIR   "${CMAKE_CURRENT_SOURCE_DIR}/3rdparty/cpr/include")
    # include_directories(${3RDPARTY_CPR_INC_DIR})
endif()

set(3RDPARTY_JSONCPP_INC_DIR   "${CMAKE_CURRENT_SOURCE_DIR}/3rdparty/jsoncpp/include/json")
include_directories(${3RDPARTY_JSONCPP_INC_DIR})

if (APPLE)
    message("=== === === [macOS] : customize path(TARGET_PLATFORM_PATH) to macOS === === ===")
    set(3RDPARTY_JSONCPP_DIST_DIR    "${CMAKE_CURRENT_SOURCE_DIR}/3rdparty/jsoncpp/lib/mac")
    link_directories(${3RDPARTY_JSONCPP_DIST_DIR})

    # set(3RDPARTY_CPR_DIST_DIR    "${CMAKE_CURRENT_SOURCE_DIR}/3rdparty/cpr/lib/mac")
    # link_directories(${3RDPARTY_CPR_DIST_DIR})

elseif (UNIX) #(UNIX)
    message("=== === === [UOS] : customize path(TARGET_PLATFORM_PATH) to UOS /UNIX /Linux : SYSTEM_USR_PTHREAD_LIB_DIST_DIR=== === ===")
    set(SYSTEM_USR_PTHREAD_LIB_DIST_DIR    "${CMAKE_SYSROOT}/usr/lib/x86_64-linux-gnu")
    link_directories(${SYSTEM_USR_PTHREAD_LIB_DIST_DIR})

    set(3RDPARTY_JSONCPP_DIST_DIR    "${CMAKE_CURRENT_SOURCE_DIR}/3rdparty/jsoncpp/lib/uos")
    link_directories(${3RDPARTY_JSONCPP_DIST_DIR})
elseif(WIN32)
    set(3RDPARTY_JSONCPP_DIST_DIR    "${CMAKE_CURRENT_SOURCE_DIR}/3rdparty/jsoncpp/lib/windows")
    link_directories(${3RDPARTY_JSONCPP_DIST_DIR})
endif()


if(WIN32)
    include(FetchContent)
    FetchContent_Declare(cpr GIT_REPOSITORY https://github.com/libcpr/cpr.git
                            GIT_TAG 3b15fa82ea74739b574d705fea44959b58142eb8) # Replace with your desired git commit from: https://github.com/libcpr/cpr/releases
    FetchContent_MakeAvailable(cpr)
endif()




#========================================
# Source code and libs.
#========================================

#--------------------------------------------------
# [1] Add for frtc_sdk, include static lib.
#--------------------------------------------------

set(FRTC_SDK_DIST_INCLUDE_NEW_DIR    "${CMAKE_CURRENT_SOURCE_DIR}/.")
include_directories(${FRTC_SDK_DIST_INCLUDE_NEW_DIR})


# 0. For include files of librtcsdk.a.
set(FRTC_SDK_DIST_INCLUDE_DIR    "${CMAKE_CURRENT_SOURCE_DIR}/frtc_sdk/lib_rtc_common/inc/windows")
include_directories(${FRTC_SDK_DIST_INCLUDE_DIR})

# 1.2. For librtcsdk.a.
if (APPLE)
    message("=== === === [macOS] : ")
    set(FRTC_SDK_LIB_DIR    "${CMAKE_CURRENT_SOURCE_DIR}/dist/lib_mac")
    link_directories(${FRTC_SDK_LIB_DIR})
elseif (UNIX) # (UOS)
    message("=== === === [UOS] : ")
    set(RTC_COMMON_LIB_DIR    "${CMAKE_CURRENT_SOURCE_DIR}/frtc_sdk/lib_rtc_common/lib/uos")
    link_directories(${RTC_COMMON_LIB_DIR})
elseif(WIN32)
    message("=== === === [Windows] : ")
    set(RTC_COMMON_LIB_DIR    "${CMAKE_CURRENT_SOURCE_DIR}/frtc_sdk/lib_rtc_common/lib/windows")
    link_directories(${RTC_COMMON_LIB_DIR})
endif()


# 1.3. For other headers.
set(FRTC_INTERFACE_DIR    "${CMAKE_CURRENT_SOURCE_DIR}/frtc_sdk/frtc_sdk_interface")
include_directories(${FRTC_INTERFACE_DIR})

set(FRTC_SDK_RTCSDKINTERFACE_DIR    "${CMAKE_CURRENT_SOURCE_DIR}/frtc_sdk/rtc_common_interface")
include_directories(${FRTC_SDK_RTCSDKINTERFACE_DIR})

set(FRTC_SDK_UUID_DIR    "${CMAKE_CURRENT_SOURCE_DIR}/frtc_sdk/uuid")
include_directories(${FRTC_SDK_UUID_DIR})

set(FRTC_SDK_UTIL_DIR    "${CMAKE_CURRENT_SOURCE_DIR}/frtc_sdk/util")
include_directories(${FRTC_SDK_UTIL_DIR})

set(FRTC_REST_API_DIR    "${CMAKE_CURRENT_SOURCE_DIR}/frtc_sdk/frtc_sdk_rest_api")
include_directories(${FRTC_REST_API_DIR})

set(FRTC_SDK_SVCLAYOUT_DIR    "${CMAKE_CURRENT_SOURCE_DIR}/frtc_sdk/svc_layout")
include_directories(${FRTC_SDK_SVCLAYOUT_DIR})


# 1.4. Get all .cpp/.c/.cc files.
# 1.4.1.for frtc_sdk.RtcsdkInterface
aux_source_directory(${CMAKE_CURRENT_SOURCE_DIR}/frtc_sdk/frtc_sdk_interface/.             FRTC_INTERFACE_DIR_SRC)
aux_source_directory(${CMAKE_CURRENT_SOURCE_DIR}/frtc_sdk/rtc_common_interface/.           FRTC_SDK_INTERFACE_DIR_SRC)
aux_source_directory(${CMAKE_CURRENT_SOURCE_DIR}/frtc_sdk/uuid/.                           FRTC_SDK_UUID_DIR_SRC)
#aux_source_directory(${CMAKE_CURRENT_SOURCE_DIR}/frtc_sdk/util/.                           FRTC_Util_DIR_SRC)
#aux_source_directory(${CMAKE_CURRENT_SOURCE_DIR}/frtc_sdk/frtc_sdk_rest_api/.              FRTC_REST_API_DIR_SRC)

file(GLOB_RECURSE SDK_INTERFACE_HEADER_FILES    "${CMAKE_CURRENT_SOURCE_DIR}/frtc_sdk/frtc_sdk_interface/*.h")
file(GLOB_RECURSE COMMON_INTERFACE_HEADER_FILES "${CMAKE_CURRENT_SOURCE_DIR}/frtc_sdk/rtc_common_interface/*.h")
file(GLOB_RECURSE UUID_INTERFACE                "${CMAKE_CURRENT_SOURCE_DIR}/frtc_sdk/uuid/*.h")
file(GLOB_RECURSE UTIL_INTERFACE                "${CMAKE_CURRENT_SOURCE_DIR}/frtc_sdk/util/*.h")
#file(GLOB_RECURSE SDK_REST_API_HEADER_FILES    "${CMAKE_CURRENT_SOURCE_DIR}/frtc_sdk/frtc_sdk_rest_api/*.h")



file(GLOB_RECURSE RTC_COMMON_HEADERS    "${CMAKE_CURRENT_SOURCE_DIR}/frtc_sdk/lib_rtc_common/inc/windows/*.h")
file(GLOB_RECURSE 3RDPARTY_JSONCPP_HEADERS    "${CMAKE_CURRENT_SOURCE_DIR}/3rdparty/jsoncpp/include/json/*.h")
#file(GLOB_RECURSE 3RDPARTY_CPR_HEADERS    "${CMAKE_CURRENT_SOURCE_DIR}/3rdparty/cpr/include/cpr/*.h")

if(!WIN32)
    file(GLOB_RECURSE 3RDPARTY_CPR_HEADERS    "${CMAKE_CURRENT_SOURCE_DIR}/3rdparty/cpr/include/*.h")
endif()

aux_source_directory(${CMAKE_CURRENT_SOURCE_DIR}/frtc_sdk/svc_layout/.            FRTC_SDK_SVCLAYOUT_DIR_SRC)

file(GLOB_RECURSE SVC_LAYOUT_HEADERS    "${CMAKE_CURRENT_SOURCE_DIR}/frtc_sdk/svc_layout/*.h")

file(GLOB_RECURSE HEADER_FILES "${CMAKE_CURRENT_SOURCE_DIR}/dist/include/*.h")


if(APPLE)
    #TODO: Qt5 -> Qt6 -yingyong.Mao -2023-11-1
    message("this operation platform is APPLE")
    add_library(${PROJECT_NAME}
        # for frtc_sdk.
        STATIC
        ${FRTC_INTERFACE_DIR_SRC}
        ${FRTC_SDK_INTERFACE_DIR_SRC}
        ${FRTC_SDK_UUID_DIR_SRC}
        ${FRTC_REST_API_DIR_SRC}

        ${FRTC_SDK_AUDIO_SINK_DIR_SRC}
        ${FRTC_SDK_AUDIO_CAPTURE_DIR_SRC}
        ${FRTC_SDK_VIDEO_CAPTURE_DIR_SRC}
        ${FRTC_SDK_VIDEO_RENDER_DIR_SRC}

        ${FRTC_SDK_VIDEO_VIEW_DIR_SRC}
        ${FRTC_SDK_SVCLAYOUT_DIR_SRC}
        ${FRTC_NOTIFICATIONCENTER_DIR_SRC}

        # for frtc_sdk UI view.
        ${FRTC_SDK_FMEETINGVIEW_DIR_SRC}
        ${FRTC_SDK_UTIL_SCREEN_DIR_SRC}

        #${FRTC_SDK_USERDEFAULT_DIR_SRC}
        ${FRTC_CONTENT_DIR_SRC}
        #${FRTC_SDK_VIDEO_CAMERA_DIR_SRC}
        ${FRTC_SDK_AUDIO_DEVICE_DIR_SRC}
        #${FRTC_SDK_MONITOR_DEVICE_DIR_SRC}
        ${FRTC_Util_DIR_SRC}
        ${HEADER_FILES}
        ${SDK_INTERFACE_HEADER_FILES}
        ${COMMON_INTERFACE_HEADER_FILES}
        ${UUID_INTERFACE}
        #${SDK_REST_API_HEADER_FILES}
        ${NOTIFICATION_INTERFACE}
        ${CONTENT_INTERFACE}
        ${UTIL_INTERFACE}
        ${AUDIO_HEADERS}
        ${AUDIO_CAPTURE_HEADERS}
        ${AUDIO_DEVICE_HEADERS}
        ${VIDEO_CAPTURE_HEADERS}
        ${VIDEO_RENDER_HEADERS}

        ${SVC_LAYOUT_HEADERS}
        ${UTIL_SCREEN_HEADERS}
        ${USER_DEFAULT_HEADERS}
        ${MEETING_VIEW_HEADERS}
        ${RTC_COMMON_HEADERS}

        #${FRTC_SDK_QRC}
        ${3RDPARTY_JSONCPP_HEADERS}
       # ${3RDPARTY_CPR_HEADERS}
    )
elseif(UNIX) # (UOS)
    # 1.1. static lib.
    message("this operation platform is UOS")
    add_library(${PROJECT_NAME}
        SHARED

        # for frtc_sdk.
        ${FRTC_INTERFACE_DIR_SRC}
        ${FRTC_SDK_INTERFACE_DIR_SRC}
        ${FRTC_SDK_UUID_DIR_SRC}
        ${FRTC_REST_API_DIR_SRC}

        ${FRTC_SDK_VIDEO_VIEW_DIR_SRC}
        ${FRTC_SDK_SVCLAYOUT_DIR_SRC}
        ${FRTC_NOTIFICATIONCENTER_DIR_SRC}

        # for frtc_sdk UI view.
        ${FRTC_SDK_FMEETINGVIEW_DIR_SRC}
        ${FRTC_SDK_UTIL_SCREEN_DIR_SRC}

        #${FRTC_SDK_USERDEFAULT_DIR_SRC}
        ${FRTC_CONTENT_DIR_SRC}
        ${FRTC_SDK_VIDEO_CAMERA_DIR_SRC}
        ${FRTC_SDK_AUDIO_DEVICE_DIR_SRC}
        ${FRTC_SDK_MONITOR_DEVICE_DIR_SRC}

        ${HEADER_FILES}
        ${SDK_INTERFACE_HEADER_FILES}
        ${COMMON_INTERFACE_HEADER_FILES}

        ${UUID_INTERFACE}
        ${SDK_REST_API_HEADER_FILES}
        ${NOTIFICATION_INTERFACE}
        ${CONTENT_INTERFACE}
        ${UTIL_INTERFACE}

        ${AUDIO_HEADERS}
        ${AUDIO_CAPTURE_HEADERS}
        ${AUDIO_DEVICE_HEADERS}
        ${VIDEO_CAPTURE_HEADERS}
        ${VIDEO_RENDER_HEADERS}

        ${SVC_LAYOUT_HEADERS}
        ${UTIL_SCREEN_HEADERS}
        ${USER_DEFAULT_HEADERS}
        ${MEETING_VIEW_HEADERS}

        #./main.cpp
        )
elseif(WIN32)
    #TODO: Qt5 -> Qt6 -yingyong.Mao -2023-10-23
    message("this operation platform is windows")
    # 1.2. dynamic lib.
    # add_library(${PROJECT_NAME} SHARED ${LIB_SRC})
    add_library(${PROJECT_NAME}
        SHARED

        # for frtc_sdk.
        ${FRTC_INTERFACE_DIR_SRC}
        ${FRTC_SDK_INTERFACE_DIR_SRC}
        ${FRTC_SDK_UUID_DIR_SRC}
        ${FRTC_REST_API_DIR_SRC}

        ${FRTC_SDK_SVCLAYOUT_DIR_SRC}

        ${HEADER_FILES}
        ${SDK_INTERFACE_HEADER_FILES}
        ${RTC_COMMON_HEADERS}
        ${COMMON_INTERFACE_HEADER_FILES}
        ${UUID_INTERFACE}
        ${UTIL_INTERFACE}
        ${SDK_REST_API_HEADER_FILES}

        ${SVC_LAYOUT_HEADERS}

        ${3RDPARTY_JSONCPP_HEADERS}
        )
endif()

# 2. for main.c call lib.
#set(APP_SRC main.c)
#add_executable(${PROJECT_NAME} ${APP_SRC})

# 2.1. link static lib.
#target_link_libraries(${PROJECT_NAME} b64)

if(WIN32)
    target_link_libraries(${PROJECT_NAME} PRIVATE jsoncpp)
    target_link_libraries(${PROJECT_NAME} PRIVATE rtc_sdk)
    target_link_libraries(${PROJECT_NAME} PRIVATE cpr::cpr)
elseif (UNIX)
    target_link_libraries(${PROJECT_NAME} PRIVATE jsoncpp)
    target_link_libraries(${PROJECT_NAME} PRIVATE rtc_sdk)
endif()

#print message
message(${PROJECT_NAME})


#========================================
# copy lib to dist path.
#========================================

if (APPLE)
    message("=== === === [macOS] : customize path(RTCSDK_DIST_TARGET_PLATFORM_PATH) to macOS === === ===")
    set(RTCSDK_DIST_TARGET_PLATFORM_PATH   "${CMAKE_CURRENT_SOURCE_DIR}/dist/lib_mac/.")
elseif (UNIX) #UNIX
    message("=== === === [UOS] : customize path(RTCSDK_DIST_TARGET_PLATFORM_PATH) to UOS /UNIX /Linux === === ===")
    # for release.
    set(RTCSDK_DIST_TARGET_PLATFORM_PATH  "../dist/librtcsdk/uos/lib/.")
elseif(WIN32)
    message("=== === === [Windows] : customize path(RTCSDK_DIST_TARGET_PLATFORM_PATH) to Windows === === ===")
    # for release.
    set(RTCSDK_DIST_TARGET_PLATFORM_PATH  "${CMAKE_CURRENT_SOURCE_DIR}/frtc_sdk/lib_rtc_common/lib/windows")
    #set(RTCSDK_DIST_TARGET_PLATFORM_PATH  "${CMAKE_CURRENT_SOURCE_DIR}/frtc_sdk/lib_rtc_common/lib/windows")
endif()

add_custom_command(
    TARGET frtc_sdk
    POST_BUILD
    COMMENT "Copying lib librtcsdk.a binary output to dist path."
    # for release.
    COMMENT ${RTCSDK_DIST_TARGET_PLATFORM_PATH}
    #COMMAND ${CMAKE_COMMAND} -E copy ${RTCSDK_DIST_TARGET_PLATFORM_PATH}/rtc_sdk.dll $<TARGET_FILE_DIR:frtc_sdk>/rtc_sdk.dll
    #COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE_DIR:cpr>/cpr.dll $<TARGET_FILE_DIR:frtc_sdk>/cpr.dll
    #COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/build/_deps/curl-build/lib/Release/libcurl.dll $<TARGET_FILE_DIR:frtc_sdk>/libcurl.dll
)

#file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/dist/lib/libopenh264.so DESTINATION ${CMAKE_BINARY_DIR})
