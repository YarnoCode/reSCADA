import QtQuick 2.15
import QtQuick.Window 2.15

UnitPropItem {
    id: contItem
    width: 40
    height: width
    property alias mFUnit: mFUnit
    property alias regValve: regVal
    property alias valvePosition: regVal.position
    property alias valveMaxRange: mangWin.valueMax
    property alias valveMinRange: mangWin.valueMin
    property bool confmOnEnter: false
    backgroundColor: "black"

    function setMinRange(value) {
        mangWin.setValueMinRange( value )
    }
    function setMaxRange(value) {
        mangWin.setValueMaxRange( value )
    }
    function setTargetPos(value) {
        mangWin.setValue( value )
    }
    function setPos(value) {
        regVal.position = value
    }
    function setOpenLtl( value ){
        openLtl.visible = value
    }
    function setCloseLtl( value ){
        closeLtl.visible = value
    }
    signal s_openLtl( variant OpenLtl )
    signal s_closeLtl( variant CloseLtl )
    signal s_setMaxRange( variant Range )
    signal s_setMinRange( variant Range )
    signal s_setTargetPos( variant ValvePos )

    RegulValve {
        id: regVal
        anchors.fill: parent
        borderColor: borderCurrentColor
        backgroundColor: backgroundCurrentColor
        borderWidth: borderCurrentWidth
        nameText.text: title
        //position: mangWin.value
    }
    RegPersentWin {
        id: mangWin
        levelText: "УСТАВКА ПОЛОЖЕНИЯ %"
        onValueChanged: {
            mFUnit.valueReal = value
        }
        onS_valueChenged: s_setTargetPos(Value)
        mfuCurValue.mantissa: 2
    }
    MFUnit{
        id: mFUnit
        width: 90
        height: 25
        anchors.top: parent.bottom
        anchors.topMargin: 0
        anchors.horizontalCenter: parent.horizontalCenter
        backgroundColor: parent.backgroundColor
        textInput.color: regVal.substanceColor
        maxBtn.nameText.color: regVal.substanceColor
        minBtn.nameText.color: regVal.substanceColor
        disappear: true
        valueReal: mangWin.value
        upLimit: mangWin.valueMax
        downLimit: mangWin.valueMin
        mantissa: 2
        limited: true
        onValueChanged: /*if(! separCorrButtons)*/s_setTargetPos(Value)
        onS_more: s_openLtl( More )
        onS_less: s_closeLtl( Less )
        separCorrButtons: true
        confmOnEnter: parent.confmOnEnter
        property int _prtOldZ: parent.z
        //Component.onCompleted: _prtOldZ = parent.z
        body.onVisibleChanged: {
            if( body.visible ){
                _prtOldZ = parent.z
                parent.z = 100
            }
            else parent.z = _prtOldZ
        }
    }

    MouseArea {
        anchors.fill: regVal
        acceptedButtons: Qt.RightButton | Qt.LeftButton
        onClicked: {
            if (mouse.button & Qt.RightButton) {
                openSettings()
            } else if (mouse.button & Qt.LeftButton) {
                mangWin.title = name
                mangWin.show()
            }

        }
        hoverEnabled: true
        onEntered: tooltip.visible = tooltipText != ""
        onExited: tooltip.visible = false
    }

    Rectangle {
        id: openLtl
        radius: width * 0.5
        border.color: "#000000"
        width: parent.width / 5
        height: width
        visible: false
        color: "#ffffff"

        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset:  parent.height / 4

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: - parent.width / 4
    }
    Rectangle {
        id: closeLtl
        radius: width * 0.5
        border.color: "#ffffff"
        width: parent.width / 5
        height: width
        visible: false
        color: "#000000"
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset:  parent.height / 4

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: parent.width / 4
    }
}




/*##^##
Designer {
    D{i:0;formeditorZoom:6}
}
##^##*/
