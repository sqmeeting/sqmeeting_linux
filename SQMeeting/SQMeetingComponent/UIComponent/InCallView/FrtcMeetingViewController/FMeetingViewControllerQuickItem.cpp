//
//  FMeetingViewControllerQuickItem.cpp
//  class FMeetingViewControllerQuickItem.
//  frtc_sdk Qt version.
//
//  Created by Yingyong.Mao on 2023/12/03.
//  Copyright © 2022 毛英勇. All rights reserved.
//


#include "FMeetingViewControllerQuickItem.h"

#include <QPen>
#include <QPainter>

FMeetingViewControllerQuickItem::FMeetingViewControllerQuickItem(QQuickItem* parent)
    : QQuickPaintedItem(parent) {

}

QColor FMeetingViewControllerQuickItem::getColor() const {
    return color;
}

void FMeetingViewControllerQuickItem::setColor(const QColor& color) {
    // Look at chapter 3 http://doc.qt.io/qt-5/qtqml-tutorials-extending-qml-example.html
    if (color != this->color) {
        this->color = color;
        update();
        emit colorChanged();
    }
}

void FMeetingViewControllerQuickItem::paint(QPainter* painter) {
    // Drawing simple filled rect
    QPen pen(color, 2);
    painter->setPen(pen);
    painter->fillRect(QRectF(0, 0, width(), height()), color);
}
