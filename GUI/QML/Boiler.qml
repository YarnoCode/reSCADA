import QtQuick 2.12
import QtQuick.Controls 2.15
import "fap.js" as Fap

UnitPropItem {
    id: root
    width: 800
    height: 622
    property alias ignition2: ignition2

    borderWidth: 1
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

    property bool mirrorVentSmoke: true
    property bool smokePID_ContOrStep: true
    property bool pAirDuble: false

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
        y: 66
        width: 433
        height: 421
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
        visible: false
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
        visible: false
        color: "#f2f2f2"
        radius: 10
        border.color: "#ff0000"
        border.width: 3
        anchors.horizontalCenterOffset: -3
        anchors.horizontalCenter: parent.horizontalCenter
        Button{
            y: 65
            width: 100
            height: 28
            text: "Да";
            font.pointSize: 10
            anchors.horizontalCenterOffset: 0
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
                dlgReqUserConf.visible = false
                s_userConfd(true)
            }
        }
        Text{
            text: "Подтвердить розжиг горелок"
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
            y: 99
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
        x: 640
        y: 203
        width: 144
        height: 270

        SimpleButton {
            id: startBut
            width: 150
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
        SimpleButton {
            id: resetAlarmBut
            color: "#dfdf25"
            radius: 10
            border.width: 2
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 0
            anchors.rightMargin: 0
            nameText.text: "СБРОС АВАРИЙ"
            checked: true
            checkable: true
            unPressCheckColor: "#d5d108"
            onS_checkedUserChanged: s_autoMode(Checked)
        }
        SimpleButton {
            id: autoModeBut
            color: "#bfbfbf"
            radius: 10
            border.width: 2
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 0
            anchors.rightMargin: 0
            nameText.text: "РУЧНОЙ РЕЖИМ"
            checked: false
            checkable: true
            onS_checkedUserChanged: s_autoMode(Checked)
        }
        spacing: 5
    }

    Text {
        id: boilerState
        x: 637
        y: 147
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
        y: 192
        width: 133
        height: 28
        visible: true
        color: "#840000"
        text: qsTr("прогрев")
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignTop
        wrapMode: Text.WordWrap
        anchors.horizontalCenterOffset: 0
        z: 1
        anchors.horizontalCenter: parent.horizontalCenter
        font.capitalization: Font.AllUppercase
        padding: 3
        minimumPointSize: 2
        font.bold: true
        fontSizeMode: Text.Fit
        font.pointSize: 300
        //        MouseArea{
        //            anchors.fill: parent
        //            anchors.rightMargin: 344
        //            anchors.bottomMargin: 20
        //            anchors.leftMargin: -344
        //            anchors.topMargin: -20
        //            hoverEnabled: true
        //            onEntered: {
        //                tTipBoilerHeating.visible = true
        //            }
        //            onExited: {
        //                tTipBoilerHeating.visible = false
        //            }
        //        }
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
        y: 222
        width: 133
        height: 28
        visible: true
        color: "#003f62"
        text: qsTr("охлаждение")
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignTop
        wrapMode: Text.WordWrap
        anchors.horizontalCenterOffset: 0
        styleColor: "#000000"
        z: 1
        anchors.horizontalCenter: parent.horizontalCenter
        font.capitalization: Font.AllUppercase
        padding: 3
        minimumPointSize: 2
        font.bold: true
        fontSizeMode: Text.Fit
        font.pointSize: 300
        //        MouseArea{
        //            anchors.fill: parent
        //            hoverEnabled: true
        //            onEntered: {
        //                tTipBoilerColling.visible = true
        //            }
        //            onExited: {
        //                tTipBoilerColling.visible = false
        //            }
        //        }
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
        x: 301
        y: 316
        z: 20
        width: 39
        height: 83
        borderWidth: 2
        borderWidthNotify: 2
        backgroundColor: "#cd2e2e"
        function setFlameS(FlameS) {flame1.visible = FlameS }
        function setIgnitionS(IgnitionS) {ignitionflame1.visible = IgnitionS }
        AnalogSignalVar2 {
            id: burner1_pGas
            x: -103
            y: -12
            objectName: ".pGas"
            width: 90
            height: indicHeigth
            minShow: false
            shWidth: 5
            backgroundColor: indicColor
            colorShortName: "DarkOrange"
            postfix: " кПа"
            tooltipText: "Давление горелка 1"
            onS_valueChd: { flame1.height =  40 + 150 * Value/maxLvl.valueReal }
            mantissa: 2
            textColor: "#5FDFDF"
        }
        SimpleButton {
            id: sbPrVPos1
            width: burner1_pGas.height * 1.5
            height: width
            visible: true
            radius: height / 2
            border.color: "#000000"
            anchors.bottom: burner1_pGas.top
            anchors.bottomMargin: -4
            anchors.horizontalCenter: burner1_pGas.horizontalCenter
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
            objectName:  ".pGas_vrGasPosPID"
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
            impIsAnlgOut: false
            impIs2DisctOuts: true
            onManOnOffChanged: sbPrVPos1.checked = manOnOff
            adminView: parent.adminView
            confmOnEnter: true
        }
    }
    Image {
        id: flame1
        x: 341
        y: 146
        width: 50
        height: 170
        visible: true
        anchors.bottom: parent.bottom
        source: "siemense flame.png"
        anchors.bottomMargin: 306
        anchors.horizontalCenterOffset: -83
        anchors.horizontalCenter: parent.horizontalCenter
        sourceSize.width: parent.width
        sourceSize.height: parent.height
    }
    Image {
        id: flash1
        x: 295
        y: 299
        width: 30
        height: 30
        visible: ignition1.st
        source: "lightning.svg"
        anchors.horizontalCenterOffset: -37
        anchors.horizontalCenter: parent.horizontalCenter
        sourceSize.width: parent.width
        sourceSize.height: parent.height
    }
    Image {
        id: ignitionflame1
        x: 345
        y: 278
        width: 20
        height: 50
        visible: true
        source: "siemense flame.png"
        anchors.horizontalCenterOffset: -40
        anchors.horizontalCenter: parent.horizontalCenter
        sourceSize.width: parent.width
        sourceSize.height: parent.height
    }
    Rectangle {
        id: ig1
        x: 355
        y: 329
        z: 2
        width: 10
        height: 60
        color: "#b9b9b9"
        radius: 0
        border.width: ignition1.borderCurrentWidth
        border.color: ignition1.borderCurrentColor
        anchors.horizontalCenterOffset: -29
        anchors.horizontalCenter: parent.horizontalCenter
        rotation: -20
        Text {
            text: ""
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
        anchors.horizontalCenterOffset: -80
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
        x: 460
        y: 316
        width: 40
        height: 83
        z: 10
        borderWidth: 2
        borderWidthNotify: 2
        function setFlameS(FlameS) {flame2.visible = FlameS }
        function setIgnitionS(IgnitionS) {ignitionflame2.visible = IgnitionS }
        AnalogSignalVar2 {
            id: burner2_pGas
            x: 56
            y: -14
            objectName: ".pGas"
            width: 90
            height: indicHeigth
            minShow: false
            shWidth: 5
            backgroundColor: indicColor
            colorShortName: "DarkOrange"
            postfix: " кПа"//"°c"
            tooltipText: "Давление горелка 2"
            onS_valueChd: { flame2.height = 40 + 150 * Value/maxLvl.valueReal }
            mantissa: 2
            textColor: "#5FDFDF"

        }
        SimpleButton {
            id: sbPrVPos2
            width: burner2_pGas.height * 1.5
            height: width
            visible: true
            radius: height / 2
            border.color: "#000000"
            anchors.bottom: burner2_pGas.top
            anchors.bottomMargin: -4
            anchors.horizontalCenter: burner2_pGas.horizontalCenter
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
            objectName:  ".pGas_vrGasPosPID"
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
            impIsAnlgOut: false
            impIs2DisctOuts: true
            onManOnOffChanged: sbPrVPos2.checked = manOnOff
            adminView: parent.adminView
            confmOnEnter: true
        }
    }
    StartStopUnit{
        id: ignition2
        objectName: parent.objectName + ".burner2.ignition"
        anchors.fill: ig2
        name: "" + root.name
        rotation: 45
    }
    Image {
        id: flame2
        x: 410
        y: 146
        width: 50
        height: 170
        visible: true
        anchors.bottom: parent.bottom
        source: "siemense flame.png"
        mirror: true
        anchors.bottomMargin: 306
        anchors.horizontalCenterOffset: 83
        anchors.horizontalCenter: parent.horizontalCenter
        sourceSize.width: parent.width
        sourceSize.height: parent.height
    }
    Image {
        id: flash2
        x: 443
        y: 299
        width: 30
        height: 30
        visible: ignition2.st
        source: "lightning.svg"
        anchors.horizontalCenterOffset: 36
        anchors.horizontalCenter: parent.horizontalCenter
        sourceSize.width: parent.width
        sourceSize.height: parent.height
    }
    Image {
        id: ignitionflame2
        x: 345
        y: 278
        width: 20
        height: 50
        visible: true
        source: "siemense flame.png"
        mirror: true
        anchors.horizontalCenter: parent.horizontalCenter
        sourceSize.height: parent.height
        anchors.horizontalCenterOffset: 39
        sourceSize.width: parent.width
    }
    Rectangle {
        id: ig2
        x: 431
        y: 329
        z: 1
        width: 10
        height: 60
        color: "#b9b9b9"
        radius: 0
        border.width: ignition2.borderCurrentWidth
        border.color: ignition2.borderCurrentColor
        anchors.horizontalCenterOffset: 29
        anchors.horizontalCenter: parent.horizontalCenter
        rotation: 20
        Text {
            text: ""
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
        anchors.horizontalCenterOffset: 80
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
        mainGradientColor: "#6E6E6E"
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
        objectName:  ".lvl_waterFC_PID"
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
        title: ""
        x: 232
        y: 394
        z: 50
        width: 40
        height: 40
        anchors.horizontalCenterOffset: -185
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
        title: ""
        x: 523
        y: 394
        z: 50
        width: 40
        height: 40
        anchors.horizontalCenterOffset: 186
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
        title: ""
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
        x: 637
        y: 572
        width: 40
        height: 50
        borderWidth: 2
        perstWin.confmOnEnter: true
        objectName: root.objectName + ".FCair"
        title: ""
        hrzOrPrst: true

    }
    Fan {
        id: ventSmoke
        name: "Дымосос " + root.name
        title: ""
        x: 476
        y: 146
        z: 0
        width: 100
        height: 120
        anchors.horizontalCenterOffset: -307
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
        objectName: root.objectName + ".FCsmoke"
        title: ""
        hrzOrPrst: true
    }
    StartStopUnit {
        id: vGas
        objectName:  root.objectName + ".vGas"
        name: "Главный запорный " + root.name
        title: ""
        x: 222
        y: 514
        z: 1
        width: 60
        height: 54
        allovAlarmTextBlinck: false
        allovAlarmBodyBlinck: false
        borderWidth: 2
        anchors.horizontalCenterOffset: -183
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
        title: ""
        x: 225
        y: 365
        z: 1
        width: 40
        height: 30
        allovAlarmTextBlinck: false
        allovAlarmBodyBlinck: false
        anchors.horizontalCenterOffset: -185
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
        title: ""
        x: 520
        y: 365
        z: 50
        width: 40
        height: 30
        allovAlarmTextBlinck: false
        allovAlarmBodyBlinck: false
        borderWidth: 2
        anchors.horizontalCenterOffset: 186
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
        y: 174
        width: indicWidth
        height: indicHeigth
        visible: true
        anchors.horizontalCenterOffset: -269
        anchors.horizontalCenter: parent.horizontalCenter
        shWidth: 5
        backgroundColor: indicColor
        colorShortName: "DarkOrange"
        tooltipText: "Температура отходящей воды"
        postfix: "Па"
        confmOnEnter: true
        mantissa: 0
        textColor: "#5FDFDF"

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
            objectName:  ".pSmokePID"
            title: "ПИД разряжения в топке " + root.name
            processName: "Разряжение в топке " + root.name
            impactName: "Частота дымососа"
            colorProcess: "#7f9da6"
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
        y: 138
        width: indicWidth
        height: indicHeigth
        visible: true
        anchors.horizontalCenterOffset: -269
        anchors.horizontalCenter: parent.horizontalCenter
        z: 0
        shWidth: 5
        //shHeight: 15
        backgroundColor: indicColor
        colorShortName: "green"
        postfix: "°c"
        tooltipText: "Температура отработавших газов"
        confmOnEnter: true
        textColor: "#5FDFDF"
        //valueTextFont: Font.bold = false

    }

    StartStopUnit {
        id: ignition1_vGas
        objectName:  root.objectName + ".burner1.vIgnition"
        name: "Запорный клапан запальника Горелки № 1 " + root.name
        title: ""
        x: 354
        y: 430
        z: 1
        width: 20
        height: 20
        allovAlarmTextBlinck: false
        allovAlarmBodyBlinck: false
        borderWidth: 2
        anchors.horizontalCenterOffset: -20
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
        title: ""
        x: 409
        y: 430
        z: 1
        width: 20
        height: 20
        allovAlarmTextBlinck: false
        allovAlarmBodyBlinck: false
        anchors.horizontalCenterOffset: 20
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
        postfix: " кПа"
        shWidth: 5
        z: 10
        tooltipText: "Давление пара"
        backgroundColor: indicColor
        colorShortName: "#ff8c00"
        textColor: "#5FDFDF"

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
            objectName:  ".pSteamPID"
            title: "ПИД давления пара " + root.name
            processName: "Давление пара " + root.name
            impactName: "Давление горелок"
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
        title: ""
        x: 131
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
        title: ""
        x: 131
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
        width: 90
        z: 2
        height: indicHeigth
        anchors.horizontalCenterOffset: 2
        anchors.horizontalCenter: parent.horizontalCenter
        shWidth: 5
        backgroundColor: indicColor
        colorShortName: "DarkOrange"
        tooltipText: "Давление воздуха"
        postfix: " кПа"
        confmOnEnter: true
        visible: ! pAirDuble
        mantissa: 2
        textColor: "#5FDFDF"

    }

    SimpleButton{
        id: sbPrAir
        x: 375
        y: 522
        radius: height / 2
        border.color: "#000000"
        width: 45
        height: width
        visible: true
        checkable: true
        nameText.text: "A"
        nameText.verticalAlignment: Text.AlignVCenter
        nameText.horizontalAlignment: Text.AlignHCenter
        pressCheckColor: "gray"
        unPressCheckColor: Fap.run
        mouseArea.onClicked:{
            if( mouse.button & Qt.RightButton ){
                pidPAir.show()
            }
        }
        onS_checkedUserChanged: pidPAir.s_manOn(Checked)
    }

    PID_Win{
        id: pidPAir
        objectName: ".airPID"
        title: "ПИД давления воздуха " + root.name
        processName: "Давление воздуха " + root.name
        impactName: "Частота вентилятора"
        colorProcess: "#7f9da6"
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

    AnalogSignalVar2 {
        id: pAir1
        objectName: ".pAir1"
        x: 368
        y: 528
        z: 2
        width:  indicWidth
        height: indicHeigth
        anchors.horizontalCenterOffset: -70
        anchors.horizontalCenter: parent.horizontalCenter
        shWidth: 5
        backgroundColor: indicColor
        colorShortName: "DarkOrange"
        tooltipText: "Давление воздуха 1"
        postfix: " кПа"
        confmOnEnter: true
        visible: pAirDuble
        mantissa: 2
        textColor: "#5FDFDF"

    }

    AnalogSignalVar2 {
        id: pAir2
        objectName: ".pAir2"
        x: 368
        y: 528
        z: 2
        width:  indicWidth
        height: indicHeigth
        anchors.horizontalCenterOffset: 70
        anchors.horizontalCenter: parent.horizontalCenter
        shWidth: 5
        backgroundColor: indicColor
        colorShortName: "DarkOrange"
        tooltipText: "Давление воздуха 2"
        postfix: " кПа"
        confmOnEnter: true
        visible: pAirDuble
        mantissa: 2
        textColor: "#5FDFDF"

    }

    Pipe {
        x: 360
        y: 582
        width: 176
        height: 40
        anchors.horizontalCenterOffset: 36
        anchors.horizontalCenter: parent.horizontalCenter
        borderWidth: 2
        nActiveColor: "#0b5467"
    }

    Pipe {
        x: 194
        y: 397
        width: 40
        height: 187
        z: 0
        horOrVert: false
        anchors.horizontalCenterOffset: 80
        anchors.horizontalCenter: parent.horizontalCenter
        nActiveColor: "#0b5467"
    }

    PipeAngle90 {
        x: 305
        y: 567
        width: 50
        height: 60
        anchors.horizontalCenterOffset: -80
        anchors.horizontalCenter: parent.horizontalCenter
        z: 0
        borderWidth: 2
        nActiveColor: "#0b5467"
        pipeThin: 40
        rotation: 90

    }


    Pipe {
        x: 195
        y: 397
        width: 40
        height: 175
        horOrVert: false
        anchors.horizontalCenterOffset: -80
        anchors.horizontalCenter: parent.horizontalCenter
        nActiveColor: "#0b5467"
    }

    Pipe {
        x: 194
        y: 355
        width: 25
        height: 841
        z: 0
        horOrVert: false
        anchors.horizontalCenterOffset: -185
        anchors.horizontalCenter: parent.horizontalCenter
        nActiveColor: pipeGasColor
    }

    Pipe {
        y: 325
        width: 98
        height: 25
        anchors.left: parent.horizontalCenter
        anchors.leftMargin: 70
        borderWidth: 2
        nActiveColor: pipeGasColor
    }

    PipeAngle90 {
        x: 238
        y: 325
        width: 30
        height: 30
        anchors.horizontalCenterOffset: -183
        anchors.horizontalCenter: parent.horizontalCenter
        endAmgle: 90
        pipeThin: 25
        borderWidth: 2
        rotation: 180
        nActiveColor: pipeGasColor
    }

    Pipe {
        x: 232
        y: 325
        width: 93
        height: 25
        anchors.right: parent.horizontalCenter
        anchors.rightMargin: 75
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
        anchors.horizontalCenterOffset: 186
        nActiveColor: pipeGasColor
    }
    Pipe {
        x: 267
        y: 478
        width: 343
        height: 25
        anchors.horizontalCenterOffset: -3
        anchors.horizontalCenter: parent.horizontalCenter
        z: 0
        borderWidth: 2
        nActiveColor: pipeGasColor
    }



    AnalogSignalVar2 {
        id: pGasBV
        x: 368
        y: 486
        width: 90
        height: indicHeigth
        minShow: false
        anchors.horizontalCenterOffset: 2
        anchors.horizontalCenter: parent.horizontalCenter
        backgroundColor: indicColor
        postfix: " кПа"
        shWidth: 5
        objectName:  ".pGasBV"
        colorShortName: "#ff8c00"
        //confmOnEnter: true
        tooltipText: "Давление между клапанами"
        z: 5
        mantissa: 2
        textColor: "#5FDFDF"

    }

    AnalogSignalVar2 {
        id: pGas
        x: 215
        y: 574
        width: 90
        height: indicHeigth
        anchors.horizontalCenterOffset: -183
        anchors.horizontalCenter: parent.horizontalCenter
        backgroundColor: indicColor
        postfix: " кПа"
        shWidth: 5
        objectName: ".pGas"
        colorShortName: "#ff8c00"
        confmOnEnter: true
        tooltipText: "Давление газа"
        z: 5
        mantissa: 2
        textColor: "#5FDFDF"

    }

    PipeAngle90 {
        x: 525
        y: 325
        width: 30
        height: 30
        anchors.horizontalCenterOffset: 183
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
        anchors.horizontalCenterOffset: 20
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
        anchors.horizontalCenterOffset: -20
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
        anchors.horizontalCenterOffset: 183
        anchors.horizontalCenter: parent.horizontalCenter
        nActiveColor: pipeGasColor
        endAmgle: 90
        pipeThin: 25
        rotation: 0
        borderWidth: 2
    }
    Pipe {
        x: 100
        y: 459
        width: 104
        height: 6
        z: 1
        nActiveColor: pipeGasColor
        borderWidth: 1
    }





    PipeAngle90 {
        x: 90
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
        x: 90
        y: 309
        width: 6
        height: 146
        z: 1
        horOrVert: false
        nActiveColor: pipeGasColor
        borderWidth: 1
    }

    PipeAngle180 {
        x: 89
        y: 300
        width: 20
        height: 9
        endAmgle: 180
        nActiveColor: pipeGasColor
        borderWidth: 1
        rotation: 180
        pipeThin: 6

    }


    Pipe {
        x: 155
        y: 501
        width: 49
        height: 6
        borderWidth: 1
        nActiveColor: pipeGasColor
        z: 1
    }

    PipeAngle90 {
        x: 145
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
        x: 145
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
        anchors.horizontalCenterOffset: -252
        anchors.horizontalCenter: parent.horizontalCenter
        nActiveColor: pipeGasColor
        z: 1
    }

    Pipe {
        x: 155
        y: 607
        width: 49
        height: 6
        borderWidth: 1
        nActiveColor: pipeGasColor
        z: 1
    }

    SimpleButton {
        id: btTestGerm
        x: 223
        y: 569
        width: 115
        height: 30
        color: "#a4a4a4"
        radius: 5
        //border.color: "#dfdfdf"
        border.width: 2
        unPressCheckColor: "#bbbbbb"
        lightnessCoef: 1.5
        nameText.verticalAlignment: Text.AlignVCenter
        nameText.horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenterOffset: -325
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
    function alamSoundWork ( Work ){
        if(Work) tmr.start()
        else {
            tmr.stop()
            sound.rotation = 0
        }
    }
    function alamSoundEnable ( Enable ){
        no.visible = ! Enable
    }
    Image {
        id: sound
        x: 211
        y: 88
        width: 50
        height: 52
        visible: true
        property color bim: "gray"
        Timer{
            id: tmr
            repeat: true
            interval: 250
            onTriggered: if(parent.rotation == 0)
                             parent.rotation = 20
                         else
                             parent.rotation = 0

        }
        source: "data:image/svg+xml;utf8,
<svg version=\"1.1\" width=\"50\" height=\"52\" viewBox=\"0 0 50 52\" xml:space=\"preserve\">
<desc></desc>
<defs>
</defs>
<g transform=\"matrix(0.1 0 0 0.1 24.94 25.8)\" id=\"Qi5aHQNjT3S1eEZ4tIiK0\"  >
<g style=\"\" vector-effect=\"non-scaling-stroke\"   >
        <g transform=\"matrix(1 0 0 1 -204.67 -145.42)\" id=\"kHPNhCmTQNJW01P6zac3F\"  >
<path style=\"stroke: none; stroke-width: 1; stroke-dasharray: none; stroke-linecap: butt; stroke-dashoffset: 0; stroke-linejoin: miter; stroke-miterlimit: 4; fill: rgb(195,199,201); fill-rule: nonzero; opacity: 1;\" vector-effect=\"non-scaling-stroke\"  transform=\" translate(-51.33, -110.58)\" d=\"M 51.328 76.466 C 70.177 76.466 85.44300000000001 91.73299999999999 85.44300000000001 110.58099999999999 C 85.44300000000001 129.42899999999997 70.17600000000002 144.696 51.32800000000001 144.696 C 32.480000000000004 144.696 17.213000000000008 129.429 17.213000000000008 110.58099999999999 C 17.213000000000008 91.73299999999998 32.479 76.466 51.328 76.466 z\" stroke-linecap=\"round\" />
</g>
        <g transform=\"matrix(1 0 0 1 51.19 212.79)\" id=\"gjkARXIHzjj9d7tZ-Dh2L\"  >
<path style=\"stroke: none; stroke-width: 1; stroke-dasharray: none; stroke-linecap: butt; stroke-dashoffset: 0; stroke-linejoin: miter; stroke-miterlimit: 4; fill: rgb(49,66,77); fill-rule: nonzero; opacity: 1;\" vector-effect=\"non-scaling-stroke\"  transform=\" translate(-307.19, -468.79)\" d=\"M 452.183 434.677 L 452.183 502.908 L 162.20299999999997 502.908 L 162.20299999999997 434.677 L 204.84699999999998 434.677 L 409.539 434.677 z\" stroke-linecap=\"round\" />
</g>
        <g transform=\"matrix(1 0 0 1 51.19 137.91)\" id=\"ZNfJ8jIZ8LCDeIQL98nJs\"  >
<path style=\"stroke: none; stroke-width: 1; stroke-dasharray: none; stroke-linecap: butt; stroke-dashoffset: 0; stroke-linejoin: miter; stroke-miterlimit: 4; fill: rgb(68,87,100); fill-rule: nonzero; opacity: 1;\" vector-effect=\"non-scaling-stroke\"  transform=\" translate(-307.19, -393.91)\" d=\"M 409.539 353.142 L 409.539 434.677 L 204.847 434.677 L 204.847 353.14200000000005 C 234.27200000000002 372.33200000000005 269.41 383.50500000000005 307.193 383.50500000000005 C 344.975 383.505 380.114 372.332 409.539 353.142 z\" stroke-linecap=\"round\" />
</g>
        <g transform=\"matrix(1 0 0 1 51.19 -60.13)\" id=\"NZOw1RlNYWXkojSB_20tu\"  >
<path style=\"stroke: none; stroke-width: 1; stroke-dasharray: none; stroke-linecap: butt; stroke-dashoffset: 0; stroke-linejoin: miter; stroke-miterlimit: 4; fill: rgb(126,132,136); fill-rule: nonzero; opacity: 1;\" vector-effect=\"non-scaling-stroke\"  transform=\" translate(-307.19, -195.87)\" d=\"M 307.193 136.168 C 340.2 136.168 366.895 162.863 366.895 195.869 C 366.895 228.875 340.2 255.571 307.193 255.571 C 274.186 255.571 247.492 228.876 247.492 195.869 C 247.492 162.862 274.187 136.168 307.193 136.168 z\" stroke-linecap=\"round\" />
</g>
        <g transform=\"matrix(1 0 0 1 51.19 -60.13)\" id=\"CS_0vs9ukOLif8_bxE9BW\"  >
<path style=\"stroke: none; stroke-width: 1; stroke-dasharray: none; stroke-linecap: butt; stroke-dashoffset: 0; stroke-linejoin: miter; stroke-miterlimit: 4; fill: " +bim+/*rgb(255,211,17)*/"; fill-rule: nonzero; opacity: 1;\" vector-effect=\"non-scaling-stroke\"  transform=\" translate(-307.19, -195.87)\" d=\"M 409.539 353.142 C 380.114 372.332 344.976 383.505 307.193 383.505 C 269.40999999999997 383.505 234.272 372.332 204.84699999999998 353.142 C 153.50399999999996 319.709 119.55799999999998 261.712 119.55799999999998 195.87 C 119.55799999999998 92.245 203.56699999999998 8.235000000000014 307.193 8.235000000000014 C 410.81899999999996 8.235000000000014 494.828 92.244 494.828 195.87 C 494.828 261.712 460.882 319.709 409.539 353.142 z M 366.895 195.87 C 366.895 162.864 340.2 136.169 307.193 136.169 C 274.186 136.169 247.492 162.864 247.492 195.87 C 247.492 228.876 274.187 255.572 307.193 255.572 C 340.19899999999996 255.572 366.895 228.876 366.895 195.87 z\" stroke-linecap=\"round\" />
</g>
        <g transform=\"matrix(1 0 0 1 51.19 195.73)\" id=\"-CLz3-XtIHHzTKhqyKw2q\"  >
<path style=\"stroke: none; stroke-width: 1; stroke-dasharray: none; stroke-linecap: butt; stroke-dashoffset: 0; stroke-linejoin: miter; stroke-miterlimit: 4; fill: rgb(30,46,55); fill-rule: nonzero; opacity: 1;\" vector-effect=\"non-scaling-stroke\"  transform=\" translate(-144.99, -17.06)\" d=\"M 0 34.115 L 0 0 L 289.975 0 L 289.975 34.115 z\" stroke-linecap=\"round\" />
</g>
        <g transform=\"matrix(1 0 0 1 51.19 -60.13)\" id=\"oXX93enE2UBCNe7QlhMrg\"  >
<path style=\"stroke: none; stroke-width: 1; stroke-dasharray: none; stroke-linecap: butt; stroke-dashoffset: 0; stroke-linejoin: miter; stroke-miterlimit: 4; fill: rgb(91,96,99); fill-rule: nonzero; opacity: 1;\" vector-effect=\"non-scaling-stroke\"  transform=\" translate(-25.59, -25.59)\" d=\"M 0 25.587 C 0 11.45569 11.45569 0 25.587 0 C 39.71831 0 51.174 11.45569 51.174 25.587 C 51.174 39.71831 39.71831 51.174 25.587 51.174 C 11.45569 51.174 0 39.71831 0 25.587 z\" stroke-linecap=\"round\" />
</g>
        <g transform=\"matrix(1 0 0 1 -21.3 -60.13)\" id=\"58nqgErDry-M8CQ8bhsW1\"  >
<path style=\"stroke: none; stroke-width: 1; stroke-dasharray: none; stroke-linecap: butt; stroke-dashoffset: 0; stroke-linejoin: miter; stroke-miterlimit: 4; fill: rgb(238,238,238); fill-rule: nonzero; opacity: 1;\" vector-effect=\"non-scaling-stroke\"  transform=\" translate(-234.7, -195.87)\" d=\"M 204.847 195.87 C 204.847 106.921 266.766 32.48000000000002 349.837 13.163000000000011 C 336.131 9.976000000000012 321.86899999999997 8.236000000000011 307.193 8.236000000000011 C 203.56799999999998 8.236000000000011 119.55799999999999 92.245 119.55799999999999 195.871 C 119.55799999999999 261.713 153.502 319.709 204.84699999999998 353.14300000000003 C 234.272 372.333 269.40999999999997 383.50600000000003 307.193 383.50600000000003 C 321.873 383.50600000000003 336.135 381.774 349.837 378.58700000000005 C 328.27299999999997 373.5690000000001 308.127 364.87700000000007 290.13599999999997 353.14400000000006 C 238.792 319.709 204.847 261.712 204.847 195.87 z\" stroke-linecap=\"round\" />
</g>
        <g transform=\"matrix(1 0 0 1 0 0)\" id=\"OgW91Wok5FbDE1UFnQJ50\"  >
<path style=\"stroke: none; stroke-width: 1; stroke-dasharray: none; stroke-linecap: butt; stroke-dashoffset: 0; stroke-linejoin: miter; stroke-miterlimit: 4; fill: rgb(0,0,0); fill-rule: nonzero; opacity: 1;\" vector-effect=\"non-scaling-stroke\"  transform=\" translate(-256, -256)\" d=\"M 460.828 426.442 L 418.18399999999997 426.442 L 418.18399999999997 358.18 C 471.67299999999994 321.509 503.472 261.358 503.472 196.299 C 503.472 88.059 415.413 0 307.173 0 C 198.933 0 110.877 88.059 110.877 196.299 C 110.877 261.35900000000004 142.676 321.509 196.165 358.18 L 196.165 392.497 C 182.188 391.01800000000003 152.654 384.716 125.01799999999999 358.28000000000003 C 106.02899999999998 340.117 90.93499999999999 315.46500000000003 80.15899999999999 285.01200000000006 C 67.401 248.96100000000007 60.64899999999999 204.53400000000005 60.03399999999999 152.89300000000006 C 79.45299999999999 148.85300000000007 94.089 131.61000000000007 94.089 111.01100000000005 C 94.089 87.42300000000006 74.899 68.23200000000006 51.309999999999995 68.23200000000006 C 27.72099999999999 68.23200000000006 8.529999999999994 87.42200000000005 8.529999999999994 111.01000000000005 C 8.529999999999994 131.65100000000004 23.223999999999997 148.92400000000004 42.699999999999996 152.91900000000004 C 43.855 254.26400000000004 67.63499999999999 327.684 113.44899999999998 371.19300000000004 C 145.875 401.98800000000006 180.195 408.607 196.164 409.95200000000006 L 196.164 426.44300000000004 L 153.52 426.44300000000004 L 153.52 494.67300000000006 L 111.01000000000002 494.67300000000006 L 111.01000000000002 512.0010000000001 L 503.337 512.0010000000001 L 503.337 494.6730000000001 L 460.827 494.6730000000001 L 460.827 426.442 z M 25.857 111.01 C 25.857 96.977 37.275 85.559 51.308 85.559 C 65.34100000000001 85.559 76.759 96.977 76.759 111.00999999999999 C 76.759 125.04299999999998 65.34100000000001 136.46099999999998 51.308 136.46099999999998 C 37.27499999999999 136.46099999999998 25.857 125.044 25.857 111.01 z M 128.204 196.299 C 128.204 97.614 208.49 17.328000000000003 307.173 17.328000000000003 C 405.858 17.328000000000003 486.144 97.614 486.144 196.299 C 486.144 257.06100000000004 455.733 313.14 404.788 346.31399999999996 C 375.741 365.25699999999995 341.987 375.27 307.173 375.27 C 272.36 375.27 238.607 365.258 209.56 346.31399999999996 L 209.555 346.311 C 158.616 313.14 128.204 257.06 128.204 196.299 z M 400.857 368.803 L 400.857 426.442 L 213.492 426.442 L 213.492 368.803 C 242.148 384.399 274.227 392.598 307.174 392.598 C 340.122 392.596 372.204 384.398 400.857 368.803 z M 443.5 494.672 L 170.848 494.672 L 170.848 443.77 L 443.5 443.77 L 443.5 494.672 z\" stroke-linecap=\"round\" />
</g>
        <g transform=\"matrix(1 0 0 1 51.18 213.23)\" id=\"sMeRNOu_szzn6MgvZgvZO\"  >
<path style=\"stroke: none; stroke-width: 1; stroke-dasharray: none; stroke-linecap: butt; stroke-dashoffset: 0; stroke-linejoin: miter; stroke-miterlimit: 4; fill: rgb(255,255,255); fill-rule: nonzero; opacity: 1;\" vector-effect=\"non-scaling-stroke\"  transform=\" translate(-76.76, -8.66)\" d=\"M 0 17.328 L 0 0 L 153.524 0 L 153.524 17.328 z\" stroke-linecap=\"round\" />
</g>
        <g transform=\"matrix(1 0 0 1 153.52 213.23)\" id=\"OGiOZ-O-Pm0PrHd5etiNS\"  >
<path style=\"stroke: none; stroke-width: 1; stroke-dasharray: none; stroke-linecap: butt; stroke-dashoffset: 0; stroke-linejoin: miter; stroke-miterlimit: 4; fill: rgb(0,0,0); fill-rule: nonzero; opacity: 1;\" vector-effect=\"non-scaling-stroke\"  transform=\" translate(-8.53, -8.66)\" d=\"M 0 17.328 L 0 0 L 17.059 0 L 17.059 17.328 z\" stroke-linecap=\"round\" />
</g>
        <g transform=\"matrix(1 0 0 1 -51.17 213.23)\" id=\"zPq1X5CtzB4h4Cc8STCbU\"  >
<path style=\"stroke: none; stroke-width: 1; stroke-dasharray: none; stroke-linecap: butt; stroke-dashoffset: 0; stroke-linejoin: miter; stroke-miterlimit: 4; fill: rgb(0,0,0); fill-rule: nonzero; opacity: 1;\" vector-effect=\"non-scaling-stroke\"  transform=\" translate(-8.53, -8.66)\" d=\"M 0 17.328 L 0 0 L 17.058 0 L 17.058 17.328 z\" stroke-linecap=\"round\" />
</g>
        <g transform=\"matrix(1 0 0 1 51.17 -59.7)\" id=\"FSFsJ5BZSMAMebxN5rhvw\"  >
<path style=\"stroke: none; stroke-width: 1; stroke-dasharray: none; stroke-linecap: butt; stroke-dashoffset: 0; stroke-linejoin: miter; stroke-miterlimit: 4; fill: rgb(0,0,0); fill-rule: nonzero; opacity: 1;\" vector-effect=\"non-scaling-stroke\"  transform=\" translate(-307.17, -196.3)\" d=\"M 238.809 196.299 C 238.809 233.996 269.477 264.665 307.174 264.665 C 344.871 264.665 375.53999999999996 233.996 375.53999999999996 196.29900000000004 C 375.53999999999996 158.60200000000006 344.871 127.93300000000004 307.174 127.93300000000004 C 269.477 127.93300000000004 238.809 158.602 238.809 196.299 z M 358.212 196.299 C 358.212 224.442 335.317 247.337 307.173 247.337 C 279.031 247.337 256.136 224.44099999999997 256.136 196.298 C 256.136 168.15500000000003 279.031 145.25900000000001 307.173 145.25900000000001 C 335.317 145.26 358.212 168.156 358.212 196.299 z\" stroke-linecap=\"round\" />
</g>
        <g transform=\"matrix(1 0 0 1 51.17 -59.7)\" id=\"8vJW_9UZZ2EDCNeCSHvmY\"  >
<path style=\"stroke: none; stroke-width: 1; stroke-dasharray: none; stroke-linecap: butt; stroke-dashoffset: 0; stroke-linejoin: miter; stroke-miterlimit: 4; fill: rgb(0,0,0); fill-rule: nonzero; opacity: 1;\" vector-effect=\"non-scaling-stroke\"  transform=\" translate(-307.17, -196.3)\" d=\"M 290.252 196.299 C 290.252 186.967 297.843 179.377 307.173 179.377 L 307.173 162.049 C 288.287 162.049 272.924 177.413 272.924 196.299 C 272.924 215.185 288.28799999999995 230.549 307.173 230.549 C 326.05800000000005 230.549 341.423 215.184 341.423 196.299 L 324.095 196.299 C 324.095 205.631 316.504 213.221 307.173 213.221 C 297.843 213.221 290.252 205.629 290.252 196.299 z\" stroke-linecap=\"round\" />
</g>
        <g transform=\"matrix(1 0 0 1 -17.13 -128)\" id=\"FMgcaAoljZ6zVRvZHTeZX\"  >
<path style=\"stroke: none; stroke-width: 1; stroke-dasharray: none; stroke-linecap: butt; stroke-dashoffset: 0; stroke-linejoin: miter; stroke-miterlimit: 4; fill: rgb(255,255,255); fill-rule: nonzero; opacity: 1;\" vector-effect=\"non-scaling-stroke\"  transform=\" translate(-238.88, -128)\" d=\"M 307.173 77.03 L 307.173 59.702 C 231.85399999999998 59.702 170.577 120.979 170.577 196.298 L 187.905 196.298 C 187.905 130.534 241.409 77.03 307.173 77.03 z\" stroke-linecap=\"round\" />
</g>
        <g transform=\"matrix(1 0 0 1 119.47 8.6)\" id=\"IP6lwVHccK3ro3TSiCOIP\"  >
<path style=\"stroke: none; stroke-width: 1; stroke-dasharray: none; stroke-linecap: butt; stroke-dashoffset: 0; stroke-linejoin: miter; stroke-miterlimit: 4; fill: rgb(0,0,0); fill-rule: nonzero; opacity: 1;\" vector-effect=\"non-scaling-stroke\"  transform=\" translate(-375.47, -264.6)\" d=\"M 307.173 332.895 C 382.492 332.895 443.769 271.618 443.769 196.29899999999998 L 426.44100000000003 196.29899999999998 C 426.44100000000003 262.06399999999996 372.937 315.568 307.172 315.568 L 307.172 332.895 z\" stroke-linecap=\"round\" />
</g>
        <g transform=\"matrix(1 0 0 1 -76.76 -34.11)\" id=\"2Lit14yiFkJHPXndHhV_u\"  >
<path style=\"stroke: none; stroke-width: 1; stroke-dasharray: none; stroke-linecap: butt; stroke-dashoffset: 0; stroke-linejoin: miter; stroke-miterlimit: 4; fill: rgb(0,0,0); fill-rule: nonzero; opacity: 1;\" vector-effect=\"non-scaling-stroke\"  transform=\" translate(-8.53, -8.66)\" d=\"M 0 17.328 L 0 0 L 17.059 0 L 17.059 17.328 z\" stroke-linecap=\"round\" />
</g>
        <g transform=\"matrix(1 0 0 1 179.11 -85.29)\" id=\"SxqYM1yk7yxk7maFjF4PL\"  >
<path style=\"stroke: none; stroke-width: 1; stroke-dasharray: none; stroke-linecap: butt; stroke-dashoffset: 0; stroke-linejoin: miter; stroke-miterlimit: 4; fill: rgb(255,255,255); fill-rule: nonzero; opacity: 1;\" vector-effect=\"non-scaling-stroke\"  transform=\" translate(-8.53, -8.66)\" d=\"M 0 17.328 L 0 0 L 17.059 0 L 17.059 17.328 z\" stroke-linecap=\"round\" />
</g>
        <g transform=\"matrix(1 0 0 1 -204.69 -144.99)\" id=\"qQh603jnsycp0CL9KSjul\"  >
<path style=\"stroke: none; stroke-width: 1; stroke-dasharray: none; stroke-linecap: butt; stroke-dashoffset: 0; stroke-linejoin: miter; stroke-miterlimit: 4; fill: rgb(255,255,255); fill-rule: nonzero; opacity: 1;\" vector-effect=\"non-scaling-stroke\"  transform=\" translate(-8.53, -8.66)\" d=\"M 0 17.328 L 0 0 L 17.059 0 L 17.059 17.328 z\" stroke-linecap=\"round\" />
</g>
</g>
</g>
</svg>"
        smooth: false
        sourceSize.height: 52
        sourceSize.width: 50
    }
    Image {
        id: no
        x: 195
        y: 74
        width: 82
        height: 79
        visible: false
        source: "No.svg"
        sourceSize.height: 64
        sourceSize.width: 64
    }

}


/*##^##
Designer {
    D{i:0}D{i:2;locked:true}D{i:4;locked:true}D{i:63;locked:true}D{i:62;locked:true}D{i:66;locked:true}
D{i:65;locked:true}D{i:69;locked:true}D{i:68;locked:true}D{i:76;locked:true}D{i:75;locked:true}
D{i:79;locked:true}D{i:78;locked:true}D{i:85;locked:true}D{i:84;locked:true}D{i:88;locked:true}
D{i:87;locked:true}D{i:121}
}
##^##*/
