#ifndef SDKDEVICECONTEXT_H
#define SDKDEVICECONTEXT_H
#include "UnifiedVideoCapture.h"
#include "AudioCapture.hpp"
#include "FContentCapture.h"

//using namespace std;

class SDKDeviceContext: public QObject {

private:
    static SDKDeviceContext *shareInstance;
public:
    static SDKDeviceContext* getInstance();
    static void releaseInstance();
private:
    SDKDeviceContext();

public slots:
    void stopCapture();

public:
    void startAudioUnitCapture();
    void stopAudioUnitCapture();
    //receive remote audio and speaker play
    void startAudioSink();
    void stopAudioSink();
    
    void selectCamera(QString id);
    void getCameraList(std::vector<QString> &cameraList);

    //local mic
    void muteMicrophone(bool mute);


    void getMicphoneList(QList<QString> &micList);
    void micphoneList(std::vector<QAudioDevice> &micList);

    void selectMic(QString id);
    
    void getSpeakerList(QList<QString> &spkList);
    void speakerList(QList<QString> &spkList);


    void selectSpeaker(QString id);
    
    QString getCurrentMicphoneName();
    QString getCurrentSpeakerName();

    QString getDefaultMicName();
    QString getDefaultSpeakerName();
    
//- VideoCapture API

    void initVideoCapture();
    void startVideoCapture();
    void stopVideoCapture();

    void setVideoSourceId(const std::string& sourceId);

public:
    //for share content.
    void startShareScreen();
    void stopShareScreen();
    
    void onOpenCameraComplete(int nOpenResulte);
    
private:
    FContentCapture *m_fContentScreenCapture;
};

#endif // SDKDEVICECONTEXT_H
