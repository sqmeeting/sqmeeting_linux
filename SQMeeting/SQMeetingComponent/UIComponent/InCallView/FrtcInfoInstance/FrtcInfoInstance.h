#ifndef FRTCINFOINSTANCE_H
#define FRTCINFOINSTANCE_H

#include <QMutex>
#include <QObject>
#include <QVariant>
#include "FrtcInCallModel.h"


class FrtcInfoInstance {
    
private:
    static QMutex m_Mutex;
    static FrtcInfoInstance *shareInstance;
public:
    static FrtcInfoInstance* sharedFrtcInfoInstance();
    static void releaseInstance();
    
private:
    FrtcInfoInstance();
    
public:

    FrtcInCallModel *inCallModel;

    int rosterNumber;
    std::vector<std::string> rosterList;
public:
    int getRosterNumber();
    std::vector<std::string> getRosterList();

    void updateRosterNumber(int rosterNumber);
    void udateRosterList(std::vector<std::string> rosterList);

};

#endif // FRTCINFOINSTANCE_H
