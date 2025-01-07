#if defined (UOS)
#elif defined (__APPLE__)
#elif defined (WIN32)
#include<windows.h>
#endif


#include "SVCLayoutManager.h"
#include <QDebug>
#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonArray>

#include <iostream>

//#include <QtGlobal> //for Q_OS_WIN

#include "FMeetingViewController.h"

//using namespace std;

namespace MeetingLayout
{

//==================================================
// for SVC Layout
//==================================================

//SVCLayoutDetail gSvcLayoutDetail[SVC_LAYOUT_MODE_NUMBER] = {0};

//[3x3]: full screen.
//#ifdef Q_OS_WIN
#if defined (WIN32)
//void SVCLayoutManager::initializeSVCLayoutDetail(SVCLayoutDetail* layoutDetail, int videoViewNum, bool isSymmetical, const float videoViewDescription[][4]) {
//    layoutDetail->videoViewNum = videoViewNum;
//    layoutDetail->isSymmetical = isSymmetical;
//    memcpy(layoutDetail->videoViewDescription, videoViewDescription, sizeof(float) * (REMOTE_PEOPLE_VIDEO_NUMBER + 2) * 4);
//}

void SVCLayoutManager::prepareSVCFullScreen3x3LayoutDetail() {

    for (SVCLayoutModeType mode = SVC_LAYOUT_MODE_1X1; mode < SVC_LAYOUT_MODE_NUMBER ; ) {
        switch (mode) {
        case SVC_LAYOUT_MODE_1X1:

//            gSvcLayoutDetail[mode] = (SVCLayoutDetail) {1, true,
//                                                       {{0, 0, 1.0, 1.0},
//                                                        {0.8, 0, 0.2, 0.17}}};

            gSvcLayoutDetail[mode] = {1, true,
                                                       {{0, 0, 1.0, 1.0},
                                                       {0.8, 0, 0.2, 0.17}}};

//                            static const SVCLayoutDetail defaultLayout = {
//                                                            .videoViewNum = 1,
//                                                            .isSymmetical = true,
//                                                            .videoViewDescription = {{0, 0, 1.0, 1.0}, {0.8, 0, 0.2, 0.17}}
//                                                        };

//            SVCLayoutDetail layout;
//            initializeSVCLayoutDetail(&layout, 1, true, {{0, 0, 1.0, 1.0}, {0.8, 0, 0.2, 0.17}});

            mode = SVC_LAYOUT_MODE_1X2;
            break;

        case SVC_LAYOUT_MODE_1X2:
            gSvcLayoutDetail[mode] = {2, true,
                                                       {{0, 0.25, 0.5, 0.5},
                                                        {0.5, 0.25, 0.5, 0.5},
                                                        {0.8, 0, 0.2, 0.17}} };
            mode = SVC_LAYOUT_MODE_1X3;
            break;

        case SVC_LAYOUT_MODE_1X3:
            gSvcLayoutDetail[mode]= {3, true,
                                                       {{0.25, 0, 0.5, 0.5},
                                                        {0, 0.5, 0.5, 0.5},
                                                        {0.5, 0.5, 0.5, 0.5},
                                                        {0.8, 0, 0.2, 0.17}}};
            mode = SVC_LAYOUT_MODE_1X4;
            break;

        case SVC_LAYOUT_MODE_1X4:
            gSvcLayoutDetail[mode] = {4, true,
                                                       {{0, 0, 0.5, 0.5},
                                                        {0.5, 0, 0.5, 0.5},
                                                        {0, 0.5, 0.5, 0.5},
                                                        {0.5, 0.5, 0.5, 0.5},
                                                        {0.8, 0, 0.2, 0.17}} };
            mode = SVC_LAYOUT_MODE_1X5;
            break;

        case SVC_LAYOUT_MODE_1X5:
            gSvcLayoutDetail[mode] = {4, true,
                                                       {{0, 0, 0.333, 0.333},
                                                           {0.333, 0, 0.333, 0.333},
                                                           {0.666, 0, 0.333, 0.333},
                                                           {0, 0.333, 0.333, 0.333},
                                                           {0.333, 0.333, 0.333, 0.333},
                                                           {0.8, 0, 0.2, 0.17}
                                                       } };
            mode = SVC_LAYOUT_MODE_1X6;
            break;

        case SVC_LAYOUT_MODE_1X6:
            gSvcLayoutDetail[mode] =  {4, true,
                                                       {{0, 0, 0.333, 0.333},
                                                           {0.333, 0, 0.333, 0.333},
                                                           {0.666, 0, 0.333, 0.333},
                                                           {0, 0.333, 0.333, 0.333},
                                                           {0.333, 0.333, 0.333, 0.333},
                                                           {0.666, 0.333, 0.333, 0.333},
                                                           {0.8, 0, 0.2, 0.17}
                                                       } };
            mode = SVC_LAYOUT_MODE_1X7;
            break;

        case SVC_LAYOUT_MODE_1X7:
            gSvcLayoutDetail[mode] =  {4, true,
                                                       {{0, 0, 0.333, 0.333},
                                                           {0.333, 0, 0.333, 0.333},
                                                           {0.666, 0, 0.336, 0.336},
                                                           {0, 0.333, 0.336, 0.336},
                                                           {0.336, 0.333, 0.333, 0.333},
                                                           {0.666, 0.333, 0.333, 0.333},
                                                           {0, 0.666, 0.333, 0.333},

                                                           {0.8, 0, 0.2, 0.17}
                                                       } };
            mode = SVC_LAYOUT_MODE_1X8;
            break;

        case SVC_LAYOUT_MODE_1X8:
            gSvcLayoutDetail[mode] =  {4, true,
                                                       {{0, 0, 0.333, 0.333},
                                                           {0.333, 0, 0.333, 0.333},
                                                           {0.666, 0, 0.333, 0.333},
                                                           {0, 0.333, 0.333, 0.333},
                                                           {0.333, 0.333, 0.333, 0.333},
                                                           {0.666, 0.333, 0.333, 0.333},
                                                           {0, 0.666, 0.333, 0.333},
                                                           {0.333, 0.666, 0.333, 0.333},
                                                           {0.8, 0, 0.2, 0.17}
                                                       } };
            mode = SVC_LAYOUT_MODE_1X9;
            break;

        case SVC_LAYOUT_MODE_1X9:
            gSvcLayoutDetail[mode] =  {4, true,
                                                       {{0, 0, 0.333, 0.333},
                                                           {0.333, 0, 0.333, 0.333},
                                                           {0.666, 0, 0.333, 0.333},
                                                           {0, 0.333, 0.333, 0.333},
                                                           {0.333, 0.333, 0.333, 0.333},
                                                           {0.666, 0.333, 0.333, 0.333},
                                                           {0, 0.666, 0.333, 0.333},
                                                           {0.333, 0.666, 0.333, 0.333},
                                                           {0.666, 0.666, 0.333, 0.333},
                                                           {0.8, 0, 0.2, 0.17}
                                                       } };
            mode = SVC_LAYOUT_MODE_NUMBER;
            break;

        default:
            break;
        }
    }
}

//[3x3]: not full screen.
void SVCLayoutManager::prepareSVC3x3LayoutDetail() {
    qDebug("[%s][%d]", __func__, __LINE__);

    for (SVCLayoutModeType mode = SVC_LAYOUT_MODE_1X1; mode < SVC_LAYOUT_MODE_NUMBER ; ) {
        switch (mode) {
        case SVC_LAYOUT_MODE_1X1:
            gSvcLayoutDetail[mode] =  {1, true, {
                                                                 {0, 0.085, 1.0, 0.83},
                                                                 {0.8, 0, 0.2, 0.17}}}; //local video view
            mode = SVC_LAYOUT_MODE_1X2;
            break;
        case SVC_LAYOUT_MODE_1X2:
            gSvcLayoutDetail[mode] = {2, true, {
                                                                 {0, 0.2925, 0.5, 0.415},
                                                                 {0.5, 0.2925, 0.5, 0.415},
                                                                 {0.8, 0, 0.2, 0.17}} }; //local video view
            mode = SVC_LAYOUT_MODE_1X3;
            break;

        case SVC_LAYOUT_MODE_1X3:
            gSvcLayoutDetail[mode]=  {3, true, {
                                                                 {0.25, 0.085, 0.5, 0.415},
                                                                 {0, 0.5, 0.5, 0.415},
                                                                 {0.5, 0.5, 0.5, 0.415},
                                                                 {0.8, 0, 0.2, 0.17}}}; //local video view
            mode = SVC_LAYOUT_MODE_1X4;
            break;

        case SVC_LAYOUT_MODE_1X4:
            gSvcLayoutDetail[mode] =  {4, true, {
                                                                 {0, 0.085, 0.5, 0.415},
                                                                 {0.5, 0.085, 0.5, 0.415},
                                                                 {0, 0.5, 0.5, 0.415},
                                                                 {0.5, 0.5, 0.5, 0.415},
                                                                 {0.8, 0, 0.2, 0.17}} }; //local video view
            mode = SVC_LAYOUT_MODE_1X5;
            break;

        case SVC_LAYOUT_MODE_1X5:
            gSvcLayoutDetail[mode] =  {4, true, {
                                                                    {0, 0.085, 0.333, 0.2767},
                                                                    {0.333, 0.085, 0.333, 0.2767},
                                                                    {0.666, 0.085, 0.333, 0.2767},
                                                                    {0.0, 0.3617, 0.333, 0.2767},
                                                                    {0.333, 0.3617, 0.333, 0.2767},
                                                                    {0.8, 0, 0.2, 0.17} //local video view
                                                                } };
            mode = SVC_LAYOUT_MODE_1X6;
            break;

        case SVC_LAYOUT_MODE_1X6:
            gSvcLayoutDetail[mode] =  {4, true, {
                                                                    {0, 0.085, 0.333, 0.2767},
                                                                    {0.333, 0.085, 0.333, 0.2767},
                                                                    {0.666, 0.085, 0.333, 0.2767},
                                                                    {0.0, 0.3617, 0.333, 0.2767},
                                                                    {0.333, 0.3617, 0.333, 0.2767},
                                                                    {0.666, 0.3617, 0.333, 0.2767},
                                                                    {0.8, 0, 0.2, 0.17} //local video view
                                                                } };
            mode = SVC_LAYOUT_MODE_1X7;
            break;

        case SVC_LAYOUT_MODE_1X7:
            gSvcLayoutDetail[mode] =  {4, true, {
                                                                    {0, 0.085, 0.333, 0.2767},
                                                                    {0.333, 0.085, 0.333, 0.2767},
                                                                    {0.666, 0.085, 0.333, 0.2767},
                                                                    {0.0, 0.3617, 0.333, 0.2767},
                                                                    {0.333, 0.3617, 0.333, 0.2767},
                                                                    {0.666, 0.3617, 0.333, 0.2767},
                                                                    {0.0, 0.6384, 0.333, 0.2767},

                                                                    {0.8, 0, 0.2, 0.17} //local video view
                                                                } };
            mode = SVC_LAYOUT_MODE_1X8;
            break;

        case SVC_LAYOUT_MODE_1X8:
            gSvcLayoutDetail[mode] =  {4, true, {
                                                                    {0, 0.085, 0.333, 0.2767},
                                                                    {0.333, 0.085, 0.333, 0.2767},
                                                                    {0.666, 0.085, 0.333, 0.2767},
                                                                    {0.0, 0.3617, 0.333, 0.2767},
                                                                    {0.333, 0.3617, 0.333, 0.2767},
                                                                    {0.666, 0.3617, 0.333, 0.2767},
                                                                    {0.0, 0.6384, 0.333, 0.2767},
                                                                    {0.333, 0.6384, 0.333, 0.2767},
                                                                    {0.8, 0, 0.2, 0.17} //local video view
                                                                } };
            mode = SVC_LAYOUT_MODE_1X9;
            break;

        case SVC_LAYOUT_MODE_1X9:
            gSvcLayoutDetail[mode] =  {4, true, {
                                                                    {0, 0.085, 0.333, 0.2767},
                                                                    {0.333, 0.085, 0.333, 0.2767},
                                                                    {0.666, 0.085, 0.333, 0.2767},
                                                                    {0.0, 0.3617, 0.333, 0.2767},
                                                                    {0.333, 0.3617, 0.333, 0.2767},
                                                                    {0.666, 0.3617, 0.333, 0.2767},
                                                                    {0.0, 0.6384, 0.333, 0.2767},
                                                                    {0.333, 0.6384, 0.333, 0.2767},
                                                                    {0.666, 0.6384, 0.333, 0.2767},
                                                                    {0.8, 0, 0.2, 0.17} //local video view
                                                                } };
            mode = SVC_LAYOUT_MODE_NUMBER;
            break;

        default:
            break;
        }
    }
}

//[1x5]: 1.remote: sharing content; 2.lecture mode.
void SVCLayoutManager::prepareSVCLayoutDetail() {

    for (SVCLayoutModeType mode = SVC_LAYOUT_MODE_1X1; mode < SVC_LAYOUT_MODE_NUMBER; ) {
        switch (mode) {
        case SVC_LAYOUT_MODE_1X1:
            gSvcLayoutDetail[mode] =  {1, true,
                                                       {{0, 0.17, 1.0, 0.83},
                                                        {0.4, 0, 0.2, 0.17}}};
            mode = SVC_LAYOUT_MODE_1X2;
            break;

        case SVC_LAYOUT_MODE_1X2:
            gSvcLayoutDetail[mode] =  {2, true,
                                                       {{0, 0.17, 1.0, 0.83},
                                                        {0.3, 0, 0.2, 0.17},
                                                        {0.5, 0, 0.2, 0.17}} };
            mode = SVC_LAYOUT_MODE_1X3;
            break;

        case SVC_LAYOUT_MODE_1X3:
            gSvcLayoutDetail[mode] =  {3, true,
                                                       {{0, 0.17, 1.0, 0.83},
                                                        {0.2, 0, 0.2, 0.17},
                                                        {0.4, 0, 0.2, 0.17},
                                                        {0.6, 0, 0.2, 0.17}}};
            mode = SVC_LAYOUT_MODE_1X4;
            break;

        case SVC_LAYOUT_MODE_1X4:
            gSvcLayoutDetail[mode] =  {4, true,
                                                       {{0, 0.17, 1.0, 0.83},
                                                        {0.1, 0, 0.2, 0.17},
                                                        {0.3, 0, 0.2, 0.17},
                                                        {0.5, 0, 0.2, 0.17},
                                                        {0.7, 0, 0.2, 0.17}} };
            mode = SVC_LAYOUT_MODE_1X5;
            break;

        case SVC_LAYOUT_MODE_1X5:
            gSvcLayoutDetail[mode] =  {4, true,
                                                       {{0, 0.17, 1.0, 0.83},
                                                           {0.0, 0, 0.2, 0.17},
                                                           {0.2, 0, 0.2, 0.17},
                                                           {0.4, 0, 0.2, 0.17},
                                                           {0.6, 0, 0.2, 0.17},
                                                           {0.8, 0, 0.2, 0.17}
                                                       } };
            mode = SVC_LAYOUT_MODE_NUMBER;
            break;

        default:
            break;
        }
    }
}

#else
//macOS, UOS.
void SVCLayoutManager::prepareSVCFullScreen3x3LayoutDetail() {

    for (SVCLayoutModeType mode = SVC_LAYOUT_MODE_1X1; mode < SVC_LAYOUT_MODE_NUMBER ; ) {
        switch (mode) {
        case SVC_LAYOUT_MODE_1X1:

            gSvcLayoutDetail[mode] = (SVCLayoutDetail) {1, true,
                                                       {{0, 0, 1.0, 1.0},
                                                        {0.8, 0, 0.2, 0.17}}};

            //                static const SVCLayoutDetail defaultLayout = {
            //                                                .videoViewNum = 1,
            //                                                .isSymmetical = true,
            //                                                .videoViewDescription = {{0, 0, 1.0, 1.0}, {0.8, 0, 0.2, 0.17}}
            //                                            };

            mode = SVC_LAYOUT_MODE_1X2;
            break;

        case SVC_LAYOUT_MODE_1X2:
            gSvcLayoutDetail[mode] = (SVCLayoutDetail) {2, true,
                                                       {{0, 0.25, 0.5, 0.5},
                                                        {0.5, 0.25, 0.5, 0.5},
                                                        {0.8, 0, 0.2, 0.17}} };
            mode = SVC_LAYOUT_MODE_1X3;
            break;

        case SVC_LAYOUT_MODE_1X3:
            gSvcLayoutDetail[mode]=(SVCLayoutDetail) {3, true,
                                                       {{0.25, 0, 0.5, 0.5},
                                                        {0, 0.5, 0.5, 0.5},
                                                        {0.5, 0.5, 0.5, 0.5},
                                                        {0.8, 0, 0.2, 0.17}}};
            mode = SVC_LAYOUT_MODE_1X4;
            break;

        case SVC_LAYOUT_MODE_1X4:
            gSvcLayoutDetail[mode] = (SVCLayoutDetail) {4, true,
                                                       {{0, 0, 0.5, 0.5},
                                                        {0.5, 0, 0.5, 0.5},
                                                        {0, 0.5, 0.5, 0.5},
                                                        {0.5, 0.5, 0.5, 0.5},
                                                        {0.8, 0, 0.2, 0.17}} };
            mode = SVC_LAYOUT_MODE_1X5;
            break;

        case SVC_LAYOUT_MODE_1X5:
            gSvcLayoutDetail[mode] = (SVCLayoutDetail) {4, true,
                                                       {{0, 0, 0.333, 0.333},
                                                           {0.333, 0, 0.333, 0.333},
                                                           {0.666, 0, 0.333, 0.333},
                                                           {0, 0.333, 0.333, 0.333},
                                                           {0.333, 0.333, 0.333, 0.333},
                                                           {0.8, 0, 0.2, 0.17}
                                                       } };
            mode = SVC_LAYOUT_MODE_1X6;
            break;

        case SVC_LAYOUT_MODE_1X6:
            gSvcLayoutDetail[mode] = (SVCLayoutDetail) {4, true,
                                                       {{0, 0, 0.333, 0.333},
                                                           {0.333, 0, 0.333, 0.333},
                                                           {0.666, 0, 0.333, 0.333},
                                                           {0, 0.333, 0.333, 0.333},
                                                           {0.333, 0.333, 0.333, 0.333},
                                                           {0.666, 0.333, 0.333, 0.333},
                                                           {0.8, 0, 0.2, 0.17}
                                                       } };
            mode = SVC_LAYOUT_MODE_1X7;
            break;

        case SVC_LAYOUT_MODE_1X7:
            gSvcLayoutDetail[mode] = (SVCLayoutDetail) {4, true,
                                                       {{0, 0, 0.333, 0.333},
                                                           {0.333, 0, 0.333, 0.333},
                                                           {0.666, 0, 0.336, 0.336},
                                                           {0, 0.333, 0.336, 0.336},
                                                           {0.336, 0.333, 0.333, 0.333},
                                                           {0.666, 0.333, 0.333, 0.333},
                                                           {0, 0.666, 0.333, 0.333},

                                                           {0.8, 0, 0.2, 0.17}
                                                       } };
            mode = SVC_LAYOUT_MODE_1X8;
            break;

        case SVC_LAYOUT_MODE_1X8:
            gSvcLayoutDetail[mode] = (SVCLayoutDetail) {4, true,
                                                       {{0, 0, 0.333, 0.333},
                                                           {0.333, 0, 0.333, 0.333},
                                                           {0.666, 0, 0.333, 0.333},
                                                           {0, 0.333, 0.333, 0.333},
                                                           {0.333, 0.333, 0.333, 0.333},
                                                           {0.666, 0.333, 0.333, 0.333},
                                                           {0, 0.666, 0.333, 0.333},
                                                           {0.333, 0.666, 0.333, 0.333},
                                                           {0.8, 0, 0.2, 0.17}
                                                       } };
            mode = SVC_LAYOUT_MODE_1X9;
            break;

        case SVC_LAYOUT_MODE_1X9:
            gSvcLayoutDetail[mode] = (SVCLayoutDetail) {4, true,
                                                       {{0, 0, 0.333, 0.333},
                                                           {0.333, 0, 0.333, 0.333},
                                                           {0.666, 0, 0.333, 0.333},
                                                           {0, 0.333, 0.333, 0.333},
                                                           {0.333, 0.333, 0.333, 0.333},
                                                           {0.666, 0.333, 0.333, 0.333},
                                                           {0, 0.666, 0.333, 0.333},
                                                           {0.333, 0.666, 0.333, 0.333},
                                                           {0.666, 0.666, 0.333, 0.333},
                                                           {0.8, 0, 0.2, 0.17}
                                                       } };
            mode = SVC_LAYOUT_MODE_NUMBER;
            break;

        default:
            break;
        }
    }
}

//[3x3]: not full screen.
void SVCLayoutManager::prepareSVC3x3LayoutDetail() {
    qDebug("[%s][%d]", __func__, __LINE__);

    for (SVCLayoutModeType mode = SVC_LAYOUT_MODE_1X1; mode < SVC_LAYOUT_MODE_NUMBER ; ) {
        switch (mode) {
            case SVC_LAYOUT_MODE_1X1:
                gSvcLayoutDetail[mode] = (SVCLayoutDetail) {1, true, {
                    {0, 0.085, 1.0, 0.83},
                    {0.8, 0, 0.2, 0.17}}}; //local video view
                mode = SVC_LAYOUT_MODE_1X2;
                break;
            case SVC_LAYOUT_MODE_1X2:
                gSvcLayoutDetail[mode] = (SVCLayoutDetail) {2, true, {
                    {0, 0.2925, 0.5, 0.415},
                    {0.5, 0.2925, 0.5, 0.415},
                    {0.8, 0, 0.2, 0.17}} }; //local video view
                mode = SVC_LAYOUT_MODE_1X3;
                break;
           
            case SVC_LAYOUT_MODE_1X3:
                gSvcLayoutDetail[mode]=(SVCLayoutDetail) {3, true, {
                    {0.25, 0.085, 0.5, 0.415},
                    {0, 0.5, 0.5, 0.415},
                    {0.5, 0.5, 0.5, 0.415},
                    {0.8, 0, 0.2, 0.17}}}; //local video view
                mode = SVC_LAYOUT_MODE_1X4;
                break;
            
            case SVC_LAYOUT_MODE_1X4:
                gSvcLayoutDetail[mode] = (SVCLayoutDetail) {4, true, {
                    {0, 0.085, 0.5, 0.415},
                    {0.5, 0.085, 0.5, 0.415},
                    {0, 0.5, 0.5, 0.415},
                    {0.5, 0.5, 0.5, 0.415},
                    {0.8, 0, 0.2, 0.17}} }; //local video view
                mode = SVC_LAYOUT_MODE_1X5;
                break;
                
            case SVC_LAYOUT_MODE_1X5:
                gSvcLayoutDetail[mode] = (SVCLayoutDetail) {4, true, {
                    {0, 0.085, 0.333, 0.2767},
                    {0.333, 0.085, 0.333, 0.2767},
                    {0.666, 0.085, 0.333, 0.2767},
                    {0.0, 0.3617, 0.333, 0.2767},
                    {0.333, 0.3617, 0.333, 0.2767},
                    {0.8, 0, 0.2, 0.17} //local video view
                } };
                mode = SVC_LAYOUT_MODE_1X6;
                break;
                
            case SVC_LAYOUT_MODE_1X6:
                gSvcLayoutDetail[mode] = (SVCLayoutDetail) {4, true, {
                    {0, 0.085, 0.333, 0.2767},
                    {0.333, 0.085, 0.333, 0.2767},
                    {0.666, 0.085, 0.333, 0.2767},
                    {0.0, 0.3617, 0.333, 0.2767},
                    {0.333, 0.3617, 0.333, 0.2767},
                    {0.666, 0.3617, 0.333, 0.2767},
                    {0.8, 0, 0.2, 0.17} //local video view
                } };
                mode = SVC_LAYOUT_MODE_1X7;
                break;
                
            case SVC_LAYOUT_MODE_1X7:
                gSvcLayoutDetail[mode] = (SVCLayoutDetail) {4, true, {
                    {0, 0.085, 0.333, 0.2767},
                    {0.333, 0.085, 0.333, 0.2767},
                    {0.666, 0.085, 0.333, 0.2767},
                    {0.0, 0.3617, 0.333, 0.2767},
                    {0.333, 0.3617, 0.333, 0.2767},
                    {0.666, 0.3617, 0.333, 0.2767},
                    {0.0, 0.6384, 0.333, 0.2767},
                    
                    {0.8, 0, 0.2, 0.17} //local video view
                } };
                mode = SVC_LAYOUT_MODE_1X8;
                break;
                
            case SVC_LAYOUT_MODE_1X8:
                gSvcLayoutDetail[mode] = (SVCLayoutDetail) {4, true, {
                    {0, 0.085, 0.333, 0.2767},
                    {0.333, 0.085, 0.333, 0.2767},
                    {0.666, 0.085, 0.333, 0.2767},
                    {0.0, 0.3617, 0.333, 0.2767},
                    {0.333, 0.3617, 0.333, 0.2767},
                    {0.666, 0.3617, 0.333, 0.2767},
                    {0.0, 0.6384, 0.333, 0.2767},
                    {0.333, 0.6384, 0.333, 0.2767},
                    {0.8, 0, 0.2, 0.17} //local video view
                } };
                mode = SVC_LAYOUT_MODE_1X9;
                break;
                
            case SVC_LAYOUT_MODE_1X9:
                gSvcLayoutDetail[mode] = (SVCLayoutDetail) {4, true, {
                    {0, 0.085, 0.333, 0.2767},
                    {0.333, 0.085, 0.333, 0.2767},
                    {0.666, 0.085, 0.333, 0.2767},
                    {0.0, 0.3617, 0.333, 0.2767},
                    {0.333, 0.3617, 0.333, 0.2767},
                    {0.666, 0.3617, 0.333, 0.2767},
                    {0.0, 0.6384, 0.333, 0.2767},
                    {0.333, 0.6384, 0.333, 0.2767},
                    {0.666, 0.6384, 0.333, 0.2767},
                    {0.8, 0, 0.2, 0.17} //local video view
                } };
                mode = SVC_LAYOUT_MODE_NUMBER;
                break;
       
            default:
                break;
        }
    }
}

//[1x5]: 1.remote: sharing content; 2.lecture mode.
void SVCLayoutManager::prepareSVCLayoutDetail() {
    
    for (SVCLayoutModeType mode = SVC_LAYOUT_MODE_1X1; mode < SVC_LAYOUT_MODE_NUMBER; ) {
        switch (mode) {
            case SVC_LAYOUT_MODE_1X1:
                gSvcLayoutDetail[mode] = (SVCLayoutDetail) {1, true,
                    {{0, 0.17, 1.0, 0.83},
                    {0.4, 0, 0.2, 0.17}}};
                mode = SVC_LAYOUT_MODE_1X2;
                break;
                
            case SVC_LAYOUT_MODE_1X2:
                gSvcLayoutDetail[mode] = (SVCLayoutDetail) {2, true,
                    {{0, 0.17, 1.0, 0.83},
                    {0.3, 0, 0.2, 0.17},
                    {0.5, 0, 0.2, 0.17}} };
                mode = SVC_LAYOUT_MODE_1X3;
                break;
           
            case SVC_LAYOUT_MODE_1X3:
                gSvcLayoutDetail[mode] = (SVCLayoutDetail) {3, true,
                    {{0, 0.17, 1.0, 0.83},
                    {0.2, 0, 0.2, 0.17},
                    {0.4, 0, 0.2, 0.17},
                    {0.6, 0, 0.2, 0.17}}};
                mode = SVC_LAYOUT_MODE_1X4;
                break;
            
            case SVC_LAYOUT_MODE_1X4:
                gSvcLayoutDetail[mode] = (SVCLayoutDetail) {4, true,
                    {{0, 0.17, 1.0, 0.83},
                    {0.1, 0, 0.2, 0.17},
                    {0.3, 0, 0.2, 0.17},
                    {0.5, 0, 0.2, 0.17},
                    {0.7, 0, 0.2, 0.17}} };
                mode = SVC_LAYOUT_MODE_1X5;
                break;
                
            case SVC_LAYOUT_MODE_1X5:
                gSvcLayoutDetail[mode] = (SVCLayoutDetail) {4, true,
                    {{0, 0.17, 1.0, 0.83},
                    {0.0, 0, 0.2, 0.17},
                    {0.2, 0, 0.2, 0.17},
                    {0.4, 0, 0.2, 0.17},
                    {0.6, 0, 0.2, 0.17},
                    {0.8, 0, 0.2, 0.17}
                } };
                mode = SVC_LAYOUT_MODE_NUMBER;
                break;
            
            default:
                break;
        }
    }
}
#endif

//==================================================
// for sending gSvcLayoutDetail to FMeetingViewController.qml -> SVCLayout.qml.
//==================================================
//[Qt]:
void SVCLayoutManager::sendDataToQMLPrepareSVCLayout(std::string aSVCLayoutType) {
    QString svcLayoutType = QString::fromStdString(aSVCLayoutType);
    qDebug("[%s][%d]: emit signalPrepareSVCLayout(svcLayoutType: %s)", Q_FUNC_INFO, __LINE__, qPrintable(svcLayoutType));

    QJsonObject Obj;
    Obj.insert("svcLayoutType", svcLayoutType);
    QVariant varValue = QVariant::fromValue(Obj);
    emit signalPrepareSVCLayout(varValue);
}


//==================================================
// for class SVCLayoutManager
//==================================================

QMutex SVCLayoutManager::m_Mutex;
SVCLayoutManager * SVCLayoutManager::shareInstance = nullptr;

SVCLayoutManager* SVCLayoutManager::getInstance() {
    if (nullptr == shareInstance) {
        QMutexLocker mutexLocker(&m_Mutex);
        shareInstance = new SVCLayoutManager();
    }
    return shareInstance;
}

void SVCLayoutManager::releaseInstance() {
    qDebug("[%s][%d] Enter", Q_FUNC_INFO, __LINE__);
    if (nullptr != shareInstance) {
        QMutexLocker mutexLocker(&m_Mutex);
        delete shareInstance;
        shareInstance = nullptr;
    }
    qDebug("[%s][%d] Exit", Q_FUNC_INFO, __LINE__);
}


SVCLayoutManager::SVCLayoutManager(QObject *parent) : QObject(parent) {
    qDebug("[%s][%d]", Q_FUNC_INFO, __LINE__);

    this->m_svcLayoutMode = SVC_LAYOUT_MODE_1X1;
    
    this->m_svcVideoList = new QList<SVCVideoInfo *>;
    
    
    //prepareSVCLayoutDetail();
    //sendDataToQMLPrepareSVCLayout("prepareSVCLayoutDetail");
}

SVCLayoutManager::~SVCLayoutManager() {
    qDebug("[%s][%d]", Q_FUNC_INFO, __LINE__);
}

void SVCLayoutManager::changeLayout2FullScreen3x3() {
    this->m_gridModeLayout = true;
    prepareSVCFullScreen3x3LayoutDetail();
    //sendDataToQMLPrepareSVCLayout("prepareSVCFullScreen3x3LayoutDetail");
}

void SVCLayoutManager::changeLayout2ExitScreen3x3() {
    qDebug("[%s][%d]", Q_FUNC_INFO, __LINE__);

    this->m_gridModeLayout = true;
    prepareSVC3x3LayoutDetail();
    //sendDataToQMLPrepareSVCLayout("prepareSVC3x3LayoutDetail");
}

void SVCLayoutManager::changeLayout2Tranditional() {
    this->m_gridModeLayout = false;
    prepareSVCLayoutDetail();
    //sendDataToQMLPrepareSVCLayout("prepareSVCLayoutDetail");
}

void SVCLayoutManager::figureOutLayoutMode_phone() {
    int svcVideoCount = this->m_svcVideoList->size();

    if (svcVideoCount == 2) {
        m_svcLayoutMode = SVC_LAYOUT_MODE_1X1;
    } else if (svcVideoCount == 3) {
        m_svcLayoutMode = SVC_LAYOUT_MODE_1X2;
    } else if (svcVideoCount == 4) {
        m_svcLayoutMode = SVC_LAYOUT_MODE_1X3;
    } else if (svcVideoCount == 5) {
        m_svcLayoutMode = SVC_LAYOUT_MODE_1X4;
    } else if (svcVideoCount == 6) {
        m_svcLayoutMode = SVC_LAYOUT_MODE_1X5;
    } else if (svcVideoCount == 7) {
        m_svcLayoutMode = SVC_LAYOUT_MODE_1X6;
    } else if (svcVideoCount == 8) {
        m_svcLayoutMode = SVC_LAYOUT_MODE_1X7;
    } else if (svcVideoCount == 9) {
        m_svcLayoutMode = SVC_LAYOUT_MODE_1X8;
    } else if (svcVideoCount == 10) {
        m_svcLayoutMode = SVC_LAYOUT_MODE_1X9;
    }
    //qDebug("[%s][%d]: svcVideoCount : %d, m_svcLayoutMode : %d", Q_FUNC_INFO, __LINE__, svcVideoCount, m_svcLayoutMode);
}

QString SVCLayoutManager::videoType(VideoType type) {
    if (type == VIDEO_TYPE_REMOTE) {
        return "VIDEO_TYPE_REMOTE";
    } else if (type == VIDEO_TYPE_LOCAL) {
        return "VIDEO_TYPE_LOCAL";
    } else if (type == VIDEO_TYPE_CONTENT) {
        return "VIDEO_TYPE_CONTENT";
    } else {
        return "VIDEO_TYPE_INVALID";
    }
}

void SVCLayoutManager::clearRemoteUserInfo() {
    //qDeleteAll(m_svcVideoList->begin(), m_svcVideoList->end());
    m_svcVideoList->clear();
}

void SVCLayoutManager::showSVCVideoInfoArray(QString strMsg, QList<SVCVideoInfo *> *videoLayoutInfo) {
    qDebug("--[%s][%d]: --- --- --- %s:", Q_FUNC_INFO, __LINE__, qPrintable(strMsg));
    qDebug("--[%s][%d]: --- --- --- QList of SVCVideoInfo size: %d", Q_FUNC_INFO, __LINE__, videoLayoutInfo->size());

    int i = 0;
    for (QList<SVCVideoInfo *>::iterator iter = videoLayoutInfo->begin(); iter != videoLayoutInfo->end(); ++iter) {
        SVCVideoInfo *item = (SVCVideoInfo *)*iter;
        QString qStrDisplayName = QString::fromLocal8Bit(item->strDisplayName.c_str());
        QString qStrDataSourceID = QString::fromStdString(item->dataSourceID);
        QString qStrUUID = QString::fromStdString(item->strUUID);
        qDebug("--[%s][%d]: ------------------------- [%d] -----------------------", Q_FUNC_INFO, __LINE__, i++);
        qDebug("--[%s][%d]: | uuid: %s", Q_FUNC_INFO, __LINE__, qPrintable(qStrUUID));
        qDebug("--[%s][%d]: | strDisplayName: %s", Q_FUNC_INFO, __LINE__,  qPrintable(qStrDisplayName));
        qDebug("--[%s][%d]: | eVideoType: %d", Q_FUNC_INFO, __LINE__, item->eVideoType);
        qDebug("--[%s][%d]: | dataSourceID: %s", Q_FUNC_INFO, __LINE__, qPrintable(qStrDataSourceID));
        qDebug("--[%s][%d]: | resolution_width: %d, resolution_height: %d.", Q_FUNC_INFO, __LINE__, item->resolution_width, item->resolution_height);
        qDebug("--[%s][%d]: | removed: %s", Q_FUNC_INFO, __LINE__, (item->removed)? "true" : "false");
        qDebug("--[%s][%d]: | active: %s", Q_FUNC_INFO, __LINE__, (item->active)? "true" : "false");
        qDebug("--[%s][%d]: | maxResolution: %s", Q_FUNC_INFO, __LINE__, (item->maxResolution)? "true" : "false");
        qDebug("--[%s][%d]: | pin: %s", Q_FUNC_INFO, __LINE__, (item->pin)? "true" : "false");
        qDebug("--[%s][%d]: ------------------------------------------------", Q_FUNC_INFO, __LINE__);
    }
}

void SVCLayoutManager::svcRefreshLayoutList(QList<SVCVideoInfo *> *videoLayoutInfo) {
    std::vector<int> removeArray;

    for (int j = this->m_svcVideoList->size() - 1; j >= 0; --j) {
        SVCVideoInfo *videoInfo = m_svcVideoList->at(j);

        bool bFind = false;
        for (int i = 0; i < videoLayoutInfo->size(); ++i) {
            SVCVideoInfo * videoParam = (SVCVideoInfo *)videoLayoutInfo->at(i);
            if (0 == videoParam->dataSourceID.compare(videoInfo->dataSourceID)) {
                videoInfo->strUUID               = videoParam->strUUID;
                videoInfo->strDisplayName        = videoParam->strDisplayName.c_str();

                videoInfo->resolution_height     = videoParam->resolution_height;
                videoInfo->resolution_width      = videoParam->resolution_width;
                videoInfo->removed               = false;
                videoInfo->active                = videoParam->isActive();
                videoInfo->maxResolution         = videoParam->isMaxResolution();
                videoInfo->pin                   = videoParam->pin;
                bFind = true;
                break;
            }
        }
        
        if (false == bFind) {
            videoInfo->removed = true;
            removeArray.push_back(j);
        }
    }

    if (0 == m_svcVideoList->size()) {
        for (QList<SVCVideoInfo *>::iterator iter = videoLayoutInfo->begin(); iter != videoLayoutInfo->end(); ++iter) {
            SVCVideoInfo *videoParam = (SVCVideoInfo *)*iter;
            m_svcVideoList->push_back(videoParam);
        }
    }

    // add video which not in videoInfoList
    for (int i = 0; i < videoLayoutInfo->size(); ++i) {
        bool bFind = false;
        SVCVideoInfo * videoParam = (SVCVideoInfo *)videoLayoutInfo->at(i);
        for (int j = 0; j < m_svcVideoList->size(); ++j) {
            SVCVideoInfo *videoInfo = m_svcVideoList->at(j);
            if (0 == videoInfo->dataSourceID.compare(videoParam->dataSourceID)) {
                bFind = true;
                videoInfo->active = videoParam->isActive();
                break;
            }
        }

        QString qStrDisplayName     = QString::fromLocal8Bit(videoParam->strDisplayName.c_str());
        QString qStrDataSourceID    = QString::fromStdString(videoParam->dataSourceID);
        QString qStrUUID            = QString::fromStdString(videoParam->strUUID);

        if (!bFind) {
            SVCVideoInfo *newVideoInfo = new SVCVideoInfo();
            newVideoInfo->strUUID            = videoParam->strUUID;
            newVideoInfo->strDisplayName     = videoParam->strDisplayName;
            newVideoInfo->eVideoType         = videoParam->eVideoType;
            newVideoInfo->dataSourceID       = videoParam->dataSourceID;
            newVideoInfo->resolution_width   = videoParam->resolution_width;
            newVideoInfo->resolution_height  = videoParam->resolution_height;
            newVideoInfo->removed            = videoParam->isRemoved();
            newVideoInfo->active             = videoParam->isActive();
            newVideoInfo->maxResolution      = videoParam->maxResolution;
            newVideoInfo->pin                = videoParam->pin;

            if (0 == removeArray.size()) {
                m_svcVideoList->push_back(newVideoInfo);
            } else {
                m_svcVideoList->replace(removeArray.at(0), newVideoInfo);
                std::vector<int>::iterator itr = removeArray.begin();
                removeArray.erase(itr); // [removeArray removeObjectAtIndex:0];
            }
        }
    }


    for (std::vector<int>::size_type i = 0; i < removeArray.size(); ++i) {
	    int removeVideoIndex = (int)removeArray.at(i);

        SVCVideoInfo *videoInfo = m_svcVideoList->at(removeVideoIndex);
        QString qStrDataSourceID = QString::fromStdString(videoInfo->dataSourceID);

        m_svcVideoList->removeAt((int)removeArray.at(i));
    }

    removeArray.clear(); //[removeArray removeAllObjects];

    for (std::vector<int>::size_type i = 0; i < removeArray.size(); ++i) {
        int removeVideoIndex = (int)removeArray.at(i);

        SVCVideoInfo *videoInfo = m_svcVideoList->at(removeVideoIndex);
        QString qStrDataSourceID = QString::fromStdString(videoInfo->dataSourceID);

        m_svcVideoList->removeAt((int)removeArray.at(i));
    }

    for (int i = 0; i < m_svcVideoList->size(); ++i) {
        SVCVideoInfo * tempVideoInfo = (SVCVideoInfo *)m_svcVideoList->at(i);
        if (i == 0 && tempVideoInfo->eVideoType == VIDEO_TYPE_CONTENT) {
            break;
        }
        if (tempVideoInfo->eVideoType == VIDEO_TYPE_CONTENT) {
            SVCVideoInfo * videoInfo = (SVCVideoInfo *)m_svcVideoList->at(0);
            m_svcVideoList->replace(0, tempVideoInfo);
            m_svcVideoList->replace(i, videoInfo);
            break;
        }
    }

    for (int i = 0; i < m_svcVideoList->size(); ++i) {
        SVCVideoInfo * tempVideoInfo = (SVCVideoInfo *)m_svcVideoList->at(i);
        if ((i == m_svcVideoList->size() - 1) && tempVideoInfo->eVideoType == VIDEO_TYPE_LOCAL) {
            break;
        }
        if (tempVideoInfo->eVideoType == VIDEO_TYPE_LOCAL) {
            SVCVideoInfo * videoInfo = m_svcVideoList->at(m_svcVideoList->size() - 1);
            m_svcVideoList->replace(i, videoInfo);
            m_svcVideoList->replace(m_svcVideoList->size() - 1, tempVideoInfo);
            break;
        }
    }

    this->figureOutLayoutMode_phone();
    

     
    for (int i = 0; i < m_svcVideoList->size(); ++i) {
        if (this->isGridModeLayout()) {
            break;
        }

        SVCVideoInfo * tempVideoInfo = (SVCVideoInfo *)m_svcVideoList->at(i);
        if (i == 0 && tempVideoInfo->eVideoType == VIDEO_TYPE_CONTENT) {
            break;
        }

        if (i == 0 && (tempVideoInfo->isActive() == true || tempVideoInfo->isMaxResolution() == true)) {
            if (tempVideoInfo->isMaxResolution() == true) {
            } else {
                break;
            }
        }

        if (tempVideoInfo->isActive() || tempVideoInfo->isMaxResolution()) {
            SVCVideoInfo * videoInfo = m_svcVideoList->at(0);
            m_svcVideoList->replace(0, tempVideoInfo);
            m_svcVideoList->replace(i, videoInfo);
            if (tempVideoInfo->isActive()) {
                break;
            }
        }
    }

    for (int i = 0; i < m_svcVideoList->size(); ++i) {
        SVCVideoInfo * tempVideoInfo = (SVCVideoInfo *)m_svcVideoList->at(i);

        if (i == 0 && tempVideoInfo->eVideoType == VIDEO_TYPE_CONTENT) {
            for (int j = 1; j < m_svcVideoList->size(); ++j) {
                SVCVideoInfo * tempVideoInfo = (SVCVideoInfo *)m_svcVideoList->at(j);
                if (j == 1 && tempVideoInfo->isPin()) {
                    break;
                }

                if (tempVideoInfo->isPin()) {
                    SVCVideoInfo * videoInfo = m_svcVideoList->at(1);
                    m_svcVideoList->replace(1, tempVideoInfo);
                    m_svcVideoList->replace(j, videoInfo);
                    break;
                }
            }
            break;
        }

        if (i == 0 && tempVideoInfo->isPin()) {
            break;
        }

        if (tempVideoInfo->isPin()) {
            SVCVideoInfo * videoInfo = m_svcVideoList->at(0);
            m_svcVideoList->replace(0, tempVideoInfo);
            m_svcVideoList->replace(i, videoInfo);
            break;
        }
    }

    this->refreshLayoutMode(this->m_svcLayoutMode, this->m_svcVideoList);
}


void SVCLayoutManager::refreshLayoutMode(SVCLayoutModeType mode, QList<SVCVideoInfo *> * viewArray) {
    SVCLayoutDetail detail = gSvcLayoutDetail[mode];
    QJsonObject Obj;
    Obj.insert("videoViewNum", detail.videoViewNum);
    Obj.insert("isSymmetical", detail.isSymmetical);

    int nStrArray = mode + 1;
    QJsonArray rowJsonArray;
    for (int i = 0; i <= nStrArray; ++i) {
        QJsonArray columnJsonArray;

        for (int j = 0; j < 4; ++j) {
            float value = detail.videoViewDescription[i][j];
            QString str = QString::number(value , 'f', 3);
            columnJsonArray.append(str);
        }

        rowJsonArray.append(columnJsonArray);
    }

    Obj.insert("videoViewDescription", rowJsonArray);
    

    int index = 0;
    QJsonArray videoViewJsonArray;
    for (QList<SVCVideoInfo *>::iterator iter = m_svcVideoList->begin(); iter != m_svcVideoList->end(); ++iter) {
        SVCVideoInfo *item = (SVCVideoInfo *)*iter;

        QString qStrDisplayName = QString::fromLocal8Bit(item->strDisplayName.c_str());
        QString qStrDataSourceID = QString::fromStdString(item->dataSourceID);
        QString qStrUUID = QString::fromStdString(item->strUUID);

        QJsonObject Obj;
        Obj.insert("strUUID", qStrUUID);
        Obj.insert("strDisplayName", qStrDisplayName);
        Obj.insert("eVideoType", (int)item->eVideoType);
        Obj.insert("dataSourceID", qStrDataSourceID);
        Obj.insert("resolution_width", item->resolution_width);
        Obj.insert("resolution_height", item->resolution_height);
        Obj.insert("removed", item->isRemoved());
        Obj.insert("active", item->isActive());
        Obj.insert("maxResolution", item->isMaxResolution());
        Obj.insert("pin", item->isPin());

        videoViewJsonArray.append(Obj);
    }
    Obj.insert("viewArray", videoViewJsonArray);
    
    QVariant varValue = QVariant::fromValue(Obj);
    emit signalRefreshLayoutMode(mode, varValue);
}
}
