
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
endif()


if (APPLE)
    message("=== === === [macOS] : set C, C++ Compiler libs on macOS === === ===")
    set (CMAKE_C_COMPILER "/usr/bin/clang")
    set (CMAKE_CXX_COMPILER "/usr/bin/clang++")
elseif (UNIX) #(UNIX)
    message("=== === === [UOS] : set C, C++ Compiler on UOS === === ===")
elseif(WIN32)
    message("=== === === [Windows] : set C, C++ Compiler on Windows === === ===")
endif()

project(SQMeeting LANGUAGES CXX C)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

if (APPLE)
    message("=== === === [macOS] : set CMAKE_CXX_STANDARD to 17 on macOS === === ===")
    set(CMAKE_CXX_STANDARD 17)
elseif (UNIX) #(UNIX)
    message("=== === === [UOS] : set CMAKE_CXX_STANDARD to 17 on UOS === === ===")
    set(CMAKE_CXX_STANDARD 17)
elseif(WIN32)
    message("=== === === [Windows] : set CMAKE_CXX_STANDARD to 17 on Windows === === ===")
    set(CMAKE_CXX_STANDARD 17)
endif()

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c99")

set(CMAKE_CXX_STANDARD_REQUIRED ON)


if(WIN32)
    message("this operation platform is windows")
    #set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wl,-Bdynamic -std=c++14 -D_WINDOWS_COMPILE_ ")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Zc:__cplusplus /permissive- -D_WINDOWS_COMPILE_ ")
elseif(APPLE)
    message("this operation platform is APPLE")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wl, -std=c++17 -pthread -D_GNU_ -DLOG_ON")
elseif(UNIX)
    message("set CMAKE_CXX_FLAGS, this operation platform is UOS/UNIX")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DUOS -Wl,-Bdynamic -std=c++17 -pthread -D_GNU_ -DLOG_ON -no-pie -fPIC")
    set(CMAKE_POSITION_INDEPENDENT_CODE ON)
endif()

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

if (APPLE)
    message("=== === === [macOS] : set CMAKE_PREFIX_PATH on macOS === === ===")
    set(CMAKE_PREFIX_PATH "/usr/local/Qt-6.6.1")
elseif (UNIX)
    message("=== === === [UOS] : set CMAKE_PREFIX_PATH on UOS === === ===")
    #set(CMAKE_PREFIX_PATH "/opt/qt6")
    set(CMAKE_PREFIX_PATH "/usr/local/Qt-6.6.1")
    set(QML_IMPORT_PATH "${CMAKE_PREFIX_PATH}/qml" FORCE)
    #set(Qt6QML_DIR "${CMAKE_PREFIX_PATH}/qml" FORCE)
    message("+++++++++++++++++++ [UOS] : QML dir is ${Qt6QML_DIR} === === ===")
elseif (WIN32)
    message("=== === === [Windows] : set CMAKE_PREFIX_PATH on Windows === === ===")
    set(QML_IMPORT_PATH "${CMAKE_PREFIX_PATH}/qml" FORCE)
endif()

message(" ======================= ${CMAKE_PREFIX_PATH} ========================")

set(Qt6_DIR "${CMAKE_PREFIX_PATH}/lib/cmake/Qt6")
set(Qt6Widgets "${CMAKE_PREFIX_PATH}/lib/cmake/Qt6Widgets")
set(Qt6Network_DIR "${CMAKE_PREFIX_PATH}/lib/cmake/Qt6Network")
set(Qt6LinguistTools_DIR "${CMAKE_PREFIX_PATH}/lib/cmake/Qt6LinguistTools")
set(Qt6Multimedia_DIR "${CMAKE_PREFIX_PATH}/lib/cmake/Qt6Multimedia")

message("+++--- Qt6QML_DIR is ${Qt6QML_DIR}, Qt tool chain file is ${CMAKE_TOOLCHAIN_FILE} +++---")


find_package(Qt6 COMPONENTS Core Quick Qml LinguistTools Multimedia MultimediaWidgets QuickControls2 REQUIRED)

#for camera
find_package(QT NAMES Qt6 COMPONENTS Widgets Multimedia MultimediaWidgets REQUIRED)
find_package(Qt${QT_VERSION_MAJOR} COMPONENTS Widgets Multimedia MultimediaWidgets REQUIRED)


qt_standard_project_setup()


include_directories(${Qt6MultimediaWidgets_INCLUDE_DIRS})
include_directories(${Qt6Quick_INCLUDE_DIRS}) #for QQuickImageProvider
include_directories(${Qt6Multimedia_INCLUDE_DIRS}) #for QAudioDeviceInfo

message(STATUS " qtinclude ${QT_INCLUDE_DIR} ${Qt6MultimediaWidgets_INCLUDE_DIRS}" )

set(TS_FILES FrtcMeeting_zh_CN.ts)

#App icon.

#for gmake.
#ICON = FrtcMeeting.icns

set(APP_ICONS ${CMAKE_CURRENT_SOURCE_DIR}/FrtcMeeting.icns)
set_source_files_properties(${APP_ICONS} PROPERTIES MACOSX_PACKAGE_LOCATION "Resources")

#Reource files include images file path.
file(GLOB resources_skin_root "${CMAKE_CURRENT_SOURCE_DIR}/Images/MainView/*")
#file(GLOB SourceFiles Source/*.cpp Source/qml.rc)

set_source_files_properties(${resources_skin_root} PROPERTIES MACOSX_PACKAGE_LOCATION "Resources/images/MainView")

set_source_files_properties(FrtcTool.qml, AlertManager.qml, FrtcCallInterface.qml
    PROPERTIES
        QT_QML_SINGLETON_TYPE true
)

#--------------------------------------------------
# [5] Add for usr/lib .a, include static lib.
#--------------------------------------------------

# 1.1. For include files of *.a.
set(SYSTEM_HEADER   "${CMAKE_SYSROOT}/usr/include/")
include_directories(${SYSTEM_HEADER})

set(SYSTEM_PTHREAD_HEADER   "${CMAKE_SYSROOT}/usr/include/pthread/")
include_directories(${SYSTEM_PTHREAD_HEADER})

set(SYSTEM_USR_LOCAL_HEADER   "${CMAKE_SYSROOT}/usr/local/include")
include_directories(${SYSTEM_USR_LOCAL_HEADER})

# 1.2. For *.a.
set(SYSTEM_USR_LIB_DIST_DIR    "${CMAKE_SYSROOT}/usr/lib")
link_directories(${SYSTEM_USR_LIB_DIST_DIR})


if (APPLE)
    message("=== === === [macOS] : customize path(TARGET_PLATFORM_PATH) to macOS === === ===")

elseif (UNIX) #(UNIX)
    message("=== === === [UOS] : customize path(TARGET_PLATFORM_PATH) to UOS /UNIX /Linux : SYSTEM_USR_PTHREAD_LIB_DIST_DIR=== === ===")
    set(SYSTEM_USR_PTHREAD_LIB_DIST_DIR    "${CMAKE_SYSROOT}/usr/lib/x86_64-linux-gnu")
    link_directories(${SYSTEM_USR_PTHREAD_LIB_DIST_DIR})

    add_library(libasound SHARED IMPORTED)
    set_target_properties(libasound PROPERTIES IMPORTED_LOCATION ${SYSTEM_USR_PTHREAD_LIB_DIST_DIR}/libasound.so)

    add_library(libpulse SHARED IMPORTED)
    set_target_properties(libpulse PROPERTIES IMPORTED_LOCATION ${SYSTEM_USR_PTHREAD_LIB_DIST_DIR}/libpulse.so)

    set(SYSTEM_USR_LOCAL_LIB_DIST_DIR    "${CMAKE_SYSROOT}/usr/local/lib")
    link_directories(${SYSTEM_USR_LOCAL_LIB_DIST_DIR})

    add_library(libportaudio SHARED IMPORTED)
    set_target_properties(libportaudio PROPERTIES IMPORTED_LOCATION ${SYSTEM_USR_LOCAL_LIB_DIST_DIR}/libportaudio.so)
endif()

if(APPLE)
    find_path(LOG4CPLUS_INCLUDE_DIR log4cplus/logger.h
        HINTS /opt/homebrew/Cellar/log4cplus/2.1.1/include)

    find_library(LOG4CPLUS_LIBRARY log4cplus
        HINTS /opt/homebrew/Cellar/log4cplus/2.1.1/lib)
elseif (UNIX)
link_libraries(log4cplus)
endif()

include_directories(${LOG4CPLUS_INCLUDE_DIR})

#--------------------------------------------------
# [1] Add for frtc_sdk, include static lib.
#--------------------------------------------------


# 1.1. For include files of librtc_sdk.a (for common code) and librtcsdk.a (for frtc_sdk).

set(FRTC_SDK_DIST_SDK_INCLUDE_DIR    "${CMAKE_CURRENT_SOURCE_DIR}/../../FrtcMeeting/frtc_sdk_dist/dist/include/sdk/include")
include_directories(${FRTC_SDK_DIST_SDK_INCLUDE_DIR})

set(FRTC_SDK_INCLUDE_DIR    "${CMAKE_CURRENT_SOURCE_DIR}/../frtc_sdk/frtc_sdk/frtc_sdk_interface")
include_directories(${FRTC_SDK_INCLUDE_DIR})

# 1.2. For librtc_sdk.a (for common code) and librtcsdk.a (for frtc_sdk).
if (APPLE)
    message("=== === === [macOS] : ")
    #set(FRTC_SDK_LIB_DIR    "${CMAKE_CURRENT_SOURCE_DIR}/../../FrtcMeeting/frtc_sdk_dist/dist/lib_mac")
    set(FRTC_SDK_LIB_DIR    "${CMAKE_CURRENT_SOURCE_DIR}/dist")
    link_directories(${FRTC_SDK_LIB_DIR})
elseif (UNIX) # (UOS)
    message("=== === === [UOS] : ")
    set(FRTC_SDK_LIB_DIR    "${CMAKE_CURRENT_SOURCE_DIR}/dist/uos/lib")
    link_directories(${FRTC_SDK_LIB_DIR})
elseif (WIN32) #MSVC
    message("=== === === [UOS] : ")
    set(FRTC_SDK_LIB_DIR    "${CMAKE_CURRENT_SOURCE_DIR}/dist/windows/lib")
    link_directories(${FRTC_SDK_LIB_DIR})
endif()



# 1.3. For other headers.
# for frtc_sdk : FrtcCall.h and FrtcManagement.h.
if(WIN32)
    set(FRTC_INTERFACE_DIR    "${CMAKE_CURRENT_SOURCE_DIR}/dist/windows/inc")
    include_directories(${FRTC_INTERFACE_DIR})
elseif(UNIX)
    set(FRTC_INTERFACE_DIR    "${CMAKE_CURRENT_SOURCE_DIR}/dist/uos/inc")
    include_directories(${FRTC_INTERFACE_DIR})
else()
    set(FRTC_INTERFACE_DIR    "${CMAKE_CURRENT_SOURCE_DIR}/../../FrtcMeeting/frtc_sdk_dist/frtc_sdk/FrtcInterface")
    include_directories(${FRTC_INTERFACE_DIR})
endif()

set(FRTC_INTERFACE_USERDEFAULT_DIR    "${CMAKE_CURRENT_SOURCE_DIR}/../../FrtcMeeting/frtc_sdk_dist/frtc_sdk/UserDefault")
include_directories(${FRTC_INTERFACE_USERDEFAULT_DIR})



#--------------------------------------------------
# [2] Add for FrtcMeeting.
#--------------------------------------------------

# 2.1.Add header file include directories.
include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/SQMeetingComponent/FrtcMeetingInterface/FMakeCallClient
    ${CMAKE_CURRENT_SOURCE_DIR}/SQMeetingComponent/FrtcMeetingInterface/MessageHandlerFactory
    ${CMAKE_CURRENT_SOURCE_DIR}/SQMeetingComponent/FrtcMeetingInterface/MessageHandlerStrategy
    ${CMAKE_CURRENT_SOURCE_DIR}/SQMeetingComponent/Utils
    ${CMAKE_CURRENT_SOURCE_DIR}/SQMeetingComponent/UIComponent/OutOffCallView/FrtcAccountViewController/Src
    ${CMAKE_CURRENT_SOURCE_DIR}/SQMeetingComponent/UIComponent/OutOffCallView/FrtcMainViewController/Src
    ${CMAKE_CURRENT_SOURCE_DIR}/SQMeetingComponent/UIComponent/OutOffCallView/FrtcSettingViewController/Src

    ${CMAKE_CURRENT_SOURCE_DIR}/SQMeetingComponent/UIComponent/InCallView/FrtcMeetingView/Src
    ${CMAKE_CURRENT_SOURCE_DIR}/SQMeetingComponent/UIComponent/InCallView/FrtcTitleBarView/Src
    ${CMAKE_CURRENT_SOURCE_DIR}/SQMeetingComponent/UIComponent/InCallView/FrtcCallBarView/Src          #[In call]: TabBar buttons.
    ${CMAKE_CURRENT_SOURCE_DIR}/SQMeetingComponent/UIComponent/InCallView/FrtcMeetingInfoView/Src
    ${CMAKE_CURRENT_SOURCE_DIR}/SQMeetingComponent/UIComponent/InCallView/FrtcNetWorkInfoView/Src
    ${CMAKE_CURRENT_SOURCE_DIR}/SQMeetingComponent/UIComponent/InCallView/FrtcParticipantsView/Src
    ${CMAKE_CURRENT_SOURCE_DIR}/SQMeetingComponent/UIComponent/InCallView/FrtcShareContent/FrtcShareContentSelectWindow/Src
    ${CMAKE_CURRENT_SOURCE_DIR}/SQMeetingComponent/UIComponent/InCallView/FrtcShareContent/FrtcSharingFrameWindow/Src
    ${CMAKE_CURRENT_SOURCE_DIR}/SQMeetingComponent/UIComponent/InCallView/FrtcShareContent/FrtcSharingBarView/Src
    ${CMAKE_CURRENT_SOURCE_DIR}/SQMeetingComponent/UIComponent/InCallView/FrtcCallWindowController/FrtcInCallModel
    ${CMAKE_CURRENT_SOURCE_DIR}/SQMeetingComponent/UIComponent/InCallView/FrtcInfoInstance

    ${CMAKE_CURRENT_SOURCE_DIR}/SQMeetingComponent/FMeetingView/Src
    ${CMAKE_CURRENT_SOURCE_DIR}/SQMeetingComponent/NotificationCenter
    ${CMAKE_CURRENT_SOURCE_DIR}/SQMeetingComponent/Content
    ${CMAKE_CURRENT_SOURCE_DIR}/SQMeetingComponent/UserDefault
    ${CMAKE_CURRENT_SOURCE_DIR}/SQMeetingComponent/UUID
    ${CMAKE_CURRENT_SOURCE_DIR}/SQMeetingComponent/UtilScreen
    ${CMAKE_CURRENT_SOURCE_DIR}/SQMeetingComponent/SvcLayout
    ${CMAKE_CURRENT_SOURCE_DIR}/SQMeetingComponent/DeviceContext
    ${CMAKE_CURRENT_SOURCE_DIR}/SQMeetingComponent/Network

    ${CMAKE_CURRENT_SOURCE_DIR}/SQMeetingComponent/Audio/AudioCapture
    ${CMAKE_CURRENT_SOURCE_DIR}/SQMeetingComponent/Audio/AudioSink

    )

if (APPLE)
    include_directories(
        ${CMAKE_CURRENT_SOURCE_DIR}/SQMeetingComponent/Audio/AudioSink/AudioSink_macOS
        ${CMAKE_CURRENT_SOURCE_DIR}/SQMeetingComponent/Audio/AudioCapture/AudioCapture_macOS
        ${CMAKE_CURRENT_SOURCE_DIR}/SQMeetingComponent/Video/VideoCapture
        ${CMAKE_CURRENT_SOURCE_DIR}/SQMeetingComponent/Video/VideoRender
        ${CMAKE_CURRENT_SOURCE_DIR}/SQMeetingComponent/Audio/AudioDevice/AudioDevice_macOS
        #./../frtc_sdk_dist/frtc_sdk/DeviceMonitor/DeviceMonitor_macOS
    )
elseif (UNIX) # (UOS)
    include_directories(
        ${CMAKE_CURRENT_SOURCE_DIR}/SQMeetingComponent/Audio/AudioSink/AudioSink_UOS
        ${CMAKE_CURRENT_SOURCE_DIR}/SQMeetingComponent/Audio/AudioCapture/AudioCapture_UOS
        ${CMAKE_CURRENT_SOURCE_DIR}/SQMeetingComponent/Video/VideoCapture
        ${CMAKE_CURRENT_SOURCE_DIR}/SQMeetingComponent/Video/VideoRender
        ${CMAKE_CURRENT_SOURCE_DIR}/SQMeetingComponent/Audio/AudioDevice/AudioDevice_UOS
    )
elseif(WIN32)
    include_directories(
        ${CMAKE_CURRENT_SOURCE_DIR}/SQMeetingComponent/Audio/AudioSink/AudioSink_macOS
        ${CMAKE_CURRENT_SOURCE_DIR}/SQMeetingComponent/Audio/AudioCapture/AudioCapture_macOS
        ${CMAKE_CURRENT_SOURCE_DIR}/SQMeetingComponent/Video/VideoCapture
        ${CMAKE_CURRENT_SOURCE_DIR}/SQMeetingComponent/Video/VideoRender
        ${CMAKE_CURRENT_SOURCE_DIR}/SQMeetingComponent/Audio/AudioDevice/AudioDevice_macOS
        #./../frtc_sdk_dist/frtc_sdk/DeviceMonitor/DeviceMonitor_macOS
)
endif()


# 2.2.Add cpp directories.
aux_source_directory(SQMeetingComponent/FrtcMeetingInterface/FMakeCallClient/.   FRTC_MEETING_INTERFACE_DIR_SRC)
aux_source_directory(SQMeetingComponent/FrtcMeetingInterface/MessageHandlerStrategy/.   FRTC_MEETING_STRATEGY_DIR_SRC)
aux_source_directory(SQMeetingComponent/FrtcMeetingInterface/MessageHandlerFactory/.   FRTC_MEETING_STRATEGY_FACTORY_DIR_SRC)
aux_source_directory(SQMeetingComponent/Utils/.                                  FRTCMEETING_UTILS_DIR_SRC)

#set(MAIN_CALLVIEW FrtcMeeting/UIComponent/OutOffCallView/FrtcMainViewController/Src/FrtcCallView.cpp)
aux_source_directory(SQMeetingComponent/UIComponent/OutOffCallView/FrtcMainViewController/Src/.   MAIN_CALLVIEW_DIR_SRC)
aux_source_directory(SQMeetingComponent/UIComponent/OutOffCallView/FrtcSettingViewController/Src/.   MAIN_SETTING_DIR_SRC)

aux_source_directory(SQMeetingComponent/UIComponent/InCallView/FrtcMeetingView/Src/.         FRTCMEETING_UICOMPONET_INCALLVIEW_FRTCMETINGVIEW_DIR_SRC)
aux_source_directory(SQMeetingComponent/UIComponent/InCallView/FrtcCallBarView/Src/.         FRTCMEETING_UICOMPONET_INCALLVIEW_FRTCCALLBARVIEW_DIR_SRC)
aux_source_directory(SQMeetingComponent/UIComponent/InCallView/FrtcTitleBarView/Src/.        FRTCMEETING_UICOMPONET_INCALLVIEW_TITLEVIEW_DIR_SRC)
aux_source_directory(SQMeetingComponent/UIComponent/InCallView/FrtcMeetingInfoView/Src/.     FRTCMEETING_UICOMPONET_INCALLVIEW_FRTCMEETINGINFOVIEW_DIR_SRC)
aux_source_directory(SQMeetingComponent/UIComponent/InCallView/FrtcNetWorkInfoView/Src/.     FRTCMEETING_UICOMPONET_INCALLVIEW_FRTCNETWORKINFOVIEW_DIR_SRC)
aux_source_directory(SQMeetingComponent/UIComponent/InCallView/FrtcParticipantsView/Src/.    FRTCMEETING_UICOMPONET_INCALLVIEW_FRTCPARTICIPANTSVIEW_DIR_SRC)
aux_source_directory(SQMeetingComponent/UIComponent/InCallView/FrtcShareContent/FrtcShareContentSelectWindow/Src/.   FRTCMEETING_UICOMPONET_INCALLVIEW_FRTCSHARECONTENTSELECTWINDOW_DIR_SRC)
aux_source_directory(SQMeetingComponent/UIComponent/InCallView/FrtcShareContent/FrtcSharingFrameWindow/Src/. FRTCMEETING_UICOMPONET_INCALLVIEW_FRTCSHARINGFRAMENWINDOW_DIR_SRC)
aux_source_directory(SQMeetingComponent/UIComponent/InCallView/FrtcShareContent/FrtcSharingBarView/Src/.     FRTCMEETING_UICOMPONET_INCALLVIEW_FRTCSHARINGBARVIEW_DIR_SRC)

aux_source_directory(SQMeetingComponent/UIComponent/InCallView/FrtcCallWindowController/FrtcInCallModel/.    FRTCMEETING_UICOMPONET_INCALLVIEW_FRTCCALLWINDOWCONTROLLER_FRTCCALLMODEL_DIR_SRC)
aux_source_directory(SQMeetingComponent/UIComponent/InCallView/FrtcInfoInstance/.            FRTCMEETING_UICOMPONET_INCALLVIEW_FRTCINFOINSTANCE_DIR_SRC)
aux_source_directory(SQMeetingComponent/FMeetingView/Src/.      FRTC_SDK_FMEETINGVIEW_DIR_SRC)
aux_source_directory(SQMeetingComponent/NotificationCenter/.    FRTC_NOTIFICATIONCENTER_DIR_SRC)
aux_source_directory(SQMeetingComponent/Content/.               FRTC_CONTENT_DIR_SRC)
aux_source_directory(SQMeetingComponent/UserDefault/.           FRTC_SDK_USERDEFAULT_DIR_SRC)
aux_source_directory(SQMeetingComponent/UtilScreen/.            FRTC_SDK_UTIL_SCREEN_DIR_SRC)
aux_source_directory(SQMeetingComponent/UUID/.                  FRTC_SDK_UUID_DIR_SRC)
aux_source_directory(SQMeetingComponent/SvcLayout/.             FRTC_SDK_SVCLAYOUT_DIR_SRC)
aux_source_directory(SQMeetingComponent/DeviceContext/.         FRTC_SDK_DEVICE_DIR_SRC)
aux_source_directory(SQMeetingComponent/Network/.               FRTC_SDK_NETWORK_DIR_SRC)


if(APPLE)
    message("this operation platform is APPLE")
    aux_source_directory(SQMeetingComponent/Audio/AudioSink/AudioSink_macOS/.           FRTC_SDK_AUDIO_SINK_DIR_SRC)
    aux_source_directory(SQMeetingComponent/Audio/AudioCapture/AudioCapture_macOS/.     FRTC_SDK_AUDIO_CAPTURE_DIR_SRC)
    aux_source_directory(SQMeetingComponent/Video/VideoCapture/.     FRTC_SDK_VIDEO_CAPTURE_DIR_SRC)
    aux_source_directory(SQMeetingComponent/Video/VideoRender/.       FRTC_SDK_VIDEO_RENDER_DIR_SRC)
    aux_source_directory(SQMeetingComponent/Audio/AudioDevice/AudioDevice_macOS/.       FRTC_SDK_AUDIO_DEVICE_DIR_SRC)
elseif(UNIX) # (UOS)
    message("this operation platform is UOS")
    aux_source_directory(SQMeetingComponent/Audio/AudioSink/AudioSink_UOS/.           FRTC_SDK_AUDIO_SINK_DIR_SRC)
    aux_source_directory(SQMeetingComponent/Audio/AudioCapture/AudioCapture_UOS/.     FRTC_SDK_AUDIO_CAPTURE_DIR_SRC)
    aux_source_directory(SQMeetingComponent/Video/VideoCapture/.     FRTC_SDK_VIDEO_CAPTURE_DIR_SRC)
    aux_source_directory(SQMeetingComponent/Video/VideoRender/.       FRTC_SDK_VIDEO_RENDER_DIR_SRC)
    aux_source_directory(SQMeetingComponent/Audio/AudioDevice/AudioDevice_UOS/.         FRTC_SDK_AUDIO_DEVICE_DIR_SRC)
elseif(WIN32)
    message("this operation platform is windows")
    aux_source_directory(SQMeetingComponent/Audio/AudioSink/AudioSink_macOS/.           FRTC_SDK_AUDIO_SINK_DIR_SRC)
    aux_source_directory(SQMeetingComponent/Audio/AudioCapture/AudioCapture_macOS/.     FRTC_SDK_AUDIO_CAPTURE_DIR_SRC)
    aux_source_directory(SQMeetingComponent/Video/VideoCapture/.     FRTC_SDK_VIDEO_CAPTURE_DIR_SRC)
    aux_source_directory(SQMeetingComponent/Video/VideoRender/.       FRTC_SDK_VIDEO_RENDER_DIR_SRC)
    aux_source_directory(SQMeetingComponent/Audio/AudioDevice/AudioDevice_macOS/.       FRTC_SDK_AUDIO_DEVICE_DIR_SRC)
endif()


#========================================
# QT Modules and libs.
#========================================

find_package(Qt6Network REQUIRED)
find_package(Qt6Multimedia REQUIRED)



#========================================
# Target
#========================================

if (ANDROID)
    add_library(SQMeeting SHARED
      main.cpp
      qml.qrc
      ${TS_FILES}
    )
elseif(APPLE)
    add_executable(SQMeeting
        MACOSX_BUNDLE
      # for frtc_sdk.
      ${FRTC_INTERFACE_DIR_SRC}
      ${FRTC_SDK_INTERFACE_DIR_SRC}

      ${FRTC_SDK_USERDEFAULT_DIR_SRC}

      # for FrtcMeeting.
      ${FRTC_MEETING_INTERFACE_DIR_SRC}
      ${MAIN_CALLVIEW_DIR_SRC}
      ${FRTCMEETING_UICOMPONET_INCALLVIEW_FRTCMETINGVIEW_DIR_SRC}
      ${FRTCMEETING_UICOMPONET_INCALLVIEW_FRTCCALLBARVIEW_DIR_SRC}
      ${FRTCMEETING_UICOMPONET_INCALLVIEW_TITLEVIEW_DIR_SRC}
      ${FRTCMEETING_UICOMPONET_INCALLVIEW_FRTCMEETINGINFOVIEW_DIR_SRC}
      ${FRTCMEETING_UICOMPONET_INCALLVIEW_FRTCNETWORKINFOVIEW_DIR_SRC}
      ${FRTCMEETING_UICOMPONET_INCALLVIEW_FRTCPARTICIPANTSVIEW_DIR_SRC}
      
      # for share content.
      ${FRTCMEETING_UICOMPONET_INCALLVIEW_FRTCSHARECONTENTSELECTWINDOW_DIR_SRC}
      ${FRTCMEETING_UICOMPONET_INCALLVIEW_FRTCSHARINGFRAMENWINDOW_DIR_SRC}
      ${FRTCMEETING_UICOMPONET_INCALLVIEW_FRTCSHARINGBARVIEW_DIR_SRC}

      ${FRTCMEETING_UICOMPONET_INCALLVIEW_FRTCCALLWINDOWCONTROLLER_FRTCCALLMODEL_DIR_SRC}
      ${FRTCMEETING_UICOMPONET_INCALLVIEW_FRTCINFOINSTANCE_DIR_SRC}
      ${FRTCMEETING_UTILS_DIR_SRC}

      #new add
      ${FRTC_SDK_AUDIO_SINK_DIR_SRC}
      ${FRTC_SDK_AUDIO_CAPTURE_DIR_SRC}
      ${FRTC_SDK_AUDIO_DEVICE_DIR_SRC}

      SQMeetingComponent/Audio/AudioCapture/AudioCapture.hpp
      SQMeetingComponent/Audio/AudioCapture/IAudioCapture.h
      SQMeetingComponent/Audio/AudioSink/AudioSink.hpp
      SQMeetingComponent/Audio/AudioSink/IAudioSink.h

      ${FRTC_SDK_VIDEO_CAPTURE_DIR_SRC}
      ${FRTC_SDK_VIDEO_RENDER_DIR_SRC}
      ${FRTC_SDK_FMEETINGVIEW_DIR_SRC}
      ${FRTC_NOTIFICATIONCENTER_DIR_SRC}
      ${FRTC_CONTENT_DIR_SRC}
      ${FRTC_SDK_USERDEFAULT_DIR_SRC}

      ${FRTC_SDK_UUID_DIR_SRC}
      ${FRTC_SDK_UTIL_SCREEN_DIR_SRC}
      ${FRTC_SDK_SVCLAYOUT_DIR_SRC}
      ${FRTC_SDK_DEVICE_DIR_SRC}
      ${FRTC_SDK_NETWORK_DIR_SRC}

      ${FRTC_MEETING_STRATEGY_DIR_SRC}
      ${FRTC_MEETING_STRATEGY_FACTORY_DIR_SRC}

      main.cpp
      qml.qrc
      ${TS_FILES}
      ${APP_ICONS} # Add icon file to see in IDE.
      ${resources_skin_root}
      SQMeetingComponent/FrtcMeetingInterface/MessageHandlerStrategy/UnMuteAllowedHandler.h SQMeetingComponent/FrtcMeetingInterface/MessageHandlerStrategy/UnMuteAllowedHandler.cpp
      SQMeetingComponent/FrtcMeetingInterface/MessageHandlerStrategy/WaterMaskHandler.h SQMeetingComponent/FrtcMeetingInterface/MessageHandlerStrategy/WaterMaskHandler.cpp
      SQMeetingComponent/FrtcMeetingInterface/MessageHandlerStrategy/OverlayMessageHandler.h SQMeetingComponent/FrtcMeetingInterface/MessageHandlerStrategy/OverlayMessageHandler.cpp
      SQMeetingComponent/FrtcMeetingInterface/MessageHandlerStrategy/UnMuteRequestHandler.h SQMeetingComponent/FrtcMeetingInterface/MessageHandlerStrategy/UnMuteRequestHandler.cpp
      SQMeetingComponent/FrtcMeetingInterface/MessageHandlerStrategy/LayoutSettingChangedHandler.h SQMeetingComponent/FrtcMeetingInterface/MessageHandlerStrategy/LayoutSettingChangedHandler.cpp
      SQMeetingComponent/UserDefault/FrtcFileManager.h SQMeetingComponent/UserDefault/FrtcFileManager.cpp
      SQMeetingComponent/FrtcMeetingInterface/MessageHandlerStrategy/PinSpeakerChangedHandler.h SQMeetingComponent/FrtcMeetingInterface/MessageHandlerStrategy/PinSpeakerChangedHandler.cpp
    )
elseif(UNIX)
    qt6_add_resources(RESOURCES qml.qrc)

    add_executable(SQMeeting
      # for frtc_sdk.
      ${FRTC_INTERFACE_DIR_SRC}
      ${FRTC_SDK_INTERFACE_DIR_SRC}

      ${FRTC_SDK_USERDEFAULT_DIR_SRC}

      # for FrtcMeeting.
      ${FRTC_MEETING_INTERFACE_DIR_SRC}
      ${MAIN_CALLVIEW_DIR_SRC}
      ${FRTCMEETING_UICOMPONET_INCALLVIEW_FRTCMETINGVIEW_DIR_SRC}
      ${FRTCMEETING_UICOMPONET_INCALLVIEW_FRTCCALLBARVIEW_DIR_SRC}
      ${FRTCMEETING_UICOMPONET_INCALLVIEW_TITLEVIEW_DIR_SRC}
      ${FRTCMEETING_UICOMPONET_INCALLVIEW_FRTCMEETINGINFOVIEW_DIR_SRC}
      ${FRTCMEETING_UICOMPONET_INCALLVIEW_FRTCNETWORKINFOVIEW_DIR_SRC}
      ${FRTCMEETING_UICOMPONET_INCALLVIEW_FRTCPARTICIPANTSVIEW_DIR_SRC}
      
      # for share content.
      ${FRTCMEETING_UICOMPONET_INCALLVIEW_FRTCSHARECONTENTSELECTWINDOW_DIR_SRC}
      ${FRTCMEETING_UICOMPONET_INCALLVIEW_FRTCSHARINGFRAMENWINDOW_DIR_SRC}
      ${FRTCMEETING_UICOMPONET_INCALLVIEW_FRTCSHARINGBARVIEW_DIR_SRC}

      ${FRTCMEETING_UICOMPONET_INCALLVIEW_FRTCCALLWINDOWCONTROLLER_FRTCCALLMODEL_DIR_SRC}
      ${FRTCMEETING_UICOMPONET_INCALLVIEW_FRTCINFOINSTANCE_DIR_SRC}
      ${FRTCMEETING_UTILS_DIR_SRC}

      #new add
      ${FRTC_SDK_AUDIO_SINK_DIR_SRC}
      ${FRTC_SDK_AUDIO_CAPTURE_DIR_SRC}
      ${FRTC_SDK_AUDIO_DEVICE_DIR_SRC}
      SQMeetingComponent/Audio/AudioCapture/AudioCapture.hpp
      SQMeetingComponent/Audio/AudioSink/AudioSink.hpp

      ${FRTC_SDK_VIDEO_CAPTURE_DIR_SRC}
      ${FRTC_SDK_VIDEO_RENDER_DIR_SRC}
      ${FRTC_SDK_FMEETINGVIEW_DIR_SRC}
      ${FRTC_NOTIFICATIONCENTER_DIR_SRC}
      ${FRTC_CONTENT_DIR_SRC}
      ${FRTC_SDK_USERDEFAULT_DIR_SRC}

      ${FRTC_SDK_UUID_DIR_SRC}
      ${FRTC_SDK_UTIL_SCREEN_DIR_SRC}
      ${FRTC_SDK_SVCLAYOUT_DIR_SRC}
      ${FRTC_SDK_DEVICE_DIR_SRC}
      ${FRTC_SDK_NETWORK_DIR_SRC}
      ${FRTC_MEETING_STRATEGY_DIR_SRC}
      ${FRTC_MEETING_STRATEGY_FACTORY_DIR_SRC}

      main.cpp
      qml.qrc
      ${TS_FILES}
      ${APP_ICONS} # Add icon file to see in IDE.
      ${resources_skin_root}
      ${RESOURCES}
    )
elseif(WIN32)
    add_executable(SQMeeting
      # for frtc_sdk.
      ${FRTC_INTERFACE_DIR_SRC}
      ${FRTC_SDK_INTERFACE_DIR_SRC}

      ${FRTC_SDK_USERDEFAULT_DIR_SRC}

      # for FrtcMeeting.
      ${FRTC_MEETING_INTERFACE_DIR_SRC}
      ${MAIN_CALLVIEW_DIR_SRC}
      ${FRTCMEETING_UICOMPONET_INCALLVIEW_FRTCMETINGVIEW_DIR_SRC}
      ${FRTCMEETING_UICOMPONET_INCALLVIEW_FRTCCALLBARVIEW_DIR_SRC}
      ${FRTCMEETING_UICOMPONET_INCALLVIEW_TITLEVIEW_DIR_SRC}
      ${FRTCMEETING_UICOMPONET_INCALLVIEW_FRTCMEETINGINFOVIEW_DIR_SRC}
      ${FRTCMEETING_UICOMPONET_INCALLVIEW_FRTCNETWORKINFOVIEW_DIR_SRC}
      ${FRTCMEETING_UICOMPONET_INCALLVIEW_FRTCPARTICIPANTSVIEW_DIR_SRC}
      
      # for share content.
      ${FRTCMEETING_UICOMPONET_INCALLVIEW_FRTCSHARECONTENTSELECTWINDOW_DIR_SRC}
      ${FRTCMEETING_UICOMPONET_INCALLVIEW_FRTCSHARINGFRAMENWINDOW_DIR_SRC}
      ${FRTCMEETING_UICOMPONET_INCALLVIEW_FRTCSHARINGBARVIEW_DIR_SRC}

      ${FRTCMEETING_UICOMPONET_INCALLVIEW_FRTCCALLWINDOWCONTROLLER_FRTCCALLMODEL_DIR_SRC}
      ${FRTCMEETING_UICOMPONET_INCALLVIEW_FRTCINFOINSTANCE_DIR_SRC}
      ${FRTCMEETING_UTILS_DIR_SRC}

      #new add
      ${FRTC_SDK_AUDIO_SINK_DIR_SRC}
      ${FRTC_SDK_AUDIO_CAPTURE_DIR_SRC}
      ${FRTC_SDK_AUDIO_DEVICE_DIR_SRC}
      SQMeetingComponent/Audio/AudioCapture/AudioCapture.hpp
      SQMeetingComponent/Audio/AudioSink/AudioSink.hpp

      ${FRTC_SDK_VIDEO_CAPTURE_DIR_SRC}
      ${FRTC_SDK_VIDEO_RENDER_DIR_SRC}
      ${FRTC_SDK_FMEETINGVIEW_DIR_SRC}
      ${FRTC_NOTIFICATIONCENTER_DIR_SRC}
      ${FRTC_CONTENT_DIR_SRC}
      ${FRTC_SDK_USERDEFAULT_DIR_SRC}

      ${FRTC_SDK_UUID_DIR_SRC}
      ${FRTC_SDK_UTIL_SCREEN_DIR_SRC}
      ${FRTC_SDK_SVCLAYOUT_DIR_SRC}
      ${FRTC_SDK_DEVICE_DIR_SRC}
      ${FRTC_SDK_NETWORK_DIR_SRC}
      ${FRTC_MEETING_STRATEGY_DIR_SRC}
      ${FRTC_MEETING_STRATEGY_FACTORY_DIR_SRC}

      main.cpp
      qml.qrc
      main.qml
      ${TS_FILES}
      ${APP_ICONS} # Add icon file to see in IDE.
      ${resources_skin_root}
    )

endif()

target_compile_definitions(SQMeeting
  PRIVATE $<$<CONFIG:RelWithDebInfo>:QT_QML_DEBUG>)


if(APPLE)
    message("this operation platform is APPLE")
    target_link_libraries(SQMeeting
      PRIVATE
      Qt6::Core
      Qt6::Quick
      Qt6::Network
      Qt6::Multimedia
      Qt${QT_VERSION_MAJOR}::MultimediaWidgets
      ${Qt6Quick_LIBRARIES} #for QQuickImageProvider
      ${Qt6Multimedia_LIBRARIES} #for QAudioDeviceInfo

      # common code sdk.
      rtcsdk
      frtc_sdk
      jsoncpp
      ${LOG4CPLUS_LIBRARY}
     )
elseif(UNIX) # (UOS)
    message("this operation platform is UOS OR UNIX")
    target_link_libraries(SQMeeting
      PRIVATE 

      Qt6::Core 
      Qt6::Quick
      Qt6::Network
      Qt6::Multimedia
      Qt6::MultimediaWidgets
      ${Qt6Quick_LIBRARIES} #for QQuickImageProvider
      ${Qt6Multimedia_LIBRARIES} #for QAudioDeviceInfo      

      log4cplus
      libpulse
      libasound
      libportaudio

      rtc_sdk
      frtc_sdk
    )

elseif(WIN32) #MSVC
    message("this operation platform is windows")
    target_link_libraries(SQMeeting
        PRIVATE
        Qt6::Core
        Qt6::Quick
        Qt6::QuickControls2
        Qt6::Network
        Qt6::Multimedia
        Qt6::MultimediaWidgets
        
        frtc_sdk
     )
endif()

# set application info.
# set target Application name from Project name "FrtcMeeting" to "神旗"
#SET_TARGET_PROPERTIES (FrtcMeeting PROPERTIES OUTPUT_NAME "神旗")
#SET_TARGET_PROPERTIES (FrtcMeeting PROPERTIES OUTPUT_NAME "ShenQi")

set_target_properties(SQMeeting PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)

if (APPLE)
    message("=== === === [macOS] : add Info.plist to macOS === === ===")
    set_target_properties(SQMeeting PROPERTIES
        MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_SOURCE_DIR}/doc/mac/Info.plist"
    )

    qt_finalize_executable(SQMeeting)

endif()



#[Qt-bug] Qt clean will remove the ts files.
# Qt6_create_translation(QM_FILES ${CMAKE_SOURCE_DIR} ${TS_FILES})

#add_subdirectory(frtc_sdk_bundle/frtc_sdk_plugin/)
#add_subdirectory(frtc_sdk_dist/)
