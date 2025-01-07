#include "UtilScreen.h"

UtilScreen::UtilScreen() {
}


//==================== begin for Screen resolution ====================

//#pragma mark --ViewController Size Internal Function--

//如果为2个屏幕，默认计算机主屏幕index=0，外接显示器index = 1
void UtilScreen::getAllScreenInfo() {
    //qDebug("[%s]", Q_FUNC_INFO);
    QList<QScreen *> list_screen =  QGuiApplication::screens();
    // QRect rect = list_screen.at(0)->geometry();
    foreach(auto screen, list_screen) {
        QRect rect = screen->geometry();
        int desktop_width = rect.width();
        int desktop_height = rect.height();
        //qDebug() << "screen : " << screen << ", name : " << screen->name() << ": " << desktop_width << ", " << desktop_height;
    }
}

void UtilScreen::getPrimaryScreen() {
    //qDebug("[%s]", Q_FUNC_INFO);
    QScreen *primaryScreen = QGuiApplication::primaryScreen();
    QRect rect = primaryScreen->geometry();
    int desktop_width = rect.width();
    int desktop_height = rect.height();
    //qDebug() << "primaryScreen : " << primaryScreen << ", name : " << primaryScreen->name() << ": " << desktop_width << ", " << desktop_height;
}


QRect UtilScreen::screenSize() {
    QScreen *primaryScreen = QGuiApplication::primaryScreen();
    QRect rect = primaryScreen->geometry();
    int desktop_width = rect.width();
    int desktop_height = rect.height();
    //qDebug() << "primaryScreen : " << primaryScreen << ", name : " << primaryScreen->name() << ": " << desktop_width << ", " << desktop_height;
    return rect;
}

QSize UtilScreen::currentSize() {
    //qDebug("[%s]", Q_FUNC_INFO);
    QRect displayPixelSize = screenSize();
    int height = displayPixelSize.height();
    if (height >= 1200) {
        return QSize(1536, 1037);
    } else if (height >= 1000 && height < 1200) {
        return QSize(1280, 864);
    } else if (height >= 800 && height < 1000) {
        return QSize(1024, 691);
    } else {
        return QSize(819, 551);
    }
}

float UtilScreen::ratio() {
    QSize displayPixelSize = currentSize();
    int height = displayPixelSize.height();
    if (height >= 1200) {
        return 1.2;
    } else if (height >= 1000 && height < 1200) {
        return 1.0;
    } else if (height >= 800 && height < 1000) {
        return 0.8;
    } else {
        return 0.64;
    }
}

float UtilScreen::updateRation(QSize size) {
    int height = size.height();
    if (height >= 1200) {
        return 1.2;
    } else if (height >= 1000 && height < 1200) {
        return 1.0;
    } else if (height >= 800 && height < 1000) {
        return 0.8;
    } else {
        return 0.64;
    }
}

int UtilScreen::disPlayWidth() {
    return currentSize().width();
}

int UtilScreen::disPlayHeight() {
    return currentSize().height();
}
//==================== end for Screen resolution ====================
