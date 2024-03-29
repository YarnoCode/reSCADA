﻿import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQml.Models 2.15
import "fap.js" as Fap

Window {
    id: wind
    visible: false
    color: Fap.menuBackground
    width: 300
    height: windowContent.height

    flags: Qt.Window | Qt.Dialog
    title: winTitle
    minimumWidth: 200
    maximumHeight: 600
    property string winTitle: ""
    property int rowSize: 20

    //        Component.onCompleted: {
    ////            addAlarm("qwe", "qweqwe", true)
    ////            addAlarm("asd", "asdasd", false)
    //            addEngRow("zxc")
    //            addEngRow("rty")
    //        }

    signal s_resetAlarm()

    function addAlarm(objname, symname, ignorable) {
        alarms.insert(alarms.index, propertyAlarm.createObject(alarms))
        alarms.get(alarms.index).objectName = objname
        alarms.get(alarms.index).alarmName = symname
        alarms.get(alarms.index).checkable = ignorable
        alarms.index++
        return alarms.get(alarms.index - 1)
    }

    function addEngRow(objname) {
        engSignals.insert(engSignals.index,
                          propertyEngRow.createObject(engSignals))
        engSignals.get(engSignals.index).objectName = objname
        engSignals.index++
        return engSignals.get(engSignals.index - 1)
    }
    function alarmSet() {
        areaAlarm.alarm = true
    }
    function alarmReseted() {
        areaAlarm.alarm = false
        areaAlarm.alarmNotify = false
    }
    function setQuitAlarm() {
        alarmSet()
        areaAlarm.alarmNotify = true
    }

    onVisibleChanged: {
        if (!visible) {
            areaHidden.hidden = true
            wind.height = windowContent.height
            for (var i = 0; i < engSignals.index; i++) {
                var engrow = engSignals.get(i)
                for (var j = 0; j < engrow.engModel.index; j++) {
                    var engrowrow = engrow.engModel.get(j)
                    if (engrowrow.settingName !== undefined) {
                        engrowrow.commit()
                    }
                }
            }
        } else {
            areaHidden.hidden = false
        }
    }
    Component {
        id: propertyAlarm
        CheckBox {
            width: parent == undefined ? 0 : parent.width
            height: rowSize
            indicator.width: indicatorSize
            indicator.height: indicatorSize
            checkable: true
            text: alarmName
            background: Rectangle {
                id: rectBkgrd
            }
            property int indicatorSize: 16
            property string alarmName: "Unknown alarm"
            property color colorAlarm: Fap.alarm
            property color colorNormal: Fap.menuBackground

            signal changedIgnore(bool status)
            function changeIgnore(status) {
                checkState = status ? Qt.Checked : Qt.Unchecked
            }
            function setConnected(status) {
                text = alarmName + (status ? "" : " (Нет связи)")
            }
            function setAlarm() {
                rectBkgrd.color = colorAlarm
            }
            function alarmReseted() {
                rectBkgrd.color = colorNormal
            }

            onCheckStateChanged: changedIgnore(checkState == Qt.Checked)

            onCheckableChanged: {
                if (!checkable) {
                    indicator.width = 0
                    indicator.height = 0
                }
            }
        }
    }
    Component {
        id: propertyEngRow
        Rectangle {
            id: rectBkgrd
            width: parent == undefined ? 0 : parent.width
            height: rowSize
            color: colorNormal
            //            anchors.leftMargin: 5
            //            anchors.topMargin: 1
            //Отображение аварии
            property string alarmName: "Unknown alarm"
            property color colorAlarm: Fap.alarm
            property color colorNormal: Fap.menuBackground

            function setAlarm() {
                rectBkgrd.color = colorAlarm
            }
            function alarmReseted() {
                rectBkgrd.color = colorNormal
            }

            property real ratio: 0.1
            property alias engModel: engmodel
            signal sendProperty(int property, variant value)
            function addPropertySignal(objname, symname) {
                engmodel.insert(engmodel.index,
                                propertySignal.createObject(engmodel))
                engmodel.get(engmodel.index).objectName = objname
                engmodel.get(engmodel.index).sigName = symname
                engmodel.index++
                return engmodel.get(engmodel.index - 1)
            }
            function addPropertyValue(objname, symname) {
                engmodel.insert(engmodel.index,
                                propertyValue.createObject(engmodel))
                engmodel.get(engmodel.index).objectName = objname
                engmodel.get(engmodel.index).sigName = symname
                engmodel.index++
                return engmodel.get(engmodel.index - 1)
            }
            function addPropertySetting(objname, symname, tr) {
                engmodel.insert(engmodel.index,
                                propertySetting.createObject(engmodel))
                engmodel.get(engmodel.index).objectName = objname
                engmodel.get(engmodel.index).settingName = symname
                engmodel.get(engmodel.index).reversed = tr > 0 ? true : false
                engmodel.get(engmodel.index).timed = tr >= 0 ? true : false
                engmodel.index++
                return engmodel.get(engmodel.index - 1)
            }
            ObjectModel {
                id: engmodel
                property int index: 0
            }

            Column {
                width: parent == undefined ? 0 : parent.width
                Repeater {
                    model: engmodel
                }
                Component {
                    id: propertySignal
                    Row {
                        property bool val: false
                        property bool connected: false
                        property alias text: vall.text
                        property real ratio: 0.1
                        property int indicatorSize: 16
                        property string sigName: "Unknown signal"
                        width: parent == undefined ? 0 : parent.width
                        height: rowSize
                        signal s_imChanged(bool status)
                        signal s_imValChanged(variant status)
                        function setIm(status) {
                            imit.checked = status ? Qt.Checked : Qt.Unchecked
                        }
                        function setImVal(status) {
                            imitVal.checked = status ? Qt.Checked : Qt.Unchecked
                        }
                        function setVal(status) {
                            val = status ? Qt.Checked : Qt.Unchecked
                        }
                        function setConnected(status) {
                            connected = status
                        }
                        CheckBox {
                            id: imit
                            //                        width: parent.width*parent.ratio
                            width: parent.height
                            height: parent.height
                            indicator.width: parent.indicatorSize
                            indicator.height: parent.indicatorSize
                            onCheckStateChanged: s_imChanged(checkState == Qt.Checked)
                        }
                        CheckBox {
                            id: imitVal
                            //                        width: parent.width*parent.ratio
                            width: parent.height
                            height: parent.height
                            indicator.width: parent.indicatorSize
                            indicator.height: parent.indicatorSize
                            onCheckStateChanged: s_imValChanged(
                                                     checkState == Qt.Checked)
                        }
                        CheckBox {
                            id: vall
                            width: parent.width * (1 - parent.ratio * 2)
                            height: parent.height
                            text: parent.sigName + (parent.connected ? "" : "(Нет связи)")
                            indicator: Rectangle {
                                color: parent.parent.val ? Fap.engTrueSignal : Fap.engFalseSignal
                                height: parent.parent.indicatorSize
                                width: parent.parent.indicatorSize
                                radius: width / 2
                                x: parent.leftPadding / 2
                                y: (parent.height - height) / 2
                                border.color: Fap.buttonsBorder
                            }
                        }
                    }
                }
                Component {
                    id: propertyValue
                    Row {
                        //property real val: 0
                        property bool connected: false
                        property alias text: name.text
                        property real ratio: 0.1
                        property int indicatorSize: 16
                        property string sigName: "Unknown signal"
                        width: parent == undefined ? 0 : parent.width
                        height: rowSize
                        signal s_imChanged(bool ImVal)
                        signal s_imValChanged(variant ImVal)
                        signal s_valChanged(variant Val)
                        function setIm(ImOnOff) {
                            imit.checked = ImOnOff ? Qt.Checked : Qt.Unchecked
                        }
                        function setImVal(ImVal) {
                            imitVal.text = ImVal
                        }
                        function setVal(Val) {
                            vval.text = Val
                        }
                        function setConnected(Contd) {
                            connected = Contd
                        }
                        function commit() {
                            if (imitVal.text === "") {
                                imitVal.text = "0"
                            }
                            setImVal(parseFloat(imitVal.text, 10))
                        }
                        spacing: 1
                        CheckBox {
                            id: imit
                            //                        width: parent.width*parent.ratio
                            width: parent.height
                            height: parent.height
                            indicator.width: parent.indicatorSize
                            indicator.height: parent.indicatorSize
                            onCheckStateChanged: s_imChanged(checkState == Qt.Checked)
                        }

                        TextField {
                            id: imitVal
                            width: parent.width * parent.ratio * 4
                            height: 16
                            anchors.top: parent.top
                            anchors.topMargin: (rowSize - 16) / 2
                            text: "0"
                            visible: imit.checked
                            padding: 1
                            onTextChanged: {
                                text = text.replace(',', '.')
                            }

                            onEditingFinished: parent.s_imValChanged(parseFloat(text,10))
                            Keys.onPressed: {
                                if (event.key === 16777220
                                        || event.key === 16777221) {
                                    //Enter
                                    focus = false
                                }
                            }
                        }
                        TextField {
                            id: vval
                            width: parent.width * parent.ratio * 4
                            height: 16
                            anchors.top: parent.top
                            anchors.topMargin: (rowSize - 16) / 2
                            text: "0"
                            visible: !imit.checked
                            //readOnly: true
                            padding: 1
                            background: Rectangle {
                                anchors.fill: parent
                                radius: 4
                                border.width: 1
                                border.color: "#bdbdbd"
                                color: "white"
                            }

                            onTextChanged: {
                                text = text.replace(',', '.')
                            }

                            onEditingFinished: parent.s_valChanged(parseFloat(text,10))
                            validator: RegExpValidator {
                                regExp: /(-?\d{1,10})([.,]\d{0,10})?$/
                            }
                            Keys.onPressed: {
                                if (event.key === 16777220
                                        || event.key === 16777221) {
                                    //Enter
                                    focus = false
                                }
                            }
                        }
//                        RegExpValidator {
//                            regExp: /(-?\d{1,10})([.,]\d{0,10})?$/
//                        }

                        Text {
                            id: name
                            width: parent.width * parent.ratio * 6
                            height: parent.height
                            text: " " + parent.sigName + (parent.connected ? "" : "(Нет связи)")
                            verticalAlignment: Text.AlignVCenter
                        }

                    }
                }
                Component {
                    id: propertySetting
                    Row {
                        id: root
                        property alias settingName: settingLable.text
                        property alias value: textField.text
                        property real ratio: 0.3
                        property bool timed: false
                        property bool reversed: false
                        width: parent == undefined ? 0 : parent.width
                        height: rowSize
                        signal s_valChanged(variant val)
                        function setVal(val) {
                            //                        if(objectName == ".vsWarning_pulseDelay"){
                            //                           console.log("//------------")
                            //                        }
                            //                        console.log(objectName, val)
                            textField.text = val
                            textFieldNow.value = reversed ? val : 0
                            //                        if (!textFieldNow.timer.running){
                            //                            textFieldNow.stopCountdown()
                            //                        }
                        }
                        function commit() {
                            if (textField.text === "") {
                                textField.text = "0"
                            }
                            setVal(parseFloat(textField.text, 10))
                        }
                        function startCountdown(sec) {
                            textFieldNow.value = reversed ? sec : 0
                            timer.start()
                            //console.log("started", reversed)
                        }
                        function stopCountdown() {
                            textFieldNow.value = reversed ? value : 0
                            timer.stop()
                            //console.log("stopped")
                        }

                        TextField {
                            id: textFieldNow
                            property int value: 0
                            onValueChanged: {
                                let days = ~~(value / 86400)
                                let hours = ~~(value / 3600 % 24)
                                let minutes = ~~(value / 60 % 60)
                                let seconds = ~~(value % 60)

                                textFieldNow.text = (days > 0 ? (days + "д ") : "")
                                        + ((hours + ":")) + ((minutes > 9 ? "" : "0") + (minutes + ":"))
                                        + ((seconds > 9 ? "" : "0") + seconds)
                            }
                            height: 16
                            width: timed ? (parent.width * parent.ratio / 2) : 0
                            anchors.top: parent.top
                            anchors.topMargin: (rowSize - 16) / 2
                            clip: true
                            padding: 1
                            text: "0"
                            //maximumLength: 15
                            enabled: timer.running
                            readOnly: true
                            Timer {
                                id: timer
                                interval: 1000
                                repeat: true
                                onTriggered: {
                                    if ((reversed && textFieldNow.value === 0)
                                            || (!reversed
                                                && textFieldNow.value >= root.value)) {
                                        stopCountdown()
                                    } else {
                                        textFieldNow.value -= reversed ? 1 : -1
                                    }
                                }
                            }
                            //                        MouseArea{
                            //                            anchors.fill: parent
                            //                            onClicked: {
                            //                                startCountdown()
                            //                            }
                            //                        }
                        }
                        TextField {
                            id: textField
                            width: parent.width * parent.ratio / (parent.timed ? 2 : 1)
                            height: 16
                            anchors.top: parent.top
                            anchors.topMargin: (rowSize - 16) / 2
                            text: "0"
                            clip: true
                            padding: 1
                            onTextChanged: {
                                textFieldNow.value = parent.reversed ? text : "0"
                                text = text.replace(',', '.')
                            }
                            onEditingFinished: {
                                parent.s_valChanged(parseFloat(text,10))
                                textFieldNow.value = reversed ? text : 0
                            }
                            validator: RegExpValidator {
                                regExp:/(\d{1,10})([.,]\d{0,10})?$/
                            }
                            Keys.onPressed: {
                                if (event.key === 16777220
                                        || event.key === 16777221) {
                                    //Enter
                                    focus = false
                                }
                            }
                        }
                        Text {
                            id: settingLable
                            height: parent.height
                            width: parent.width * (1 - parent.ratio)
                            verticalAlignment: Text.AlignVCenter
                            text: "Unknown setting"
                            leftPadding: 6
                        }
                    }
                }
            }
            Rectangle {
                width: parent.width
                height: 2
                color: colorNormal//"gray"
                anchors.leftMargin: 5
                anchors.topMargin: 1
            }
        }

    }
    ObjectModel {
        id: alarms
        property int index: 0
    }

    ObjectModel {
        id: engSignals
        property int index: 0
    }
    SimpleButton{
        id:resAlarmBtn
        height: 20
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 2
        anchors.leftMargin: 3
        anchors.rightMargin: 3
        nameText.text: "Сброс аварий"
        onPressedChanged: if(pressed)wind.s_resetAlarm()
    }
    Flickable {
        id: sview
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: resAlarmBtn.bottom
        anchors.bottom: parent.bottom
        anchors.topMargin: 2
        ScrollBar.horizontal: ScrollBar {
            id: hbar
            active: vbar.active
        }
        ScrollBar.vertical: ScrollBar {
            id: vbar
            active: hbar.active
        }
        clip: true
        focus: true
        Keys.onUpPressed: ScrollBar.decrease()
        Keys.onDownPressed: ScrollBar.increase()
        contentWidth: parent.width
        contentHeight: windowContent.height
        Column {
            id: windowContent
            width: parent.width

            Frame {
                id: areaAlarm
                width: parent.width
                height: alarmContent.height + padding * 2
                padding: 4
                property bool alarm: false
                property color alarmColor: Fap.alarm
                property color normalColor: Fap.menuBackground
                background: Rectangle {
                    color: parent.alarm ? parent.alarmColor : parent.normalColor
                }
                Column {
                    id: alarmContent
                    width: parent.width
                    Column {
                        id: alarmBody
                        width: parent.width
                        Repeater {
                            model: alarms
                        }
                    }
                }
            }
            Column {
                id: areaHidden
                property int minimizeHiddenSize: 15
                property bool hidden: true
                width: parent.width
                Frame {
                    id: areaEngineer
                    visible: !parent.hidden
                    width: parent.width
                    height: visible ? (engContent.height + padding * 2) : 0
                    padding: 4
                    Column {
                        id: engContent
                        width: parent.width
                        Row {
                            id: engineerHeader
                            width: parent.width
                            height: 14
                            property int fontSize: 10
                            property real ratio: 0.1
                            Text {
                                id: engineerTitleEmit
                                width: parent.width * parent.ratio
                                height: parent.height
                                text: "Им."
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignTop
                                font.pixelSize: parent.fontSize
                            }
                            Text {
                                id: engineerTitleEmitValue
                                width: parent.width * parent.ratio
                                height: parent.height
                                text: "Им.зн"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignTop
                                font.pixelSize: parent.fontSize
                            }
                            Text {
                                id: engineerTitleValue
                                width: parent.width * (1 - parent.ratio * 2)
                                height: parent.height
                                text: "Значение тега"
                                horizontalAlignment: Text.AlignLeft
                                verticalAlignment: Text.AlignTop
                                font.pixelSize: parent.fontSize
                            }
                        }
                        Column {
                            id: engineerSignals
                            width: parent.width
                            Repeater {
                                model: engSignals
                            }
                        }
                    }
                }
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorZoom:1.33}
}
##^##*/
