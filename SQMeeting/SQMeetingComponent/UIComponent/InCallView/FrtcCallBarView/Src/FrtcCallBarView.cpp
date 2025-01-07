#include "FrtcCallBarView.h"

FrtcCallBarView::FrtcCallBarView(QObject *parent)
: QObject(parent) {
    qDebug("[%s][%d]", Q_FUNC_INFO, __LINE__);
}

FrtcCallBarView::~FrtcCallBarView() {
    //qDebug("[%s][%d] -> call stopRendering()", Q_FUNC_INFO, __LINE__);

    
}

void FrtcCallBarView::onQmlLocalAudioMute(bool mute) {
    qDebug("[%s][%d]", Q_FUNC_INFO, __LINE__);

}

void FrtcCallBarView::onQmlLocalVideoMute(bool mute) {
    qDebug("[%s][%d]", Q_FUNC_INFO, __LINE__);

}
