import QtQuick 2.12
import QtQuick.Controls 2.15
import "fap.js" as Fap

UnitPropItem {
    id: root
    width: 700
    height: 622

    borderWidth: 0
    borderWidthNotify: 6
    backgroundColor: "transparent"
    allovAlarmBodyBlinck: false

    property alias tank: tankWater

    property int indicWidth: 70
    property int indicHeigth: 30

    property int valveNameSize: 15
    property int pipePassThin: 4
    property color pipePassColor: "white"
    property int pipePassBorderWidth: 1

    property int pipeSteamThin: 5
    property color pipeSteamColor: "white" //element.colorSteam
    property color pipeGasColor: "#a79014"
    property int pipeOutWaterThin: 5
    property int pipeBorderWidth: 1
    property color indicColor: "black"

    property bool adminView: false
    property bool fullView: true

    property bool mirrorVentSmoke: false

    signal s_autoMode(variant AutoMode)
    function setAutoMode(AutoMode){ autoModeBut.checked = AutoMode }

    signal s_start(variant Start)
    function setStart(Start){ startBut.checked = !Start }

    signal s_stop(variant Stop)
    function setStop(Stop){ stopBut.checked = !Stop }

    signal s_alarmStop(variant AlarmStop)
    function setAlarmStop(AlarmStop){ alarmStopBut.checked = !AlarmStop }

    signal s_blowdown(variant Blowdown)
    function setBlowdown(Blowdown){ blowdownBut.checked = !Blowdown }
    function setBlowdownET (BlowdownET){ blowdownBut.etChd(BlowdownET) }
    function setAlarmPGasBV(Alarm){
        if(Alarm) pGasBV.setQuitAlarm("")
        else pGasBV.alarmReseted()
    }
    signal s_germTestStart(variant Start);
    function setGermTestStart(Start){btTestGerm.checked = Start}

    function setState( State ){
        switch (State){
        case 0: boilerState.text = "Стоп"; break;
        case 1: boilerState.text = "Пуск"; break;
        case 2: boilerState.text = "Работа"; break;
        case 3: boilerState.text = "Розжиг"; break;
        case 4: boilerState.text = "Прогрев"; break;
        case 5: boilerState.text = "Охлаждение"; break;
        case 6: boilerState.text = "Продувка"; break;
        case 7: boilerState.text = "Пусковой прогрев"; break;
        case 8: boilerState.text = "Аварийная остановка"; break;
        }
    }

    function setStartStage( StartStage )    {startBut.stateChd( StartStage )}
    function setStartHeatingET( StartHeatin ) {
        let days = ~~(StartHeatin / 86400)
        let hours = ~~(StartHeatin / 3600 % 24)
        let minutes = ~~(StartHeatin / 60 % 60)
        let seconds = ~~(StartHeatin % 60)

        boilerHeating.text = StartHeatin == 0 ? "" : "СТАРТОВЫЙ ПРОГРЕВ"+ "\n" + (
                                                    (days > 0 ? (days + "д ") : "")
                                                    + ((hours + ":")) + ((minutes > 9 ? "" : "0") + (minutes + ":"))
                                                    + ((seconds > 9 ? "" : "0") + seconds)
                                                    )
    }
    function setHeatingET( Heating ){
        let days = ~~(Heating / 86400)
        let hours = ~~(Heating / 3600 % 24)
        let minutes = ~~(Heating / 60 % 60)
        let seconds = ~~(Heating % 60)

        boilerHeating.text = Heating == 0 ? "" :(
                                                (days > 0 ? (days + "д ") : "")
                                                + ((hours + ":")) + ((minutes > 9 ? "" : "0") + (minutes + ":"))
                                                + ((seconds > 9 ? "" : "0") + seconds)
                                                )
    }
    function setCoolingET(Cooling){
        let days = ~~(Cooling / 86400)
        let hours = ~~(Cooling / 3600 % 24)
        let minutes = ~~(Cooling / 60 % 60)
        let seconds = ~~(Cooling % 60)

        boilerColling.text = Cooling == 0 ? "" : (
                                                (days > 0 ? (days + "д ") : "")
                                                + ((hours + ":")) + ((minutes > 9 ? "" : "0") + (minutes + ":"))
                                                + ((seconds > 9 ? "" : "0") + seconds)
                                                )
    }
    function setReqAlarmBtnPress(ReqAlarmBtnPress){ dlgAlarmButtonPress.visible = ReqAlarmBtnPress }
    function setReqUserConf( ReqUserConf){ dlgReqUserConf.visible = ReqUserConf}
    signal s_userConfd(variant UserConfd)

    Rectangle{
        y: 1
        width: 683
        height: 486
        visible: true
        color: backgroundCurrentColor
        radius: 10
        //color: parent.backgroundCurrecntColor
        border.color: parent.borderCurrentColor
        border.width: parent.borderCurrentWidth
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter
    }

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
    }
    Rectangle{
        id: dlgAlarmButtonPress
        x: 212
        y: 161
        width: 120
        height: 140
        z: 100
        visible: true
        radius: 10
        color: "#f2f2f2"
        border.color: "#ff0000"
        border.width: 3
        anchors.horizontalCenterOffset: -3
        anchors.horizontalCenter: parent.horizontalCenter
        AnimatedImage {
            source: "alarmButtonPress.gif"
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Text{
            text: "Нажми и отжми СТОП-кнопку для подтверждения действия."
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            font.letterSpacing: 0.3
            horizontalAlignment: Text.AlignHCenter;
            verticalAlignment: Text.AlignVCenter ;
            wrapMode: Text.WordWrap
            renderType: Text.NativeRendering
            font.bold: true
            anchors.leftMargin: 0
            anchors.rightMargin: 0
            anchors.bottomMargin: 3
        }
        Timer{
            interval: 1000
            repeat: true
            onTriggered: {
                parent.border.color == "#ff0000" ? parent.border.color = "black" : parent.border.color = "#ff0000"
            }
            running: parent.visible
        }
    }
    Rectangle{
        id: dlgReqUserConf
        x: 212
        y: 161
        width: 120
        height: 140
        z: 100
        visible: true
        color: "#f2f2f2"
        radius: 10
        border.color: "#ff0000"
        border.width: 3
        anchors.horizontalCenterOffset: -3
        anchors.horizontalCenter: parent.horizontalCenter
        Button{
            y: 56
            width: 100
            height: 28
            text: "Подтверждаю";
            font.pointSize: 10
            anchors.horizontalCenterOffset: 0
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
                dlgReqUserConf.visible = false
                s_userConfd(true)
            }
        }
        Text{
            text: "Подтверди действие."
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            font.letterSpacing: 0.4
            horizontalAlignment: Text.AlignHCenter;
            verticalAlignment: Text.AlignVCenter ;
            wrapMode: Text.WordWrap
            font.pointSize: 11
            anchors.topMargin: 5
            font.bold: true
            anchors.leftMargin: 0
            anchors.rightMargin: 0
        }

        Button {
            y: 90
            width: 100
            height: 28
            text: "Отмена"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: 0
            font.pointSize: 10
            onClicked: dlgReqUserConf.visible = false
        }
        Timer{
            interval: 1000
            repeat: true
            onTriggered: {
                parent.border.color == "#ff0000" ? parent.border.color = "black" : parent.border.color = "#ff0000"
            }
            running: parent.visible
        }
    }


    Column {
        id: column
        x: 543
        y: 205
        width: 144
        height: 270
        SimpleButton {
            id: autoModeBut
            radius: 10
            border.width: 2
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 0
            anchors.rightMargin: 0
            nameText.text: "РУЧНОЙ РЕЖИМ"
            checked: true
            checkable: true
            unPressCheckColor: "#d5d108"
            onS_checkedUserChanged: s_autoMode(Checked)
        }

        SimpleButton {
            id: startBut
            radius: 10
            border.width: 2
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 0
            anchors.rightMargin: 0
            nameText.text: "СТАРТ"
            checked: true
            checkable: true
            unPressCheckColor: "#04ff07"
            onS_checkedUserChanged: s_start(!Checked)
            function stateChd( State ) {
                nameText.text ="СТАРТ" + "\n"
                switch (State){
                case -1: nameText.text += "";break;
                case 0: nameText.text += "Обе горелки заблокированы";break;
                case 105: nameText.text += "Подтверждение пуска стоп-кнопкой";break;
                case 110: nameText.text += "Тест на герметичность";break;
                case 120: nameText.text += "Продувка перед пуском";break;
                case 125: nameText.text += "Подтверждение пуска";break;
                case 130: nameText.text += "Открытие перепускного.";break;
                case 140: nameText.text += "Выравнивание давления" ;break;
                case 150: nameText.text += "Розжиг запальников горелок";break;
                case 160: nameText.text += "Запуск горелок";break;
                case 165: nameText.text += "Прогрев";break;
                case 170: nameText.text += "Рабочая Фаза";break;
                }
            }
        }

        SimpleButton {
            id: blowdownBut
            radius: 10
            border.width: 2
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.leftMargin: 0
            nameText.text: "ПРОДУВКА"
            checked: true
            checkable: true
            unPressCheckColor: "#06ccf0"
            onS_checkedUserChanged: s_blowdown(!Checked)
            function etChd( ET ) {
                let days = ~~(ET / 86400)
                let hours = ~~(ET / 3600 % 24)
                let minutes = ~~(ET / 60 % 60)
                let seconds = ~~(ET % 60)

                nameText.text ="ПРОДУВКА"
                        + (ET == 0 ? "" :"\n" + (
                                         (days > 0 ? (days + "д ") : "")
                                         + ((hours + ":")) + ((minutes > 9 ? "" : "0") + (minutes + ":"))
                                         + ((seconds > 9 ? "" : "0") + seconds)
                                         ))
            }
        }

        SimpleButton {
            id: stopBut
            radius: 10
            border.width: 2
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.leftMargin: 0
            nameText.text: "СТОП"
            checked: true
            checkable: true
            nameText.fontSizeMode: Text.FixedSize
            nameText.font.pixelSize: 30
            onS_checkedUserChanged: s_stop(!Checked)
        }

        SimpleButton {
            id: alarmStopBut
            radius: 10
            border.width: 2
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.leftMargin: 0
            nameText.text: "АВАРИЙНЫЙ СТОП"
            checked: true
            checkable: true
            unPressCheckColor: "#ff0000"
            onS_checkedUserChanged: s_alarmStop(!Checked)
        }
        spacing: 5
    }

    Text {
        id: boilerState
        x: 377
        y: 146
        width: 150
        height: 50
        text: qsTr("состояние")
        anchors.right: parent.right
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WordWrap
        anchors.rightMargin: 13
        font.capitalization: Font.AllUppercase
        minimumPointSize: 2
        padding: 3
        font.bold: true
        font.pointSize: 300
        fontSizeMode: Text.Fit
    }

    Text {
        id: boilerHeating
        x: 192
        y: 30
        width: 133
        height: 28
        color: "#840000"
        text: qsTr("прогрев")
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignTop
        wrapMode: Text.WordWrap
        anchors.horizontalCenterOffset: (mirrorVentSmoke ? 1 : -1) * 200
        z: 1
        anchors.horizontalCenter: parent.horizontalCenter
        font.capitalization: Font.AllUppercase
        padding: 3
        minimumPointSize: 2
        font.bold: true
        fontSizeMode: Text.Fit
        font.pointSize: 300
        MouseArea{
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                tTipBoilerHeating.visible = true
            }
            onExited: {
                tTipBoilerHeating.visible = false
            }
        }
        ToolTip {
            id: tTipBoilerHeating
            delay: 500
            timeout: 5000
            visible: false
            text: "Время на прогрев котла. Уменьшается при работе горелок и увеличивается при продувке."
        }
    }

    Text {
        id: boilerColling
        x: 192
        y: 60
        width: 133
        height: 28
        color: "#003f62"
        text: qsTr("охлаждение")
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignTop
        wrapMode: Text.WordWrap
        anchors.horizontalCenterOffset: (mirrorVentSmoke ? 1 : -1) * 200
        styleColor: "#000000"
        z: 1
        anchors.horizontalCenter: parent.horizontalCenter
        font.capitalization: Font.AllUppercase
        padding: 3
        minimumPointSize: 2
        font.bold: true
        fontSizeMode: Text.Fit
        font.pointSize: 300
        MouseArea{
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                tTipBoilerColling.visible = true
            }
            onExited: {
                tTipBoilerColling.visible = false
            }
        }
        ToolTip {
            id: tTipBoilerColling
            delay: 500
            timeout: 5000
            visible: false
            text: "Время на охлаждения котла. Увеличивается при работе горелок и уменьшается при продувке."
        }
    }

    Burner{
        id: burner1
        objectName: parent.objectName + ".burner1"
        name: "Горелка 1 " + root.name
        x: 181
        y: 315
        z: 20
        width: 39
        height: 83
        borderWidth: 2
        borderWidthNotify: 2
        backgroundColor: "#cd2e2e"
        function setFlameS(FlameS) {flame1.visible = FlameS }
        function setIgnitionS(IgnitionS) {ignitionflame1.visible = IgnitionS }
        AnalogSignalVar1 {
            id: burner1_pGas
            x: -15
            y: -8
            objectName: ".pGas"
            width: 70
            height: indicHeigth
            shWidth: 5
            backgroundColor: indicColor
            colorShortName: "DarkOrange"
            postfix: "МПа"
            tooltipText: "Давление горелка 1"
            onS_valueChd: {flame1.height =  Math.max(30,Value / 100 * 170)}

            SimpleButton {
                id: sbPrVPos1
                width: parent.height * 1.5
                height: width
                visible: true
                radius: height / 2
                border.color: "#000000"
                anchors.bottom: parent.top
                anchors.bottomMargin: -4
                anchors.horizontalCenter: parent.horizontalCenter
                pressCheckColor: "#808080"
                nameText.text: "A"
                nameText.verticalAlignment: Text.AlignVCenter
                unPressCheckColor: Fap.run
                nameText.horizontalAlignment: Text.AlignHCenter
                checkable: true
                mouseArea.onClicked:{
                    if( mouse.button & Qt.RightButton ){
                        pidPGasBurner1.show()
                    }
                }
                onS_checkedUserChanged: pidPGasBurner1.s_manOn(Checked)
            }
            PID_Win{
                id: pidPGasBurner1
                objectName:  ".pGas_vrGasPosPID_ES"
                title: "ПИД давления газа горелки №1 " + root.name
                processName: "Давление газа горелки №1 " + root.name
                impactName: "Положение клапана газа"
                colorImpact: pipeGasColor
                colorProcess: "DarkOrange"
                mfuKpOut.visible: fullView
                mfuKiOut.visible: fullView
                mfuKdOut.visible: fullView
                mfuProcess.mantissa: 2
                mfuSetPt.mantissa: 2
                mfuFromProcess.mantissa: 2
                mfuFromImpact.mantissa: 2
                mfuImpact.mantissa: 2
                onManOnOffChanged: sbPrVPos1.checked = manOnOff
                adminView: parent.adminView
                confmOnEnter: true
            }
        }
    }
    Image {
        id: flame1
        x: 341
        y: 146
        width: height * 0.7
        height: 170
        visible: true
        anchors.bottom: parent.bottom
        source: "burn-fire-blue.svg"
        anchors.bottomMargin: 306
        anchors.horizontalCenterOffset: -70
        anchors.horizontalCenter: parent.horizontalCenter
        sourceSize.width: parent.width
        sourceSize.height: parent.height
    }
    Image {
        id: flash1
        x: 295
        y: 289
        width: 30
        height: 30
        visible: ignition1.st
        source: "lightning.svg"
        anchors.horizontalCenterOffset: -70
        anchors.horizontalCenter: parent.horizontalCenter
        sourceSize.width: parent.width
        sourceSize.height: parent.height
    }
    Image {
        id: ignitionflame1
        x: 345
        y: 270
        width: height
        height: 40
        visible: true
        source: "burn-fire.svg"
        anchors.horizontalCenterOffset: -70
        anchors.horizontalCenter: parent.horizontalCenter
        sourceSize.width: parent.width
        sourceSize.height: parent.height
    }
    Rectangle {
        id: ig1
        x: 355
        y: 334
        z: 2
        width: 10
        height: 60
        color: "#b9b9b9"
        radius: 0
        border.width: ignition1.borderCurrentWidth
        border.color: ignition1.borderCurrentColor
        anchors.horizontalCenterOffset: -44
        anchors.horizontalCenter: parent.horizontalCenter
        rotation: -45
        Text {
            text: "зп1"
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            rotation: 45
            anchors.horizontalCenterOffset: 19
            font.pointSize: 15
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenterOffset: 6
        }

    }
    StartStopUnit{
        id: ignition1
        name: "Запальник 1 " + root.name
        objectName: parent.objectName + ".burner1.ignition"
        anchors.fill: ig1
        rotation: ig1.rotation
    }
    Rectangle {
        x: 310
        y: 338
        width: 40
        height: 60
        color: burner1.backgroundCurrentColor
        radius: 0
        border.width: burner1.borderCurrentWidth
        border.color: burner1.borderCurrentColor
        anchors.horizontalCenterOffset: -70
        anchors.horizontalCenter: parent.horizontalCenter
        z: 10
        Rectangle{
            width: 40
            height: 40
            color: parent.color
            radius: 30
            border.width: burner1.borderCurrentWidth
            border.color: burner1.borderCurrentColor
            anchors.top: parent.top
            anchors.topMargin: -20
            anchors.horizontalCenter: parent.horizontalCenter
            z: 100
            Rectangle {
                width: 7
                height: 7
                color: parent.color
                radius: 30
                border.width: burner1.borderCurrentWidth
                border.color: burner1.borderCurrentColor
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                z: 100
            }
        }
        Text{
            text: "Г1"
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.verticalCenterOffset: 6
            anchors.horizontalCenterOffset: 0
            font.pointSize: 15
            anchors.horizontalCenter: parent.horizontalCenter

        }
    }

    Burner{
        id: burner2
        objectName: parent.objectName + ".burner2"
        name: "Горелка 2 " + root.name
        x: 320
        y: 315
        width: 40
        height: 83
        z: 10
        borderWidth: 2
        borderWidthNotify: 2
        function setFlameS(FlameS) {flame2.visible = FlameS }
        function setIgnitionS(IgnitionS) {ignitionflame2.visible = IgnitionS }
        AnalogSignalVar1 {
            id: burner2_pGas
            x: 138
            y: -9
            objectName: ".pGas"
            width: 70
            height: indicHeigth
            shWidth: 5
            backgroundColor: indicColor
            colorShortName: "DarkOrange"
            postfix: "МПа"//"°c"
            tooltipText: "Давление горелка 2"
            onS_valueChd: {flame2.height = Math.max(30,Value / 100 * 170)}

            SimpleButton {
                id: sbPrVPos2
                width: parent.height * 1.5
                height: width
                visible: true
                radius: height / 2
                border.color: "#000000"
                anchors.bottom: parent.top
                anchors.bottomMargin: -4
                anchors.horizontalCenter: parent.horizontalCenter
                pressCheckColor: "#808080"
                nameText.text: "A"
                nameText.verticalAlignment: Text.AlignVCenter
                unPressCheckColor: Fap.run
                nameText.horizontalAlignment: Text.AlignHCenter
                checkable: true
                mouseArea.onClicked:{
                    if( mouse.button & Qt.RightButton ){
                        pidPGasBurner2.show()
                    }
                }
                onS_checkedUserChanged: pidPGasBurner2.s_manOn(Checked)
            }
            PID_Win{
                id: pidPGasBurner2
                objectName:  ".pGas_vrGasPosPID_ES"
                title: "ПИД давления газа горелки №2 " + root.name
                processName: "Давление газа горелки №2 " + root.name
                impactName: "Положение клапана газа"
                colorImpact: pipeGasColor
                colorProcess: "DarkOrange"
                mfuKpOut.visible: fullView
                mfuKiOut.visible: fullView
                mfuKdOut.visible: fullView
                mfuProcess.mantissa: 2
                mfuSetPt.mantissa: 2
                mfuFromProcess.mantissa: 2
                mfuFromImpact.mantissa: 2
                mfuImpact.mantissa: 2
                onManOnOffChanged: sbPrVPos2.checked = manOnOff
                adminView: parent.adminView
                confmOnEnter: true
            }
        }
    }
    StartStopUnit{
        id: ignition2
        objectName: parent.objectName + ".burner2.ignition"
        anchors.fill: ig2
        name: "Запальник 2 " + root.name
        rotation: 45
    }
    Image {
        id: flame2
        x: 410
        y: 146
        width: height * 0.7
        height: 170
        visible: true
        anchors.bottom: parent.bottom
        source: "burn-fire-blue.svg"
        anchors.bottomMargin: 306
        anchors.horizontalCenterOffset: 70
        anchors.horizontalCenter: parent.horizontalCenter
        sourceSize.width: parent.width
        sourceSize.height: parent.height
    }
    Image {
        id: flash2
        x: 443
        y: 289
        width: 30
        height: 30
        visible: ignition2.st
        source: "lightning.svg"
        anchors.horizontalCenterOffset: 70
        anchors.horizontalCenter: parent.horizontalCenter
        sourceSize.width: parent.width
        sourceSize.height: parent.height
    }
    Image {
        id: ignitionflame2
        x: 345
        y: 270
        width: height
        height: 40
        visible: true
        source: "burn-fire.svg"
        anchors.horizontalCenter: parent.horizontalCenter
        sourceSize.height: parent.height
        anchors.horizontalCenterOffset: 70
        sourceSize.width: parent.width
    }
    Rectangle {
        id: ig2
        x: 431
        y: 334
        z: 1
        width: 10
        height: 60
        color: "#b9b9b9"
        radius: 0
        border.width: ignition2.borderCurrentWidth
        border.color: ignition2.borderCurrentColor
        anchors.horizontalCenterOffset: 44
        anchors.horizontalCenter: parent.horizontalCenter
        rotation: 45
        Text {
            text: "зп2"
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.horizontalCenterOffset: -19
            font.pointSize: 15
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenterOffset: 6
            rotation: -45
        }
    }
    Rectangle {
        x: 450
        y: 338
        width: 40
        height: 60
        color: burner1.backgroundCurrentColor
        radius: 0
        border.width: burner2.borderCurrentWidth
        border.color: burner2.borderCurrentColor
        anchors.horizontalCenterOffset: 70
        anchors.horizontalCenter: parent.horizontalCenter
        z: 2

        Text {
            text: "Г2"
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.horizontalCenterOffset: 0
            font.pointSize: 15
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenterOffset: 6
        }

        Rectangle {
            width: 40
            height: 40
            color: parent.color
            radius: 30
            border.width: burner2.borderCurrentWidth
            border.color: burner2.borderCurrentColor
            anchors.top: parent.top
            Rectangle {
                width: 7
                height: 7
                color: parent.color
                radius: 30
                border.width: burner2.borderCurrentWidth
                border.color: burner2.borderCurrentColor
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                z: 100
            }
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: -20
        }
    }

    Tank {
        id: tankWater
        x: 330
        y: 31
        width: 140
        height: 140
        radius: width / 2
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter
        borderWidth: 2
        z: 10
        objectName: "tank"
        level: 90
        levelRatio: 1
        showSeam: false
        showAlarmLevel: true
        showLevel: true
        nameText.text: ""
        SimpleButton {
            id: sbLvl
            x: 48
            y: 70
            width: 45
            height: width
            visible: true
            radius: height / 2
            border.color: "#000000"
            nameText.text: "A"
            nameText.horizontalAlignment: Text.AlignHCenter
            nameText.verticalAlignment: Text.AlignVCenter
            unPressCheckColor: Fap.run
            checkable: true
            anchors.leftMargin: -4
            pressCheckColor: "gray"
            mouseArea.onClicked:{
                if( mouse.button & Qt.RightButton ){
                    pidLvl.show()
                }
            }
            onS_checkedUserChanged:{
                pidLvl.s_manOn(Checked)
                checked = pidLvl.manOnOff
            }
        }
    }
    PID_Win{
        id: pidLvl
        objectName:  ".lvl_waterFC_PID_ES"
        title: "ПИД уровня воды " + root.name
        processName: "Уровень воды " + root.name
        impactName: "Частота насоса воды"
        colorProcess: "#7f9da6"
        mfuKpOut.visible: fullView
        mfuKiOut.visible: fullView
        mfuKdOut.visible: fullView
        mfuProcess.mantissa: 2
        mfuSetPt.mantissa: 2
        mfuFromProcess.mantissa: 2
        mfuFromImpact.mantissa: 2
        mfuImpact.mantissa: 2
        onManOnOffChanged: sbLvl.checked = manOnOff
        Component.onCompleted: sbLvl.checked = manOnOff
        adminView: parent.adminView
        confmOnEnter: true
    }
    RegulValveUnit {
        id: burner1_vrGas
        objectName:  root.objectName + ".burner1.vrGas"
        name: "Рег-й клапан горелки №1 " + root.name
        title: "РК1"
        x: 232
        y: 410
        z: 50
        width: 40
        height: 40
        anchors.horizontalCenterOffset: -143
        anchors.horizontalCenter: parent.horizontalCenter
        borderWidth: 2
        borderCurrentWidth: 2
        regValve.nameTextPixSize: valveNameSize
        regValve.position: 30
        regValve.substanceColor: pipeGasColor
        regValve.nameOnLeft: true
        regValve.nameOnTop: true
    }
    RegulValveUnit {
        id: burner2_vrGas
        objectName:  root.objectName + ".burner2.vrGas"
        name: "Рег-й клапан горелки №2 " + root.name
        title: "РК2"
        x: 523
        y: 410
        z: 50
        width: 40
        height: 40
        anchors.horizontalCenterOffset: 143
        anchors.horizontalCenter: parent.horizontalCenter
        borderCurrentWidth: 2
        borderWidth: 2
        regValve.position: 30
        regValve.substanceColor: pipeGasColor
        regValve.nameTextPixSize: valveNameSize
        regValve.nameOnLeft: true
        regValve.nameOnTop: true
    }
    Fan {
        id: ventAir
        name: "Воздушный вентилятор " + root.name
        title: "ВВ"
        x: 512
        y: 495
        width: 114
        height: 140
        anchors.horizontalCenterOffset: 182
        anchors.horizontalCenter: parent.horizontalCenter
        rotatePict: 90
        rotation: 0
        flanWidth: 40
        fanName.font.pointSize: 20
        borderWidth: 2
        objectName:  root.objectName + ".ventAir"
        mirror: true
    }
    FCUnit {
        name: "ЧП вентилятора " + root.name
        x: 377
        y: 524
        width: 40
        height: 50
        borderWidth: 2
        perstWin.confmOnEnter: true
        objectName: root.objectName + ".FCAir"
        title: "ЧПВВ"
        hrzOrPrst: true
    }
    Fan {
        id: ventSmoke
        name: "Дымосос " + root.name
        title: "Дс"
        x: 476
        y: 19
        z: 0
        width: 100
        height: 120
        anchors.horizontalCenterOffset: (mirrorVentSmoke ? -1 : 1) * 190
        anchors.horizontalCenter: parent.horizontalCenter
        fanName.font.pointSize: 20
        rotatePict: 0
        rotation: 0
        flanWidth: 40
        borderWidth: 2
        objectName:  root.objectName + ".ventSmoke"
        mirror: true
    }
    FCUnit {
        name: "ЧП дымососа " + root.name
        x: 492
        y: 90
        width: 40
        height: 50
        anchors.verticalCenter: ventSmoke.verticalCenter
        borderWidth: 2
        anchors.verticalCenterOffset: 36
        anchors.horizontalCenterOffset: 52
        anchors.horizontalCenter: ventSmoke.horizontalCenter
        perstWin.confmOnEnter: true
        objectName: root.objectName + ".FCSmoke"
        title: "ЧПД"
        hrzOrPrst: true
    }
    StartStopUnit {
        id: vGas
        objectName:  root.objectName + ".vGas"
        name: "Главный запорный " + root.name
        title: "КГ"
        x: 222
        y: 513
        z: 1
        width: 60
        height: 54
        allovAlarmTextBlinck: false
        allovAlarmBodyBlinck: false
        borderWidth: 2
        anchors.horizontalCenterOffset: -143
        anchors.horizontalCenter: parent.horizontalCenter
        textColor: "White"
        onStdChanged: textColor = std ? "Black" : "White"
        colorStopReady: "Black"
        colorRun: "Gold"
        Rectangle {
            color: parent.backgroundCurrentColor
            radius: 3
            border.color: parent.borderCurrentColor
            border.width: parent.borderWidth
            anchors.fill: parent
            Text {
                id: vGasNameText
                color: vGas.textCurrentColor
                text: vGas.title
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                fontSizeMode: Text.Fit
                anchors.topMargin: 3
                anchors.bottomMargin: 3
                anchors.leftMargin: 6
                font.pointSize: 300
                anchors.rightMargin: 6
                minimumPointSize: 10
                minimumPixelSize: 10
            }
        }
    }

    StartStopUnit {
        id: burner1_vGas
        objectName: root.objectName + ".burner1.vGas"
        name: "Запорный клапан Горелки №1 " + root.name
        title: "КГ1"
        x: 225
        y: 365
        z: 1
        width: 50
        height: 30
        allovAlarmTextBlinck: false
        allovAlarmBodyBlinck: false
        anchors.horizontalCenterOffset: -143
        anchors.horizontalCenter: parent.horizontalCenter
        colorStopReady: "Black"
        colorRun: "Gold"
        borderWidth: 2
        textColor:"White"
        onStdChanged: textColor = std ? "Black" : "White"
        Rectangle {
            color: parent.backgroundCurrentColor
            radius: 3
            border.color: parent.borderCurrentColor
            border.width: parent.borderWidth
            anchors.fill: parent
            Text {
                id: burner1_vGasCloserNameText
                color: burner1_vGas.textCurrentColor
                text: burner1_vGas.title
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                fontSizeMode: Text.Fit
                anchors.topMargin: 3
                anchors.bottomMargin: 3
                anchors.leftMargin: 6
                font.pointSize: 300
                anchors.rightMargin: 6
                minimumPointSize: 10
                minimumPixelSize: 10
            }
        }
    }

    StartStopUnit {
        id: burner2_vGas
        objectName:  root.objectName + ".burner2.vGas"
        name: "Запорный клапан Горелки №2 " + root.name
        title: "КГ2"
        x: 520
        y: 365
        z: 50
        width: 50
        height: 30
        allovAlarmTextBlinck: false
        allovAlarmBodyBlinck: false
        borderWidth: 2
        anchors.horizontalCenterOffset: 143
        anchors.horizontalCenter: parent.horizontalCenter
        colorStopReady: "Black"
        colorRun: "Gold"
        textColor:"White"
        onStdChanged: textColor = std ? "Black" : "White"
        Rectangle {
            color: parent.backgroundCurrentColor
            radius: 3
            border.color: parent.borderCurrentColor
            border.width: parent.borderWidth
            anchors.fill: parent
            Text {
                id: burner2_vGasCloserNameText
                color: burner2_vGas.textCurrentColor
                text: burner2_vGas.title
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                fontSizeMode: Text.Fit
                anchors.topMargin: 3
                anchors.bottomMargin: 3
                anchors.leftMargin: 6
                font.pointSize: 300
                anchors.rightMargin: 6
                minimumPointSize: 10
                minimumPixelSize: 10
            }
        }
    }

    AnalogSignalVar2 {
        id: pSmoke
        objectName: ".pSmoke"
        x: 427
        y: 44
        width: indicWidth
        height: indicHeigth
        visible: true
        anchors.horizontalCenterOffset: (mirrorVentSmoke ? -1 : 1) * 195
        anchors.horizontalCenter: parent.horizontalCenter
        shWidth: 5
        backgroundColor: indicColor
        colorShortName: "DarkOrange"
        tooltipText: "Температура отходящей воды"
        postfix: "МПа"
        confmOnEnter: true
        SimpleButton{
            id: sbPSmoke
            radius: height / 2
            border.color: "#000000"
            width: parent.height * 1.5
            height: width
            visible: true
            checkable: true
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.right
            nameText.text: "A"
            nameText.verticalAlignment: Text.AlignVCenter
            nameText.horizontalAlignment: Text.AlignHCenter
            anchors.leftMargin: -4
            pressCheckColor: "gray"
            unPressCheckColor: Fap.run
            mouseArea.onClicked:{
                if( mouse.button & Qt.RightButton ){
                    pidPSmoke.show()
                }
            }
            onS_checkedUserChanged: pidPSmoke.s_manOn(Checked)
        }
        PID_Win{
            id: pidPSmoke
            objectName:  ".pSmokePID_CP"
            title: "ПИД разряжения в топке " + root.name
            processName: "Разряжение в топке " + root.name
            impactName: "Частота дымососа"
            colorProcess: "#7f9da6"
            impIs2DisctOuts: false
            mfuKpOut.visible: fullView
            mfuKiOut.visible: fullView
            mfuKdOut.visible: fullView
            mfuProcess.mantissa: 2
            mfuSetPt.mantissa: 2
            mfuFromProcess.mantissa: 2
            mfuFromImpact.mantissa: 2
            mfuImpact.mantissa: 2
            onManOnOffChanged: sbPSmoke.checked = manOnOff
            adminView: parent.adminView
            confmOnEnter: true
        }
    }



    AnalogSignalVar2 {
        objectName: ".tSmoke"
        id: tSmoke
        x: 525
        y: 8
        width: indicWidth
        height: indicHeigth
        visible: true
        anchors.horizontalCenterOffset: (mirrorVentSmoke ? -1 : 1) * 195
        anchors.horizontalCenter: parent.horizontalCenter
        z: 0
        shWidth: 5
        //shHeight: 15
        backgroundColor: indicColor
        colorShortName: "green"
        postfix: "°c"
        tooltipText: "Температура отработавших газов"
        confmOnEnter: true
    }

    StartStopUnit {
        id: ignition1_vGas
        objectName:  root.objectName + ".burner1.vIgnition"
        name: "Запорный клапан запальника Горелки № 1 " + root.name
        title: "КЗ1"
        x: 354
        y: 430
        z: 1
        width: 34
        height: 20
        allovAlarmTextBlinck: false
        allovAlarmBodyBlinck: false
        borderWidth: 2
        anchors.horizontalCenterOffset: -26
        anchors.horizontalCenter: parent.horizontalCenter
        colorStopReady: "Black"
        colorRun: "Gold"
        onStdChanged: textColor = std ? "Black" : "White"
        textColor: "White"
        Rectangle {
            color: parent.backgroundCurrentColor
            radius: 3
            border.color: parent.borderCurrentColor
            border.width: parent.borderWidth
            anchors.fill: parent
            Text {
                id: ignition1_vGasCloserNameText
                color: ignition1_vGas.textCurrentColor
                text: ignition1_vGas.title
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                fontSizeMode: Text.Fit
                anchors.topMargin: 3
                anchors.bottomMargin: 3
                anchors.leftMargin: 6
                font.pointSize: 300
                anchors.rightMargin: 6
                minimumPointSize: 10
                minimumPixelSize: 10
            }
        }
    }

    StartStopUnit {
        id: ignition2_vGas
        objectName:  root.objectName + ".burner2.vIgnition"
        name: "Запорный клапан запальника Горелки № 2 " + root.name
        title: "КЗ2"
        x: 409
        y: 430
        z: 1
        width: 34
        height: 20
        allovAlarmTextBlinck: false
        allovAlarmBodyBlinck: false
        anchors.horizontalCenterOffset: 26
        anchors.horizontalCenter: parent.horizontalCenter
        colorStopReady: "Black"
        colorRun: "Gold"
        borderWidth: 2
        onStdChanged: textColor = std ? "Black" : "White"
        textColor: "White"
        Rectangle {
            color: parent.backgroundCurrentColor
            radius: 3
            border.color: parent.borderCurrentColor
            border.width: parent.borderWidth
            anchors.fill: parent
            Text {
                id: ignition2_vGasCloserNameText
                color: ignition2_vGas.textCurrentColor
                text: ignition2_vGas.title
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                fontSizeMode: Text.Fit
                anchors.topMargin: 3
                anchors.bottomMargin: 3
                anchors.leftMargin: 6
                font.pointSize: 300
                anchors.rightMargin: 6
                minimumPointSize: 10
                minimumPixelSize: 10
            }
        }
    }


    AnalogSignalVar2 {
        id: pSteam
        x: 368
        y: 8
        width: 70
        height: indicHeigth
        anchors.horizontalCenterOffset: 44
        anchors.horizontalCenter: parent.horizontalCenter
        objectName: ".pSteam"
        confmOnEnter: true
        postfix: "МПа"
        shWidth: 5
        z: 10
        tooltipText: "Давление пара"
        backgroundColor: indicColor
        colorShortName: "#ff8c00"
        SimpleButton{
            id: sbPrSteam
            radius: height / 2
            border.color: "#000000"
            width: parent.height * 1.5
            height: width
            visible: true
            checkable: true
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.right
            nameText.text: "A"
            nameText.verticalAlignment: Text.AlignVCenter
            nameText.horizontalAlignment: Text.AlignHCenter
            anchors.leftMargin: -4
            pressCheckColor: "gray"
            unPressCheckColor: Fap.run
            mouseArea.onClicked:{
                if( mouse.button & Qt.RightButton ){
                    pidPSteam.show()
                }
            }
            onS_checkedUserChanged: pidPSteam.s_manOn(Checked)
        }
        PID_Win{
            id: pidPSteam
            objectName:  ".pSteamPID_CP"
            title: "ПИД давления пара " + root.name
            processName: "Давление пара " + root.name
            impactName: "Давление горелок"
            impIs2DisctOuts: false
            colorProcess: "#7f9da6"
            mfuKpOut.visible: fullView
            mfuKiOut.visible: fullView
            mfuKdOut.visible: fullView
            mfuProcess.mantissa: 2
            mfuSetPt.mantissa: 2
            mfuFromProcess.mantissa: 2
            mfuFromImpact.mantissa: 2
            mfuImpact.mantissa: 2
            onManOnOffChanged: sbPrSteam.checked = manOnOff
            adminView: parent.adminView
            confmOnEnter: true
        }
    }

    StartStopUnit {
        id: vCandle
        objectName: root.objectName + ".vCandle"
        name: "Запорный клапан свечи безопасности " + root.name
        title: "КСБ"
        x: 93
        y: 450
        z: 2
        width: 35
        height: 25
        allovAlarmTextBlinck: false
        allovAlarmBodyBlinck: false
        borderWidth: 2
        colorStopReady: "Black"
        colorRun: "Gold"
        onStdChanged: textColor = std ? "Black" : "White"
        textColor: "White"
        Rectangle {
            color: parent.backgroundCurrentColor
            radius: 3
            border.color: parent.borderCurrentColor
            border.width: parent.borderWidth
            anchors.fill: parent
            Text {
                id: vCandleNameText
                color: vCandle.textCurrentColor
                text: vCandle.title
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                fontSizeMode: Text.Fit
                anchors.topMargin: 3
                anchors.bottomMargin: 3
                anchors.leftMargin: 6
                font.pointSize: 300
                anchors.rightMargin: 6
                minimumPointSize: 10
                minimumPixelSize: 10
            }
        }
    }

    StartStopUnit {
        id: vGasSml
        objectName: root.objectName + ".vGasSml"
        name: "Запорный перепускной клапан " + root.name
        title: "КП"
        x: 93
        y: 528
        z: 2
        width: 35
        height: 25
        allovAlarmTextBlinck: false
        allovAlarmBodyBlinck: false
        borderWidth: 2
        colorStopReady: "Black"
        colorRun: "Gold"
        onStdChanged: textColor = std ? "Black" : "White"
        textColor: "White"
        Rectangle {
            color: parent.backgroundCurrentColor
            radius: 3
            border.color: parent.borderCurrentColor
            border.width: parent.borderWidth
            anchors.fill: parent
            Text {
                id: vGasSmlNameText
                color: vGasSml.textCurrentColor
                text: vGasSml.title
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                fontSizeMode: Text.Fit
                anchors.topMargin: 3
                anchors.bottomMargin: 3
                anchors.leftMargin: 6
                font.pointSize: 300
                anchors.rightMargin: 6
                minimumPointSize: 10
                minimumPixelSize: 10
            }
        }
    }


    AnalogSignalVar2 {
        id: pAir
        objectName: ".pAir"
        x: 368
        y: 573
        z: 2
        width:  indicWidth
        height: indicHeigth
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter
        shWidth: 5
        backgroundColor: indicColor
        colorShortName: "DarkOrange"
        tooltipText: "Давление воздуха"
        postfix: "МПа"
        confmOnEnter: true
        SimpleButton{
            id: sbPrAir
            radius: height / 2
            border.color: "#000000"
            width: parent.height * 1.5
            height: width
            visible: true
            checkable: true
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.right
            nameText.text: "A"
            nameText.verticalAlignment: Text.AlignVCenter
            nameText.horizontalAlignment: Text.AlignHCenter
            anchors.leftMargin: -4
            pressCheckColor: "gray"
            unPressCheckColor: Fap.run
            mouseArea.onClicked:{
                if( mouse.button & Qt.RightButton ){
                    pidPAir.show()
                }
            }
            onS_checkedUserChanged: pidPAir.s_manOn(Checked)
        }
    }
    PID_Win{
        id: pidPAir
        objectName: ".airPID_CP"
        title: "ПИД давления воздуха " + root.name
        processName: "Давление воздуха " + root.name
        impactName: "Частота вентилятора"
        colorProcess: "#7f9da6"
        impIs2DisctOuts: false
        mfuKpOut.visible: fullView
        mfuKiOut.visible: fullView
        mfuKdOut.visible: fullView
        mfuProcess.mantissa: 2
        mfuSetPt.mantissa: 2
        mfuFromProcess.mantissa: 2
        mfuFromImpact.mantissa: 2
        mfuImpact.mantissa: 2
        onManOnOffChanged: sbPrAir.checked = manOnOff
        adminView: parent.adminView
        confmOnEnter: true
    }
    //    Image {
    //        id: boilerIm
    //        x: 147
    //        y: 76
    //        width: 522
    //        height: 405
    //        visible: false
    //        source: "boiler.svg"
    //        anchors.horizontalCenter: parent.horizontalCenter
    //        anchors.horizontalCenterOffset: 0
    //        sourceSize.width: parent.width
    //        sourceSize.height: parent.height
    //    }

    Pipe {
        x: 360
        y: 582
        width: 158
        height: 40
        anchors.horizontalCenterOffset: 36
        anchors.horizontalCenter: parent.horizontalCenter
        borderWidth: 2
        nActiveColor: "DeepSkyBlue"
    }

    Pipe {
        x: 194
        y: 397
        width: 40
        height: 187
        z: 0
        horOrVert: false
        anchors.horizontalCenterOffset: 70
        anchors.horizontalCenter: parent.horizontalCenter
        nActiveColor: "#00bfff"
    }

    PipeAngle90 {
        x: 305
        y: 567
        width: 50
        height: 60
        anchors.horizontalCenterOffset: -70
        anchors.horizontalCenter: parent.horizontalCenter
        z: 0
        borderWidth: 2
        nActiveColor: "DeepSkyBlue"
        pipeThin: 40
        rotation: 90

    }


    Pipe {
        x: 195
        y: 397
        width: 40
        height: 175
        horOrVert: false
        anchors.horizontalCenterOffset: -70
        anchors.horizontalCenter: parent.horizontalCenter
        nActiveColor: "#00bfff"
    }

    Pipe {
        x: 194
        y: 355
        width: 25
        height: 388
        z: 0
        horOrVert: false
        anchors.horizontalCenterOffset: -143
        anchors.horizontalCenter: parent.horizontalCenter
        nActiveColor: pipeGasColor
    }

    Pipe {
        x: 480
        y: 325
        width: 46
        height: 25
        anchors.horizontalCenterOffset: 103
        anchors.horizontalCenter: parent.horizontalCenter
        borderWidth: 2
        nActiveColor: pipeGasColor
    }

    PipeAngle90 {
        x: 238
        y: 325
        width: 30
        height: 30
        anchors.horizontalCenterOffset: -141
        anchors.horizontalCenter: parent.horizontalCenter
        endAmgle: 90
        pipeThin: 25
        borderWidth: 2
        rotation: 180
        nActiveColor: pipeGasColor
    }

    Pipe {
        x: 268
        y: 325
        width: 46
        height: 25
        anchors.horizontalCenterOffset: -103
        anchors.horizontalCenter: parent.horizontalCenter
        borderWidth: 2
        nActiveColor: pipeGasColor
    }

    Pipe {
        x: 190
        y: 355
        width: 25
        height: 118
        z: 3
        horOrVert: false
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: 143
        nActiveColor: pipeGasColor
    }
    Pipe {
        x: 267
        y: 478
        width: 259
        height: 25
        anchors.horizontalCenterOffset: -3
        anchors.horizontalCenter: parent.horizontalCenter
        z: 0
        borderWidth: 2
        nActiveColor: pipeGasColor
    }



    AnalogSignalVar1 {
        id: pGasBV
        x: 368
        y: 486
        width: 70
        height: indicHeigth
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter
        backgroundColor: indicColor
        postfix: "МПа"
        shWidth: 5
        objectName:  ".pGasBV"
        colorShortName: "#ff8c00"
        //confmOnEnter: true
        tooltipText: "Давление между клапанами"
        z: 5
    }

    AnalogSignalVar2 {
        id: pGas
        x: 215
        y: 573
        width: 70
        height: indicHeigth
        anchors.horizontalCenterOffset: -143
        anchors.horizontalCenter: parent.horizontalCenter
        backgroundColor: indicColor
        postfix: "МПа"
        shWidth: 5
        objectName: ".pGas"
        colorShortName: "#ff8c00"
        confmOnEnter: true
        tooltipText: "Давление газа"
        z: 5
    }

    PipeAngle90 {
        x: 525
        y: 325
        width: 30
        height: 30
        anchors.horizontalCenterOffset: 140
        anchors.horizontalCenter: parent.horizontalCenter
        endAmgle: 90
        borderWidth: 2
        nActiveColor: pipeGasColor
        rotation: 270
        pipeThin: 25
    }

    Pipe {
        x: 190
        y: 378
        width: 6
        height: 102
        borderWidth: 1
        anchors.horizontalCenterOffset: 26
        nActiveColor: pipeGasColor
        anchors.horizontalCenter: parent.horizontalCenter
        horOrVert: false
        z: 0
    }

    Pipe {
        x: 190
        y: 378
        width: 6
        height: 102
        borderWidth: 1
        anchors.horizontalCenterOffset: -26
        nActiveColor: pipeGasColor
        anchors.horizontalCenter: parent.horizontalCenter
        horOrVert: false
        z: 0
    }

    PipeAngle90 {
        x: 525
        y: 473
        width: 30
        height: 30
        anchors.horizontalCenterOffset: 140
        anchors.horizontalCenter: parent.horizontalCenter
        nActiveColor: pipeGasColor
        endAmgle: 90
        pipeThin: 25
        rotation: 0
        borderWidth: 2
    }
    Pipe {
        x: 27
        y: 459
        width: 169
        height: 6
        z: 1
        nActiveColor: pipeGasColor
        borderWidth: 1
    }





    PipeAngle90 {
        x: 17
        y: 455
        width: 10
        height: 10
        endAmgle: 90
        nActiveColor: pipeGasColor
        borderWidth: 1
        pipeThin: 6
        rotation: 90
    }

    Pipe {
        x: 17
        y: -15
        width: 6
        height: 471
        z: 1
        horOrVert: false
        nActiveColor: pipeGasColor
        borderWidth: 1
    }

    PipeAngle180 {
        x: 16
        y: -24
        width: 20
        height: 9
        endAmgle: 180
        nActiveColor: pipeGasColor
        borderWidth: 1
        rotation: 180
        pipeThin: 6

    }


    Pipe {
        x: 117
        y: 501
        width: 79
        height: 6
        borderWidth: 1
        nActiveColor: pipeGasColor
        z: 1
    }

    PipeAngle90 {
        x: 107
        y: 603
        width: 10
        height: 10
        borderWidth: 1
        pipeThin: 6
        rotation: 90
        nActiveColor: pipeGasColor
        endAmgle: 90
    }

    PipeAngle90 {
        x: 107
        y: 501
        width: 10
        height: 10
        borderWidth: 1
        pipeThin: 6
        rotation: 180
        nActiveColor: pipeGasColor
        endAmgle: 90
    }

    Pipe {
        x: 198
        y: 511
        width: 6
        height: 92
        borderWidth: 1
        horOrVert: false
        anchors.horizontalCenterOffset: -240
        anchors.horizontalCenter: parent.horizontalCenter
        nActiveColor: pipeGasColor
        z: 1
    }

    Pipe {
        x: 117
        y: 607
        width: 79
        height: 6
        borderWidth: 1
        nActiveColor: pipeGasColor
        z: 1
    }

    SimpleButton {
        id: btTestGerm
        x: 223
        y: 521
        width: 125
        height: 39
        color: "#a4a4a4"
        radius: 5
        //border.color: "#dfdfdf"
        border.width: 2
        unPressCheckColor: "#bbbbbb"
        lightnessCoef: 1.5
        nameText.verticalAlignment: Text.AlignVCenter
        nameText.horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter
        nameText.text: "ТЕСТ НА ГЕРМЕТИЧНОСТЬ"
        checkable: true
        ///checked: false
        onS_checkedUserChanged: s_germTestStart(Checked)
        Timer{
            interval: 1000
            repeat: true
            onTriggered: {
                parent.lightnessCoef == 1.5 ? parent.lightnessCoef = 0.5 : parent.lightnessCoef = 1.5
            }
            running: parent.checked
        }

    }


}


/*##^##
Designer {
    D{i:0;formeditorZoom:0.9}D{i:2;locked:true}D{i:4;locked:true}D{i:64;locked:true}D{i:63;locked:true}
D{i:80;locked:true}D{i:79;locked:true}D{i:86;locked:true}D{i:85;locked:true}D{i:89;locked:true}
D{i:88;locked:true}
}
##^##*/
