import QtQuick 2.15
import "fap.js" as Fap

StartStopUnit {
    id: contItem
    width: 40
    height: width
    property alias perstWin: regPersWin
    property alias freq: regPersWin.value
    property alias reqMaxRange: regPersWin.valueMax
    property alias freqMinRange: regPersWin.valueMin
    property bool  hrzOrPrst: false
    property alias title: title.text

    function setMinRange(value) {
        regPersWin.setValueMinRange( value )
    }
    function setMaxRange(value) {
        regPersWin.setValueMaxRange( value )
    }
    function setFreq(value) {
        regPersWin.setValue(value)
    }
    function setFreqLive(value) {
        freq.text = value.toFixed(0)+ "%"
    }
    signal s_moreLtl( variant MoreLtl )
    signal s_lessLtl( variant LessLtl )
    signal s_freqChanged( variant ValvePos )

    Rectangle {
        id: regVal
        anchors.fill: parent
        border.color: borderCurrentColor
        border.width: borderCurrentWidth
        color: backgroundCurrentColor
        Text{
            id: title
            text: "ЧП"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: parent.height/2 - 1
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            minimumPointSize: 3
            anchors.rightMargin: 1
            anchors.leftMargin: 1
            anchors.topMargin: 1
            font.pointSize: 300
            fontSizeMode: Text.Fit
        }
        Text{
            id: freq
            width: 40
            text: "99%"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: title.bottom
            anchors.bottom: parent.bottom
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.bottomMargin: 1
            minimumPointSize: 3
            anchors.rightMargin: 1
            anchors.leftMargin: 1
            anchors.topMargin: 1
            font.pointSize: 300
            fontSizeMode: Text.Fit
        }
    }
    RegPersentWin {
        id: regPersWin
        onValueChanged: freq = value
        title: name
        sepCorBtn: false
        readOnly: false
        onS_moreVal: s_moreLtl( More )
        onS_lessVal: s_lessLtl( Less )
        onS_valueChenged: s_freqChanged( Value )
        mainColor: "#09aad4"
        scaleColor: "#1a6b14"
        mfuCurValue.mantissa: 1
        upLimit: hrzOrPrst ? 50 : 100
        unitOfmeg: hrzOrPrst ? "Гц" : "%"
    }

    mouseArea.onClicked: {
        if (mouse.button & Qt.LeftButton) {
            regPersWin.show()
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorZoom:4}D{i:3}
}
##^##*/

