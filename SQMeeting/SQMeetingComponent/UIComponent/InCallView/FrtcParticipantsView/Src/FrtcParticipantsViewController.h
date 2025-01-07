#ifndef FRTCPARTICIPANTVIEWCONTROLLER_H
#define FRTCPARTICIPANTVIEWCONTROLLER_H

#include <QObject>
#include <QTimer>
#include <QMutex>
#include <QDebug>

class FrtcParticipantsViewController : public QObject {
    Q_OBJECT
    Q_DISABLE_COPY(FrtcParticipantsViewController);

private:
    static QMutex m_Mutex;
    static FrtcParticipantsViewController *shareInstance;
public:
    static FrtcParticipantsViewController* getInstance();
    void releaseInstance();
    explicit FrtcParticipantsViewController(QObject *parent = nullptr);
    ~FrtcParticipantsViewController();

public:
    // [set action]: QML emit signal, then those mothods will be called for action.
    //1.for incall UI Tabbar button.
    Q_INVOKABLE void onQmlInvitate();

    Q_INVOKABLE int onQmlGetParticipantsNumber();
    Q_INVOKABLE QVariant onQmlGetParticipantsList();

    QVariant getRosterList(); //prepare for the fist time show ParticipantList UI.

public:
    void updateRosterNumber(int rosterNumber);
    void udateRosterList(std::vector<std::string> rosterList);

signals:
    void cppSendMsgToQMLUpdateRosterNumber(const int rosterNumber);
    void cppSendMsgToQMLUpdateRosterList(const QVariant &rosterListObject);

};

#endif // FRTCPARTICIPANTVIEWCONTROLLER_H
