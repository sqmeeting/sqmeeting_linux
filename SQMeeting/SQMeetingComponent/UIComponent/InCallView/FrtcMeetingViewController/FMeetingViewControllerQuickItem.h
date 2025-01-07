//
//  FMeetingViewControllerQuickItem.h
//  class FMeetingViewControllerQuickItem.
//  frtc_sdk Qt version.
//
//  Created by Yingyong.Mao on 2023/12/03.
//  Copyright © 2022 毛英勇. All rights reserved.
//


#ifndef FMEETINGVIEWCONTROLLER_QUICKITEM_H
#define FMEETINGVIEWCONTROLLER_QUICKITEM_H

#include <QtQuick/QQuickPaintedItem>
#include <QColor>

/**
 * @brief The FMeetingViewControllerQuickItem class. Simple QQuickItem plugin example;
 */
class FMeetingViewControllerQuickItem: public QQuickPaintedItem {
    Q_OBJECT
    Q_PROPERTY(QColor color READ getColor WRITE setColor NOTIFY colorChanged)
public:
    FMeetingViewControllerQuickItem(QQuickItem* parent = nullptr);

    /**
     * @brief getColor  getter for @property color
     * @return          current color
     */
    QColor getColor() const;

    /**
     * @brief setColor  setter for @property color
     * @param color     color to set
     */
    void setColor(const QColor &color);

    /**
     * @brief paint     overrided method that will paint our item on scene
     * @param painter   painter
     */
    void paint(QPainter *painter) override;

signals:
    /**
     * @brief colorChanged  signal that should be emitted when @property color changes
     */
    void colorChanged();

private:
    QColor color;
};

#endif // FMEETINGVIEWCONTROLLER_QUICKITEM_H
