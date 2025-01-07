#ifndef UTILSCREEN_H
#define UTILSCREEN_H

#include<QDebug>
#include<QGuiApplication>
#include<QScreen>
#include<QRect>

class UtilScreen {
public:
    UtilScreen();

    static void getAllScreenInfo();
    static void getPrimaryScreen();
    static QRect screenSize();
    static QSize currentSize();

    static float ratio();
    static float updateRation(QSize size);

    static int disPlayWidth();
    static int disPlayHeight();
};

#endif // UTILSCREEN_H
