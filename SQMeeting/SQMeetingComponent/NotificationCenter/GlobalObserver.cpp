#include "GlobalObserver.h"

GlobalObserver *GlobalObserver::m_pInst = NULL;
GlobalObserver *GlobalObserver::getGlobalObserver() {
    if (m_pInst == NULL) {
        m_pInst = new GlobalObserver();
    }
    return m_pInst;
}

void GlobalObserver::release() {
    if (m_pInst != NULL) {
        delete m_pInst;
        m_pInst = NULL;
    }
}

void GlobalObserver::attach(const QString type, QObject *reciver, const char *method) {
//    ObesrverApater *oA = ObesrverApaterFactory::getInstance()->createObesrverApater();
//    connect(oA, SIGNAL(notify()), reciver, method);
    relationData *data = new relationData();
    data->type = type;
    data->reciver = reciver;
//    data->obesrverApater = oA;
    data->method = method;
    m_oRelationList.append(data);
}

void GlobalObserver::detach(const QString type, const QObject *reciver) {
    QList<relationData*>::iterator iter = m_oRelationList.begin();

    while (iter != m_oRelationList.end()) {
        if ((*iter)->type.compare(type) == 0 && (*iter)->reciver == reciver) {
            relationData *data = *iter;
            m_oRelationList.removeOne((*iter));

//            delete data->obesrverApater;
            delete data;
            return;
        }
        iter++;
    }
}

void GlobalObserver::notify(const QString type,
                            QGenericArgument val0, QGenericArgument val1,
                            QGenericArgument val2, QGenericArgument val3,
                            QGenericArgument val4, QGenericArgument val5, QGenericArgument val6,
                            QGenericArgument val7, QGenericArgument val8, QGenericArgument val9) {

    QList<relationData*>::iterator iter = m_oRelationList.begin();
    while (iter != m_oRelationList.end()) {
        if ((*iter)->type.compare(type) == 0) {
            QMetaObject::invokeMethod((*iter)->reciver, (*iter)->method, Qt::AutoConnection, val0, val1, val2, val3, val4, val5, val6, val7, val8, val9);
//            emit (*iter)->obesrverApater->notify();
        }
        iter++;
    }
}

GlobalObserver::GlobalObserver(QObject *parent) : QObject(parent) {

}

GlobalObserver::~GlobalObserver() {
    //释放列表数据
    QList<relationData*>::iterator iter = m_oRelationList.begin();

    while (iter != m_oRelationList.end()) {
//        delete (*iter)->obesrverApater;
        delete *iter;
        iter++;
    }

}
