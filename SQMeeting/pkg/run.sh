#!/bin/sh 
set -x
appname=`basename $0 | sed s,\.sh$,,` 
echo "appname: " $appname
dirname=`dirname $0` 
tmp="${dirname#?}" 
echo "dirname: " $dirname
if [ "${dirname%$tmp}" != "/" ]; then 
dirname=$PWD/$dirname 
echo "dirname: " $dirname
fi 

export QT_DEBUG_PLUGINS=1

echo "========== ========== ========== =========="
echo "|   set for run in different path...       "
echo "========== ========== ========== =========="

SELF=$(readlink -f "$0")
HERE=${SELF%/*}

export PATH="${HERE}/xdg-utils:$PATH"
export PATH="${HERE}:$PATH"
#export PATH="${HERE}"
export LD_LIBRARY_PATH="${HERE}/lib"
export QT_PLUGIN_PATH="${HERE}/plugin"

export QML2_IMPORT_PATH="${HERE}/qml"
export QMLSCENE_DEVICE=""

echo "HERE path: " $HERE
echo "PATH path: " $PATH
echo "LD_LIBRARY_PATH path: " $LD_LIBRARY_PATH
echo "QT_PLUGIN_PATH path: " $QT_PLUGIN_PATH
echo "qml path: " $QML2_IMPORT_PATH

#if ! command -v xdg-open > /dev/null 2>&1; then
 #   echo "Error: xdg-open is not available in PATH. Please check xdg-utils installation."
  #  exit 1
#fi

#exec SQMeeting $*
exec SQMeeting "$@"

#export QML2_IMPORT_PATH=./qml
#echo "qml path: " $QML2_IMPORT_PATH
 
# LD_LIBRARY_PATH=$dirname 
#export LD_LIBRARY_PATH 
#echo "libs path: " $LD_LIBRARY_PATH

#echo "app path: " $dirname/$appname
# $dirname/$appname "$@"
