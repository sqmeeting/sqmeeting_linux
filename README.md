# SQMeeting Linux客户端

# 系统要求

## 操作系统
支持统信UOS v20 desktop，麒麟V10 desktop, Debian 10，Debian 11  
其他Linux发行版，也可能支持，需要测试

支持x86-64和arm64 CPU架构.

## GCC和QT版本

SQMeeting Linux使用GCC 11 或者以上版本和Qt6.8进行编译

# 编译生成和运行

## 编译工具
CMake 3.16或更高版本

## 生成
1. 编译安装Qt6.8，请参照Qt官方指引[Build Qt](https://wiki.qt.io/Get_the_Source)   
   需要编译安装ffmpeg, 才能enable qt6的multi-media plugin.  
2. 安装portaudio, libasound，libpulse, liblog4cplus  
   sudo apt install portaudio19-dev libasound2-dev libpulse-dev liblog4cplus-dev
4. 进入项目根目录  
   cd SQMeeting/  
   编辑CMakeLists.txt, 指向上面qt6的安装目录.    
   mkdir build  
   cd build  
   cmake ..  
   make   //运行成功会生成SQMeeting 可执行文件

## 运行
   拷贝 SQMeeting/dist/uos/lib/*.so 到qt6/lib/  
   拷贝 ffmpeg libs 到qt6/lib/  
   拷贝 上面生成的SQMeeting 和 pkg/run.sh 到 qt6/   
   cd qt6/;  
   ./run.sh 

# License
本项目基于 [Apache License, Version 2.0](./LICENSE) 开源，请在开源协议约束范围内使用源代码。  
本项目代码仅用于学习和研究使用。 任何使用本代码产生的后果，我们不承担任何法律责任。  
请联系我们获取商业支持.