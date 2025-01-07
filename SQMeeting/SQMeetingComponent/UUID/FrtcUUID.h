#ifndef FRTCUUID_H
#define FRTCUUID_H

#include <QString>
#include <iostream>

//using namespace std;


class FrtcUUID// : public QObject
{
    //private:
    //    //[Note]: no use.
    //    FrtcUUID();

private:
    static std::string appUUID;

public:
    //[Note]: only call one time for FrtcMeeting App, for every user.
    static QString generateApplicationUUID();

    static std::string getApplicationUUID();

    static bool saveUUIDToAppConfigFile(QString uuid);
    static QString readUUIDFromAppConfigFile();

};

#endif // FRTCUUID_H
