//
//  VideoDataConvertor.h
//  class VideoDataConvertor.
//  frtc_sdk Qt version.
//
//  Created by Yingyong.Mao on 2022/09/27.
//  Copyright © 2022 毛英勇. All rights reserved.
//

#ifndef VIDEODATACONVERTOR_H
#define VIDEODATACONVERTOR_H

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
//#include <unistd.h>
//#include <sys/ioctl.h>
#include <string.h>
#include <errno.h>
//#include <sys/mman.h>
//#include <sys/select.h>
//#include <sys/time.h>
//#include <linux/videodev2.h>
#include <stdbool.h>
#include <string>

class VideoDataConvertor
{
public:
    VideoDataConvertor();

    static void yuv_to_rgb(unsigned char *yuv, unsigned char *rgb, int i32Height, int i32Width) {
        unsigned int i;
        unsigned char* y0 = yuv + 0;
        unsigned char* u0 = yuv + 1;
        unsigned char* y1 = yuv + 2;
        unsigned char* v0 = yuv + 3;

        unsigned  char* r0 = rgb + 0;
        unsigned  char* g0 = rgb + 1;
        unsigned  char* b0 = rgb + 2;
        unsigned  char* r1 = rgb + 3;
        unsigned  char* g1 = rgb + 4;
        unsigned  char* b1 = rgb + 5;

        float rt0 = 0, gt0 = 0, bt0 = 0, rt1 = 0, gt1 = 0, bt1 = 0;

        for (i = 0; i <= (i32Width * i32Height) / 2; ++i) {
            bt0 = 1.164 * (*y0 - 16) + 2.018 * (*u0 - 128);
            gt0 = 1.164 * (*y0 - 16) - 0.813 * (*v0 - 128) - 0.394 * (*u0 - 128);
            rt0 = 1.164 * (*y0 - 16) + 1.596 * (*v0 - 128);

            bt1 = 1.164 * (*y1 - 16) + 2.018 * (*u0 - 128);
            gt1 = 1.164 * (*y1 - 16) - 0.813 * (*v0 - 128) - 0.394 * (*u0 - 128);
            rt1 = 1.164 * (*y1 - 16) + 1.596 * (*v0 - 128);

            if (rt0 > 250)      rt0 = 255;
            if (rt0< 0)        rt0 = 0;

            if (gt0 > 250)     gt0 = 255;
            if (gt0 < 0)    gt0 = 0;

            if (bt0 > 250)    bt0 = 255;
            if (bt0 < 0)    bt0 = 0;

            if (rt1 > 250)    rt1 = 255;
            if (rt1 < 0)    rt1 = 0;

            if (gt1 > 250)    gt1 = 255;
            if (gt1 < 0)    gt1 = 0;

            if (bt1 > 250)    bt1 = 255;
            if (bt1 < 0)    bt1 = 0;

            *r0 = (unsigned char)rt0;
            *g0 = (unsigned char)gt0;
            *b0 = (unsigned char)bt0;

            *r1 = (unsigned char)rt1;
            *g1 = (unsigned char)gt1;
            *b1 = (unsigned char)bt1;

            yuv = yuv + 4;
            rgb = rgb + 6;

            if (yuv == nullptr)
                break;

            y0 = yuv;
            u0 = yuv + 1;
            y1 = yuv + 2;
            v0 = yuv + 3;

            r0 = rgb + 0;
            g0 = rgb + 1;
            b0 = rgb + 2;
            r1 = rgb + 3;
            g1 = rgb + 4;
            b1 = rgb + 5;
        }
    }

    static int yuyv_to_yuv420P(unsigned char yuv422[], unsigned char yuv420[], int width, int height) {
        int ynum = width * height;
        int i, j, k = 0;

        //get Y data.
        for (i = 0; i < ynum; ++i) {
           yuv420[i] = yuv422[i * 2];
        }

        //get U.
        for (i = 0; i < height; ++i) {
            if ((i%2)!=0)continue;
            for (j = 0; j < (width/2); ++j) {
                if ((4 * j + 1) > (2 * width))
                    break;
                yuv420[ ynum + k * 2 * width / 4 + j] = yuv422[i * 2 * width + 4 * j + 1];
            }
            ++k;
        }

        k=0;

        //get V.
        for (i = 0; i < height; ++i) {
            if ((i%2) == 0)
                continue;
            for (j = 0; j < (width/2); ++j) {
                if ((4*j+3) > (2*width))
                    break;
                yuv420[ynum + ynum / 4 + k * 2 * width / 4 + j] = yuv422[i * 2 * width + 4 * j + 3];
            }
            k++;
        }
        return 1;
    }

    //mac used.
    static void _NV12_TO_I420(unsigned char *src_plane1,
                              int src_stride1,
                              unsigned char *src_plane2,
                              int src_stride2,
                              int width,
                              int height,
                              unsigned char *dest,
                              int /*NOT_USED*/) {

        unsigned char *y = dest, *u = dest +  width * height, *v = dest +  width * height * 5 / 4;
        // set default stride
        if (src_stride1 == 0) {
            src_stride1 = width;
        }
        if (src_stride2 == 0) {
            src_stride2 = width;
        }
        // deduce 2nd plane
        if (src_plane2 == nullptr) {
            src_plane2 = src_plane1 + src_stride1 * height;
        }
        // copy y plane
        for (int i = 0; i < height; ++i) {
            memcpy(y, src_plane1, width);
            src_plane1 +=  src_stride1;
            y += width;
        }
        //copy uv plane
        for (int i = 0; i < height / 2; ++i) {
            for (int j = 0; j < width / 2; ++j) {
                u[j] = src_plane2 [ j * 2   ];
                v[j] = src_plane2 [ j * 2 + 1 ];
            }
            u += width / 2;
            v += width / 2;
            src_plane2 += src_stride2; // next row
        }
    }

    //image_src is the source image, image_dst is the converted image
    static void NV12_YUV420P(const unsigned char* image_src,
                             unsigned char* image_dst,
                             int image_width,
                             int image_height) {

        unsigned char* p = image_dst;
        memcpy(p, image_src, image_width * image_height * 3 / 2);
        const unsigned char* pNV = image_src + image_width * image_height;
        unsigned char* pU = p + image_width * image_height;
        unsigned char* pV = p + image_width * image_height + ((image_width * image_height)>>2);

        for (int i=0; i<(image_width * image_height)/2; ++i) {
            if ((i%2)==0) *pU++ = *(pNV + i);
            else *pV++ = *(pNV + i);
        }
    }

    /**
     * NV12属于YUV420SP格式
     * @param data
     * @param rgb
     * @param width
     * @param height
     */
/**
    static void NV12_TO_RGB24(unsigned char *data, unsigned char *rgb, int width, int height) {
        int index = 0;
        unsigned char *ybase = data;
        unsigned char *ubase = &data[width * height];
        for (int y = 0; y < height; ++y) {
            for (int x = 0; x < width; ++x) {
                //YYYYYYYYUVUV
                u_char Y = ybase[x + y * width];
                u_char U = ubase[y / 2 * width + (x / 2) * 2];
                u_char V = ubase[y / 2 * width + (x / 2) * 2 + 1];
                rgb[index++] = Y + 1.402 * (V - 128); //R
                rgb[index++] = Y - 0.34413 * (U - 128) - 0.71414 * (V - 128); //G
                rgb[index++] = Y + 1.772 * (U - 128); //B
            }
        }
    }
*/
    /**
     * NV12 belongs to YUV420SP format, the default format of android camera
     * @param data
     * @param rgb
     * @param width
     * @param height
     */
    static void NV21_TO_RGB24(unsigned char *yuyv, unsigned char *rgb, int width, int height) {
        const int nv_start = width * height;
        int index = 0, rgb_index = 0;
        uint8_t y, u, v;
        int r, g, b, nv_index = 0,i, j;

        for (i = 0; i <height; ++i) {
            for (j = 0; j <width; ++j) {
                //nv_index = (rgb_index/2-width/2 * ((i + 1)/2)) * 2;
                nv_index = i/2 * width + j-j% 2;

                y = yuyv[rgb_index];
                u = yuyv[nv_start + nv_index ];
                v = yuyv[nv_start + nv_index + 1];

                r = y + (140 * (v-128))/100;//r
                g = y-(34 * (u-128))/100-(71 * (v-128))/100;//g
                b = y + (177 * (u-128))/100;//b

                if (r> 255) r = 255;
                if (g> 255) g = 255;
                if (b> 255) b = 255;
                if (r <0) r = 0;
                if (g <0) g = 0;
                if (b <0) b = 0;

                index = rgb_index% width + (height-i-1) * width;
                //rgb[index * 3+0] = b;
                //rgb[index * 3+1] = g;
                //rgb[index * 3+2] = r;

                //Invert the image
                //rgb[height * width * 3-i * width * 3-3 * j-1] = b;
                //rgb[height * width * 3-i * width * 3-3 * j-2] = g;
                //rgb[height * width * 3-i * width * 3-3 * j-3] = r;

                //Front image
                rgb[i * width * 3 + 3 * j + 0] = b;
                rgb[i * width * 3 + 3 * j + 1] = g;
                rgb[i * width * 3 + 3 * j + 2] = r;

                rgb_index++;
            }
        }
    }


    /*yuv格式转换为rgb格式*/
    static int convert_yuv_to_rgb_pixel(int y, int u, int v) {
        unsigned int pixel32 = 0;
        unsigned char *pixel = (unsigned char *)&pixel32;
        int r, g, b;
        r = y + (1.370705 * (v-128));
        g = y - (0.698001 * (v-128)) - (0.337633 * (u-128));
        b = y + (1.732446 * (u-128));
        if (r > 255) r = 255;
        if (g > 255) g = 255;
        if (b > 255) b = 255;
        if (r < 0) r = 0;
        if (g < 0) g = 0;
        if (b < 0) b = 0;
        pixel[0] = r * 220 / 256;
        pixel[1] = g * 220 / 256;
        pixel[2] = b * 220 / 256;
        return pixel32;
    }

    static int convert_yuv_to_rgb_buffer(unsigned char *yuv, unsigned char *rgb, unsigned int width, unsigned int height) {
        unsigned int in, out = 0;
        unsigned int pixel_16;
        unsigned char pixel_24[3];
        unsigned int pixel32;
        int y0, u, y1, v;
        for (in = 0; in < width * height * 2; in += 4) {
            pixel_16 =
            yuv[in + 3] << 24 |
            yuv[in + 2] << 16 |
            yuv[in + 1] <<  8 |
            yuv[in + 0];
            y0 = (pixel_16 & 0x000000ff);
            u  = (pixel_16 & 0x0000ff00) >>  8;
            y1 = (pixel_16 & 0x00ff0000) >> 16;
            v  = (pixel_16 & 0xff000000) >> 24;

            pixel32 = convert_yuv_to_rgb_pixel(y0, u, v);
            pixel_24[0] = (pixel32 & 0x000000ff);
            pixel_24[1] = (pixel32 & 0x0000ff00) >> 8;
            pixel_24[2] = (pixel32 & 0x00ff0000) >> 16;
            rgb[out++] = pixel_24[0];
            rgb[out++] = pixel_24[1];
            rgb[out++] = pixel_24[2];

            pixel32 = convert_yuv_to_rgb_pixel(y1, u, v);
            pixel_24[0] = (pixel32 & 0x000000ff);
            pixel_24[1] = (pixel32 & 0x0000ff00) >> 8;
            pixel_24[2] = (pixel32 & 0x00ff0000) >> 16;
            rgb[out++] = pixel_24[0];
            rgb[out++] = pixel_24[1];
            rgb[out++] = pixel_24[2];
        }
        return 0;
    }
};

#endif // VIDEODATACONVERTOR_H
