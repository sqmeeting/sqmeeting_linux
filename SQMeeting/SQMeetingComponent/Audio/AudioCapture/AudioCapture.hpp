#ifndef IAUDIOCAPTURE_H
#define IAUDIOCAPTURE_H

#include "IAudioCapture.h"

#if defined (WIN32)
#include "AudioCapture_macOS/AudioUnitCapture.h"
#elif defined (__APPLE__)
#include "AudioCapture_macOS/AudioUnitCapture.h"
#elif defined (UOS)
#include "AudioCapture_UOS/AudioUnitCapture.h"
#endif


class AudioCapture
{
public:
    static IAudioCapture* getAudioCapture()
    {
#if defined(WIN32)
        return dynamic_cast<IAudioCapture *>(AudioUnitCapture::getInstance());
#elif defined(__APPLE__)
        return dynamic_cast<IAudioCapture *>(AudioUnitCapture::getInstance());
#elif defined(UOS)
        return dynamic_cast<IAudioCapture *>(AudioUnitCapture::getInstance());
#endif
    }
};
#endif