import QtQuick 2.12

UnitPropItem {
    id: tU
    width: 70
    height: 350
    property alias tank: tank
    property alias mouseArea : msAr
    allovAlarmBodyBlinck: false


    //++++++++ Test +++++++
    //        mouseArea.onPressAndHold: {
    //            linked = true
    //            connected = true
    //            allovAlarmBodyBlinck = true
    //            setQuitAlarm()
    //            var cl = tank.mainGradientColor
    //            cl = backgroundCurrentColor
    //        }
    //    // ------ Test ------
    MouseArea {
        id: msAr
        anchors.fill: parent
        acceptedButtons: Qt.RightButton | Qt.LeftButton
        onClicked: {
            if (mouse.button & Qt.RightButton) {
                openSettings()
            }
            if (mouse.button & Qt.LeftButton) {
                setNotified()
                setAlarmNotified()
            }
        }
        hoverEnabled: true
        onEntered: tooltip.visible = tooltipText != ""
        onExited: tooltip.visible = false
    }
    Tank {
        id: tank
        objectName: "tank"
        anchors.fill: parent
        mainGradientColor: backgroundCurrentColor
        borderWidth: borderCurrentWidth
        borderColor: borderCurrentColor
        nameText.text: name
    }
}
