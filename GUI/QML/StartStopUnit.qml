import QtQuick 2.15
import "fap.js" as Fap

UnitPropItem {
    id: contItem
    width: 20
    height: width
    property alias mouseArea: mouseArea
    property color colorRun: Fap.run
    property color colorStopReady: Fap.ready
    property color colorManual: Fap.manual
    property color colorStartCommand: "Lime"
    property color colorStopCommand: "Lime"
    property bool st: false
    property bool std: false
    property bool manual: false
    backgroundColor: colorStopReady

    signal s_start()
    signal s_stop()


    function started() {
        st = true
        std = true
        manual = false
        backgroundColor = colorRun
        //console.log("started +", Date.now().toString())
    }
    function stoped() {
        //stopComand()
        st = false
        std = false
        manual = false
        backgroundColor = colorStopReady
        //console.log("stoped -", Date.now().toString())
    }
    function startComand() {
        st = true
        manual = false
        backgroundColor = "Lime"
        //console.log("startComand -+", Date.now().toString())
    }
    function stopComand() {
        st = false
        manual = false
        backgroundColor = "Lime"
        //console.log("stopComand  +-", Date.now().toString())
    }
    function manualWork() {
        st = false
        manual = true
        backgroundColor = colorManual
        //console.log("manualWork 0", Date.now().toString())
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent

        acceptedButtons: Qt.RightButton | Qt.LeftButton
        onClicked: {
            if (mouse.button & Qt.RightButton) {
                openSettings()
            }
            else if (mouse.button & Qt.LeftButton) {
                notify = false
                alarmNotify = false
            }
        }
        onDoubleClicked: {
            if(st || std){
                s_stop()
                //stoped() //for test
            }
            else{
                s_start()
                //setAlarmNotify()//for test
                //started() //for test
            }
        }
        hoverEnabled: true
        onEntered: tooltip.visible = tooltipText != ""
        onExited: tooltip.visible = false
    }
}

/*##^##
Designer {
    D{i:0;formeditorZoom:1.75}
}
##^##*/

