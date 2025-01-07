#ifndef IAUDIOSINK_H
#define IAUDIOSINK_H

#include "IAudioSink.h"

#if defined (WIN32)
#include "AudioSink_macOS/AudioUnitSinkChan_macOS.h"
#elif defined (__APPLE__)
#include "AudioSink_macOS/AudioUnitSinkChan_macOS.h"
#elif defined (UOS)
#include "AudioSink_UOS/AudioUnitSinkChan.h"
#endif


class AudioSink
{
public:
    static IAudioSink* getAudioSink()
    {
#if defined(WIN32)
        return dynamic_cast<IAudioSink *>(AudioUnitSinkChan_macOS::getInstance());
#elif defined(__APPLE__)
        return dynamic_cast<IAudioSink *>(AudioUnitSinkChan_macOS::getInstance());
#elif defined(UOS)
        return dynamic_cast<IAudioSink *>(AudioUnitSinkChan::getInstance());
#endif
    }
};

#endif