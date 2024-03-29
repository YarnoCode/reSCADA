﻿import QtQuick 2.12
import "fap.js" as Fap

UnitPropItem {
    id: root
    width: 70
    height: 520
    property alias tank: cube
    property alias tWater: tWater
    property alias pidPTop: pidPTop
    property alias sbPTop: sbPTop

    property int colderDiametr: width

    property int indicWidth: 70
    property int indicHeigth: 30

    property int valveNameSize: 10
    property int pipePassThin: 4
    property color pipePassColor: "white"
    property int pipePassBorderWidth: 1

    property int pipeSteamThin: 5
    property color pipeSteamColor: "white" //element.colorSteam
    property int pipeOutWaterThin: 5
    property color pipeOutWaterColor: "white" //element.colorCoolWoter
    property int pipeBorderWidth: 1
    property color indicColor: "gray"

    property bool adminView: false
    property bool fullView: true

    property alias sbPrBottom: sbPrButt

    signal s_manTopOn(variant ManOn)
    backgroundColor: "#d3d3d3"
    allovAlarmBodyBlinck: false
    allovAlarmBorderBlinck: true

    //++++++++ Test +++++++
    //    mouseArea.onPressAndHold: {
    //        linked = true
    //        connected = true
    //        allovAlarmBodyBlinck = true
    //        setQuitAlarm()
    //        var cl = tank.mainGradientColor
    //        cl = backgroundCurrentColor
    //    }
    //------ Test ------
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
    Tank {
        id: cube
        radius: 10
        objectName: "tank"
        anchors.fill: parent
        level: 90
        levelRatio: 0.03
        mainGradientColor: backgroundCurrentColor
        borderColor: borderCurrentColor
        borderWidth: borderCurrentWidth
        function setLvlAlarm(Discr){
            levelText.color = textAlarmColor
        }
        function setLvlAlarmReseted(){
            levelText.color = levelTextColor
        }
//        Timer{
//            id: blinc
//            interval: Fap.blinkDelay
//            running: false
//            repeat: true
//            onTriggered:{

//            }
//        }

    }
    AnalogSignalVar2 {
        id: tTop
        objectName: "tTop"
        height: indicHeigth
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        z: 0
        shWidth: 5
        //shHeight: 15
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        anchors.topMargin: cube.radius * 1.5
        backgroundColor: indicColor
        colorShortName: "green"
        postfix: "°c"
        tooltipText: "Температура верха"
        confmOnEnter: true
    }
    AnalogSignalVar2 {
        id: pTop
        objectName:  "pTop"
        height: indicHeigth
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: tTop.bottom
        z: 0
        limitStep: 0.05
        shWidth: 5
        //shHeight: 15
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        anchors.topMargin: 4
        backgroundColor: indicColor
        colorShortName: "orange"
        //shortNameText: "P"
        postfix: "м"
        tooltipText: "Давление верха"
        mantissa: 2
        confmOnEnter: true

        SimpleButton{
            id: sbPTop
            radius: height / 2
            border.color: "#000000"
            width: parent.height * 1.5
            height: width
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
                    pidPTop.show()
                }
            }
            onS_checkedUserChanged: {
                s_manTopOn(Checked)
                pidPTop.s_manOn(Checked)
            }
        }
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

    AnalogSignalVar2 {
        id: tWater
        objectName: "tWater"
        y: -123
        width:  indicWidth
        height: indicHeigth
        anchors.right: parent.left
        shWidth: 5
        //shHeight: 15
        backgroundColor: indicColor
        anchors.rightMargin: 0
        colorShortName: "#008000"
        tooltipText: "Температура отходящей воды"
        postfix: "°c"
        confmOnEnter: true
        //        shLeft: false
        //        shRight: false
        //        shTop: true
    }
    AnalogSignalVar2 {
        id: pBottom
        objectName:  "pBottom"
        height: indicHeigth
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        limitStep: 0.05
        shWidth: 5
        //shHeight: 15
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        anchors.bottomMargin: cube.height * cube.levelRatio + 15
        backgroundColor: indicColor
        colorShortName: "orange"
        //shortNameText: "P"
        postfix: "м"
        tooltipText: "Давление в кубе"
        mantissa: 2
        confmOnEnter: true

        SimpleButton{
            id: sbPrButt
            radius: height / 2
            border.color: "#000000"
            width: parent.height * 1.5
            height: width
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
    AnalogSignalVar2 {
        id: tBottom
        objectName:  "tBottom"
        y: 240
        height: indicHeigth
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: pBottom.top

        z: 5
        shWidth: 5
        //shHeight: 15
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        anchors.bottomMargin: 4
        backgroundColor: indicColor
        colorShortName: "green"
        postfix: "°c"
        tooltipText: "Температура в кубе"
        confmOnEnter: true
    }
}




