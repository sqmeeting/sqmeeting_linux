import QtQuick

ListView {

    id: listView

    property bool headerVisible: false
    property bool footerVisible: false
    property bool headerHold: false
    property bool footerHold: false

    enum MoveDirection{
        NoMove,
        UpToDown,
        DownToUp
    }
    property int moveDirection: PullListView.NoMove
    property real moveStartContentY: 0

    onHeaderVisibleChanged: if(!headerVisible) {headerHold = false}
    onFooterVisibleChanged: if(!footerVisible) {footerHold = false}
    onContentYChanged: {
        if(dragging || flicking)
        {
            moveDirection = (contentY - moveStartContentY < 0) ? PullListView.UpToDown : PullListView.DownToUp
            switch(moveDirection){
            case PullListView.UpToDown:{
                if(atYBeginning && !headerVisible && !footerVisible) {
                    headerVisible = true
                }
            }break;
            case PullListView.DownToUp:{
                if(atYEnd && !headerVisible && !footerVisible) {
                    footerVisible = true
                }
            }break;
            default:break;
            }
        }
    }

    //鼠标或手指拖动驱动的界面滚动
    onDraggingChanged: dragging ? pullStart() : pullEnd()
    //鼠标滚动驱动的view滚动
    onFlickingChanged: flicking ? pullStart() : pullEnd()

    function pullStart(){
        moveStartContentY = contentY
    }

    function pullEnd(){

        //console.log("pullEnd:",atYBeginning,moveDirection,headerVisible,contentY - moveStartContentY)

        switch(moveDirection){
        case PullListView.UpToDown:{
            if(atYBeginning && headerVisible) {
                headerHold = true
            }else if(null !== headerItem){
                headerVisible = false
                headerHold = false
            }

        }break;
        case PullListView.DownToUp:{
            if(atYEnd && footerVisible) {
                footerHold = true
            }else if(null !== footerItem){
                footerVisible = false
                footerHold = false
            }
        }break;
        default:break;
        }

        moveDirection = PullListView.NoMove
    }
}

