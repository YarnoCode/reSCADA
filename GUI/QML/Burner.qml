import QtQuick 2.12
import "fap.js" as Fap

UnitPropItem {
    id: root
    width: 40
    height: 60

    allovAlarmBodyBlinck: false
    borderWidthNotify: 6
    function setState( Disabled){}

    MouseArea {
        id: mousAr
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
}

/*##^##
Designer {
    D{i:0;formeditorZoom:1.1}D{i:1;locked:true}
}
##^##*/
