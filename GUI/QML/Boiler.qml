import QtQuick 2.12
import "fap.js" as Fap

UnitPropItem {
    id: root
    width: 390
    height: 800
    alarmNotify: true
    connected: true
    linked: true
    alarm: true
    description: "Котел №"
    borderWidth: 2

    property alias tank: tankWater
    property alias pidPTop: pidPTop

    property int colderDiametr: width

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
    property color indicColor: "gray"


    property bool adminView: false
    property bool fullView: true

    backgroundColor: "#d3d3d3"
    allovAlarmBodyBlinck: false
    allovAlarmBorderBlinck: true

    Rectangle{
        y: 94
        width: 380
        height: 310
        color: "#d3d3d3"
        radius: 10
        //color: parent.backgroundCurrecntColor
        border.color: parent.borderCurrentColor
        border.width: 2
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter
    }

    MouseArea {
        id: mousAr
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

    Tank {
        id: tankWater
        x: 330
        y: 58
        width: 140
        height: 140
        radius: width / 2
        anchors.horizontalCenter: parent.horizontalCenter
        borderWidth: 2
        z: 10
        objectName:  "tankWater"
        level: 90
        levelRatio: 1
        showSeam: false
        showAlarmLevel: true
        showLevel: true
        nameText.text: ""
        function setLvlAlarm(Discr){
            levelText.color = textAlarmColor
        }
        function setLvlAlarmReseted(){
            levelText.color = levelTextColor
        }
    }
    SimpleButton{
        id: sbPrBurner
        y: 409
        radius: height / 2
        border.color: "#000000"
        anchors.horizontalCenterOffset: -3
        width: indicHeigth * 1.5
        height: width
        visible: true
        checkable: true
        anchors.horizontalCenter: parent.horizontalCenter
        nameText.text: "A"
        nameText.verticalAlignment: Text.AlignVCenter
        nameText.horizontalAlignment: Text.AlignHCenter
        pressCheckColor: "gray"
        unPressCheckColor: Fap.run
        mouseArea.onClicked:{
            if( mouse.button & Qt.RightButton ){
                pidPBott.show()
            }
        }
        onS_checkedUserChanged: pidPBott.s_manOn(Checked)
    }
    RegulValveUnit {
        id: burner1_vGas
        objectName:  "burner1.vGas"
        name: "РК1"
        x: 232
        y: 527
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
        regValve.nameOnTop: false
    }
    RegulValveUnit {
        id: burner2_vGas
        objectName:  "burner2.vGas"
        name: "РК2"
        x: 523
        y: 527
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
        regValve.nameOnLeft: false
        regValve.nameOnTop: false
    }
    Fan {
        id: ventAir
        name: "ВВ"
        x: 512
        y: 655
        z: 100
        width: 78
        height: 90
        anchors.horizontalCenterOffset: 143
        anchors.horizontalCenter: parent.horizontalCenter
        alarmNotify: false
        rotatePict: 90
        rotation: 0
        connected: true
        linked: true
        flanWidth: 40
        fanName.font.pointSize: 20
        borderWidth: 2
        objectName:  "ventAir"
        mirror: true
    }
    Fan {
        id: ventSmoke
        name: "ВД"
        x: 476
        y: 33
        z: 0
        width: 100
        height: 120
        anchors.horizontalCenterOffset: -126
        anchors.horizontalCenter: parent.horizontalCenter
        fanName.font.pointSize: 20
        rotatePict: 0
        rotation: 0
        connected: true
        linked: true
        flanWidth: 40
        borderWidth: 2
        objectName:  "ventSmoke"
        mirror: true
    }

    StartStopUnit {
        id: vGasCloser
        objectName:  "vGasCloser"
        name: "КЗГ"
        x: 222
        y: 630
        z: 1
        width: 60
        height: 54
        anchors.horizontalCenterOffset: -143
        anchors.horizontalCenter: parent.horizontalCenter
        onStdChanged: textColor = std ? "Black" : "White"
        borderWidth: 2
        Rectangle {
            id: rect2
            radius: 3
            color: parent.backgroundCurrentColor
            border.color: parent.borderCurrentColor
            border.width: parent.borderCurrentWidth
            anchors.fill: parent
        }

        Text {
            id: nameTextVGC
            text: parent.name
            anchors.fill: rect2
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.leftMargin: 6
            fontSizeMode: Text.Fit
            anchors.rightMargin: 6
            minimumPixelSize: 10
            anchors.topMargin: 3
            anchors.bottomMargin: 3
            font.pointSize: 300
            minimumPointSize: 10
            color: "White"
        }
        onTextCurrentColorChanged: { nameTextVGC.color = textCurrentColor }
        colorRun: "#ffd700"
        connected: true
        colorStopReady: "#000000"
        linked: true
    }

    StartStopUnit {
        id: burner1_vGasCloser
        objectName:  "burner1.vGasCloser"
        name: "КГ1"
        x: 225
        y: 491
        width: 50
        height: 30
        anchors.horizontalCenterOffset: -143
        anchors.horizontalCenter: parent.horizontalCenter
        z: 1
        colorStopReady: "Black"
        colorRun: "Gold"
        linked: true
        connected: true
        borderWidth: 2
        onStdChanged: textColor = std ? "Black" : "White"
        Rectangle {
            id: rect
            color: parent.backgroundCurrentColor
            radius: 3
            border.color: parent.borderCurrentColor
            border.width: parent.borderWidth
            anchors.fill: parent
        }

        Text {
            id: nameTextVGC1
            text: parent.name
            anchors.fill: rect
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            minimumPointSize: 10
            font.pointSize: 300
            anchors.leftMargin: 6
            fontSizeMode: Text.Fit
            anchors.rightMargin: 6
            anchors.topMargin: 3
            anchors.bottomMargin: 3
            minimumPixelSize: 10
            color: "White"
        }
        onTextCurrentColorChanged: { nameTextVGC1.color = textCurrentColor }
    }

    StartStopUnit {
        id: burner2_vGasCloser
        objectName:  "burner2.vGasCloser"
        name: "КГ2"
        x: 520
        y: 491
        z: 50
        width: 50
        height: 30
        anchors.horizontalCenterOffset: 143
        anchors.horizontalCenter: parent.horizontalCenter
        onStdChanged: textColor = std ? "Black" : "White"
        borderWidth: 2
        Rectangle {
            id: rect1
            color: parent.backgroundCurrentColor
            radius: 3
            border.color: parent.borderCurrentColor
            border.width: parent.borderWidth
            anchors.fill: parent
        }

        Text {
            id: nameTextVGC2
            text: parent.name
            anchors.fill: rect1
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.leftMargin: 6
            fontSizeMode: Text.Fit
            anchors.rightMargin: 6
            minimumPixelSize: 10
            anchors.topMargin: 3
            anchors.bottomMargin: 3
            font.pointSize: 300
            color: "White"
        }
        onTextCurrentColorChanged: { nameTextVGC2.color = textCurrentColor }
        colorRun: "#ffd700"
        connected: true
        colorStopReady: "#000000"
        linked: true
    }
    AnalogSignalVar2 {
        id: burner1_pGas
        objectName:  "burner1.vGas"
        x: 212
        y: 424
        z: 5
        width: 70
        height: indicHeigth
        anchors.horizontalCenterOffset: -150
        anchors.horizontalCenter: parent.horizontalCenter
        shWidth: 5
        backgroundColor: indicColor
        colorShortName: "DarkOrange"
        postfix: "кПа"
        tooltipText: "Давление горелка 1"
        confmOnEnter: true
    }

    AnalogSignalVar2 {
        id: burner2_pGas
        objectName:  "burner2.vGas"
        x: 519
        y: 424
        z: 5
        width: 70
        height: indicHeigth
        anchors.horizontalCenterOffset: 150
        anchors.horizontalCenter: parent.horizontalCenter
        shWidth: 5
        backgroundColor: indicColor
        colorShortName: "DarkOrange"
        postfix: "кПа"//"°c"
        tooltipText: "Давление горелка 2"
        confmOnEnter: true
    }

    AnalogSignalVar2 {
        id: pAir
        objectName: "tWater"
        x: 368
        y: 674
        z: 2
        width:  indicWidth
        height: indicHeigth
        anchors.horizontalCenterOffset: -3
        anchors.horizontalCenter: parent.horizontalCenter
        shWidth: 5
        backgroundColor: indicColor
        colorShortName: "DarkOrange"
        tooltipText: "Температура отходящей воды"
        postfix: "кПа"
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
                    pidPBott.show()
                }
            }
            onS_checkedUserChanged: pidPBott.s_manOn(Checked)
        }
    }

    Image {
        id: boilerIm
        x: 147
        y: 104
        width: 372
        height: 292
        visible: true
        source: "boiler.svg"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: 0
        sourceSize.width: parent.width
        sourceSize.height: parent.height

    }
    Image {
        id: flame1
        x: 341
        y: 204
        width: 120
        height: 160
        visible: true
        source: "burn-fire.svg"
        anchors.horizontalCenterOffset: -70
        anchors.horizontalCenter: parent.horizontalCenter
        sourceSize.width: parent.width
        sourceSize.height: parent.height
    }

    Image {
        id: flame2
        x: 410
        y: 204
        width: 120
        height: 160
        visible: true
        source: "burn-fire.svg"
        anchors.horizontalCenterOffset: 70
        anchors.horizontalCenter: parent.horizontalCenter
        sourceSize.width: parent.width
        sourceSize.height: parent.height
    }
    Image {
        id: ligtning1
        x: 295
        y: 369
        width: 55
        height: 63
        visible: true
        source: "lightning.svg"
        anchors.horizontalCenterOffset: -70
        anchors.horizontalCenter: parent.horizontalCenter
        z: 1
        sourceSize.width: parent.width
        sourceSize.height: parent.height
    }
    Image {
        id: ligtning2
        x: 443
        y: 369
        width: 55
        height: 63
        visible: true
        source: "lightning.svg"
        anchors.horizontalCenterOffset: 70
        anchors.horizontalCenter: parent.horizontalCenter
        z: 1
        sourceSize.width: parent.width
        sourceSize.height: parent.height
    }

    Pipe {
        x: 194
        y: 514
        width: 40
        height: 187
        z: 1
        horOrVert: false
        anchors.horizontalCenterOffset: 70
        anchors.horizontalCenter: parent.horizontalCenter
        nActiveColor: "#00bfff"
    }

    PipeAngle90 {
        x: 305
        y: 684
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
        x: 360
        y: 699
        width: 158
        height: 40
        anchors.horizontalCenterOffset: 36
        anchors.horizontalCenter: parent.horizontalCenter
        borderWidth: 2
        nActiveColor: "DeepSkyBlue"
    }

    Pipe {
        x: 195
        y: 514
        width: 40
        height: 175
        horOrVert: false
        anchors.horizontalCenterOffset: -70
        anchors.horizontalCenter: parent.horizontalCenter
        nActiveColor: "#00bfff"
    }

    Pipe {
        x: 194
        y: 472
        width: 25
        height: 267
        z: 0
        horOrVert: false
        anchors.horizontalCenterOffset: -143
        anchors.horizontalCenter: parent.horizontalCenter
        nActiveColor: pipeGasColor
    }

    Pipe {
        x: 480
        y: 442
        width: 46
        height: 25
        anchors.horizontalCenterOffset: 103
        anchors.horizontalCenter: parent.horizontalCenter
        borderWidth: 2
        nActiveColor: pipeGasColor
    }
    AnalogSignalVar2 {
        id: tSmoke
        x: 525
        y: 18
        width: 70
        objectName: "tSmoke"
        height: indicHeigth
        visible: true
        anchors.horizontalCenterOffset: -121
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
    PID_Win{
        id: pidPTop
        title: "ПИД давления верха " + root.name
        processName: "Давление верха " + root.name
        impactName: "Положение клапана охл. воды"
        objectName:  "pTopPID"
        colorImpact: pipeOutWaterColor
        colorProcess: "yellow"
        impIsOut: false
        mfuToProcess.valueReal: 3
        mfuToImpact.valueReal: 100
        mfuImpact.separCorrButtons: true
        mfuKpOut.visible: fullView
        mfuKiOut.visible: fullView
        mfuKdOut.visible: false
        mfuProcess.mantissa: 2
        mfuSetPt.mantissa: 2
        mfuFromProcess.mantissa: 2
        mfuFromImpact.mantissa: 2
        mfuImpact.mantissa: 2
        kdRow.visible: false
        onManOnOffChanged: sbPTop.checked = manOnOff
        Component.onCompleted: sbPTop.checked = manOnOff
        adminView: parent.adminView
        confmOnEnter: true
    }

    PID_Win{
        id: pidPBott
        title: "ПИД давления в кубе" + root.name
        processName: "Давление в кубе " + root.name
        impactName: "Положение клапана пара"
        objectName:  "pBottomPID"
        colorImpact: pipeSteamColor
        colorProcess: "yellow"
        impIsOut: false
        mfuToProcess.valueReal: 3
        mfuToImpact.valueReal: 100
        mfuImpact.separCorrButtons: true
        mfuKpOut.visible: fullView
        mfuKiOut.visible: fullView
        mfuKdOut.visible: false
        mfuProcess.mantissa: 2
        mfuSetPt.mantissa: 2
        mfuFromProcess.mantissa: 2
        mfuFromImpact.mantissa: 2
        mfuImpact.mantissa: 2
        kdRow.visible: false
        adminView: parent.adminView
        onManOnOffChanged: { sbPrButt.checked = manOnOff }
        Component.onCompleted: sbPrButt.checked = manOnOff
        confmOnEnter: true
    }

    PipeAngle90 {
        x: 238
        y: 442
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
        y: 442
        width: 46
        height: 25
        anchors.horizontalCenterOffset: -103
        anchors.horizontalCenter: parent.horizontalCenter
        borderWidth: 2
        nActiveColor: pipeGasColor
    }

    Pipe {
        x: 190
        y: 472
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
        y: 595
        width: 259
        height: 25
        anchors.horizontalCenterOffset: -3
        anchors.horizontalCenter: parent.horizontalCenter
        z: 1
        borderWidth: 2
        nActiveColor: pipeGasColor
    }

    Rectangle {
        x: 450
        y: 455
        width: 40
        height: 60
        color: "#cd2e2e"
        radius: 0
        border.width: 2
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
            border.width: 2
            anchors.top: parent.top
            Rectangle {
                width: 7
                height: 7
                color: parent.color
                radius: 30
                border.width: 1
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                z: 100
            }
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: -20
        }
    }

    Rectangle {
        id: rectangle
        x: 310
        y: 455
        width: 40
        height: 60
        color: "#cd2e2e"
        radius: 0
        border.width: 2
        anchors.horizontalCenterOffset: -70
        anchors.horizontalCenter: parent.horizontalCenter
        z: 3
        Rectangle{
            width: 40
            height: 40
            color: parent.color
            radius: 30
            border.width: 2
            anchors.top: parent.top
            anchors.topMargin: -20
            anchors.horizontalCenter: parent.horizontalCenter
            z: 100
            Rectangle {
                width: 7
                height: 7
                color: parent.color
                radius: 30
                border.width: 1
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
    Rectangle {
        x: 355
        y: 451
        width: 10
        height: 60
        color: "#b9b9b9"
        radius: 0
        border.width: 2
        anchors.horizontalCenterOffset: -44
        anchors.horizontalCenter: parent.horizontalCenter
        rotation: -45
        z: 2

        Text {
            text: "З1"
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

    AnalogSignalVar2 {
        id: pGasBV
        x: 368
        y: 603
        width: 70
        height: indicHeigth
        anchors.horizontalCenter: parent.horizontalCenter
        backgroundColor: indicColor
        postfix: "кПа"
        shWidth: 5
        objectName:  "pGasBV"
        colorShortName: "#ff8c00"
        confmOnEnter: true
        tooltipText: "Давление между клапанами"
        z: 5
    }

    AnalogSignalVar2 {
        id: vGasCloserMain
        x: 215
        y: 704
        width: 70
        height: indicHeigth
        anchors.horizontalCenterOffset: -143
        anchors.horizontalCenter: parent.horizontalCenter
        backgroundColor: indicColor
        postfix: "кПа"
        shWidth: 5
        objectName:  "vGasCloser"
        colorShortName: "#ff8c00"
        confmOnEnter: true
        tooltipText: "Давление между клапанами"
        z: 5
    }

    PipeAngle90 {
        x: 525
        y: 442
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
        y: 495
        width: 6
        height: 102
        anchors.horizontalCenterOffset: 26
        nActiveColor: pipeGasColor
        anchors.horizontalCenter: parent.horizontalCenter
        horOrVert: false
        z: 1
    }

    Pipe {
        x: 190
        y: 495
        width: 6
        height: 102
        anchors.horizontalCenterOffset: -26
        nActiveColor: pipeGasColor
        anchors.horizontalCenter: parent.horizontalCenter
        horOrVert: false
        z: 1
    }

    PipeAngle90 {
        x: 525
        y: 590
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

    StartStopUnit {
        id: ignition1_vGasCloser1
        name: "КЗ1"
        x: 354
        y: 547
        width: 34
        height: 20
        anchors.horizontalCenterOffset: -26
        anchors.horizontalCenter: parent.horizontalCenter
        objectName:  "ignition1.vGasCloser"
        Rectangle {
            id: rect3
            color: parent.backgroundCurrentColor
            radius: 3
            border.color: parent.borderCurrentColor
            border.width: parent.borderWidth
            anchors.fill: parent
        }

        Text {
            id: nameTextVGC3
            color: "#ffffff"
            text: parent.name
            anchors.fill: rect3
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            fontSizeMode: Text.Fit
            font.pointSize: 300
            anchors.leftMargin: 6
            anchors.bottomMargin: 3
            anchors.rightMargin: 6
            minimumPointSize: 10
            anchors.topMargin: 3
            minimumPixelSize: 10
        }
        colorStopReady: "#000000"
        linked: true
        z: 1
        colorRun: "#ffd700"
        connected: true
        borderWidth: 2
    }

    StartStopUnit {
        id: ignition2_vGasCloser
        name: "КЗ2"
        x: 409
        y: 547
        width: 34
        height: 20
        anchors.horizontalCenterOffset: 26
        anchors.horizontalCenter: parent.horizontalCenter
        objectName:  "ignition2.vGasCloser"
        Rectangle {
            id: rect4
            color: parent.backgroundCurrentColor
            radius: 3
            border.color: parent.borderCurrentColor
            border.width: parent.borderWidth
            anchors.fill: parent
        }

        Text {
            id: nameTextVGC4
            color: "#ffffff"
            text: parent.name
            anchors.fill: rect4
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            fontSizeMode: Text.Fit
            font.pointSize: 300
            anchors.leftMargin: 6
            anchors.bottomMargin: 3
            anchors.rightMargin: 6
            minimumPointSize: 10
            anchors.topMargin: 3
            minimumPixelSize: 10
        }
        colorStopReady: "#000000"
        linked: true
        z: 1
        colorRun: "#ffd700"
        connected: true
        borderWidth: 2
    }

    Rectangle {
        x: 431
        y: 451
        width: 10
        height: 60
        color: "#b9b9b9"
        radius: 0
        border.width: 2
        anchors.horizontalCenterOffset: 44
        anchors.horizontalCenter: parent.horizontalCenter
        rotation: 45
        z: 1

        Text {
            text: "З2"
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

    AnalogSignalVar2 {
        id: burner1_pGas1
        x: 368
        y: 68
        width: 70
        height: indicHeigth
        anchors.horizontalCenterOffset: 77
        anchors.horizontalCenter: parent.horizontalCenter
        objectName: "burner1.vGas"
        confmOnEnter: true
        postfix: "кПа"
        shWidth: 5
        z: 10
        tooltipText: "Давление горелка 1"
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
                    pidPBott.show()
                }
            }
            onS_checkedUserChanged: pidPBott.s_manOn(Checked)
        }
    }
}







/*##^##
Designer {
    D{i:0;formeditorZoom:1.25}D{i:5;locked:true}D{i:10;locked:true}D{i:11;locked:true}
D{i:13;locked:true}D{i:14;locked:true}D{i:22;locked:true}
}
##^##*/
