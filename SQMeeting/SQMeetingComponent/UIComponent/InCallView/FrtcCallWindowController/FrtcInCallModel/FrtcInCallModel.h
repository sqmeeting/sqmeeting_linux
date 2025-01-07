//
//  FrtcInCallModel.h
//  class FrtcInCallModel.
//  sdk Qt version.
//
//  Created by Yingyong.Mao on 2022/12/19.
//  Copyright © 2022 毛英勇. All rights reserved.
//


#ifndef FRTCCALLMODEL_H
#define FRTCCALLMODEL_H

#include <iostream>
#include <QString>

//using namespace std;

class FrtcInCallModel {
    
public:
    FrtcInCallModel();

    QString conferenceNumber;
    QString clientName;
    QString conferenceName;
    QString ownerID;
    QString ownerName;
    QString userID;
    QString userToken;
    QString conferenceStartTime;
    QString conferencePassword;
    QString meetingUrl;
    QString scheduleStartTime;
    QString scheduleEndTime;
    QString userIdentifier;
    
    bool muteMicrophone;
    bool muteCamera;
    bool authority;
    bool audioOnly;
    bool loginCall;
    
    bool isMuteMicrophone() { return muteMicrophone; }
    bool isMuteCamera() { return muteCamera; }
    bool isAuthority() { return authority; }
    bool isAudioOnly() { return audioOnly; }
    bool isLoginCall() { return loginCall; }
};

#endif // FRTCCALLMODEL_H
