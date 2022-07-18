import QtQuick 2.15
import "fap.js" as Fap

StartStopUnit {
    id: fan
    width: 300
    height: 400
    visible: true
    property alias fanName: fanName
    property bool mirror: false
    property int rotatePict: 0
    property alias textX: fanName.x
    property alias textY: fanName.y
    property int flanWidth: 5

//    onStChanged: canvas.requestPaint()
//    onStdChanged: canvas.requestPaint()
//    onManualChanged: canvas.requestPaint()
    onBorderCurrentWidthChanged: canvas.requestPaint()
    onBorderCurrentColorChanged: canvas.requestPaint()
    onBackgroundCurrentColorChanged:canvas.requestPaint()

    Canvas {
        id: canvas
        rotation: rotatePict
        visible: parent.visible
        anchors.fill: parent
        transform: Scale {
            origin.x: width / 2
            xScale: mirror ? -1 : 1
            yScale: 1
        }
        onPaint: {
            //Пряоугольник
            var context = getContext("2d")
            context.clearRect(0, 0, width, height)
            context.strokeStyle = borderCurrentColor
            context.fillStyle = backgroundCurrentColor
            context.lineWidth = borderCurrentWidth * 2
            context.beginPath()
            context.moveTo(width - flanWidth + borderCurrentWidth, borderCurrentWidth)
            context.lineTo(width - flanWidth + borderCurrentWidth, height - width / 2)
            context.lineTo(width - borderCurrentWidth, height - width / 2)
            context.lineTo(width - borderCurrentWidth, borderCurrentWidth)
            context.closePath()
            context.stroke()
            context.fill()
            //Круг
            context.beginPath()
            context.arc(width / 2, height - width / 2, width / 2 - borderCurrentWidth, 0, 2 * Math.PI)
            context.stroke()
            context.fill()
        }
    }
    Text {
        id: fanName
        text: name
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pointSize: 7
        visible: parent.visible
        wrapMode: Text.Wrap
        anchors.topMargin: parent.height - parent.width
        anchors.bottomMargin: 0
        anchors.leftMargin: 0
        anchors.rightMargin: 0
    }
    //    MouseArea {
//        anchors.fill: parent
//        acceptedButtons: Qt.RightButton | Qt.LeftButton
//        onClicked: {
//            alarmNotify = false;
//            if (mouse.button & Qt.RightButton) {
//                openSettings()
//            }
//                        else if(mouse.modifiers & Qt.ShiftModifier){
//                            addToCurrentRoteStoped()
//                        }
//                        else if(mouse.modifiers & Qt.ControlModifier){
//                            addToCurrentRoteStarted()
//                        }
//        }
//    }
}

/*##^##
Designer {
    D{i:0;formeditorZoom:1.1;height:55;width:56}
}
##^##*/
