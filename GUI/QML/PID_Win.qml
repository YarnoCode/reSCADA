﻿import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    id: wind
    width: 314
    height: 375
    title: "ПИД регулятор"
    flags:/* Qt.Window |*/ Qt.Dialog
    color: "#ced5d6"
    property alias mfuProcess: mfuProcess
    property alias mfuSetPt: mfuSetPt

    property alias mfuFromImpact: mfuFromImpact
    property alias mfuToImpact: mfuToImpact
    property alias mfuFromProcess: mfuFromProcess
    property alias mfuToProcess: mfuToProcess

    property alias mfuKpOut: mfuKpOut
    property alias mfuKiOut: mfuKiOut
    property alias mfuKdOut: mfuKdOut

    property alias mfuImpact: mfuImpact
    property alias kdRow: kdRow
    property alias kiRow: kiRow
    property alias kpRow: kpRow

    property string processName: "Температура куба РК1"
    property string impactName: "Положение клапана подачи пара"

    property alias manOnOff: switchOnOff.checked

    property color colorProcess: "YellowGreen"
    property color colorSetPt: "black"
    property color colorImpact: "DarkGoldenRod"

    property bool adminView: false

    //    property alias process: mfuProcess.valueReal
    //    property alias setPt: mfuSetPt.valueReal
    //    property alias impact: mfuImpact.valueReal

    //    property alias kp: mfuKp.valueReal
    //    property alias ki: mfuKi.valueReal
    //    property alias kd: mfuKd.valueReal

    //    property alias kpOut: mfuKpOut.valueReal
    //    property alias kiOut: mfuKiOut.valueReal
    //    property alias kdOut: mfuKdOut.valueReal

    property bool impIsAnlgOut: true
    property bool impIs2DisctOuts: false
    property bool confmOnEnter: false

    signal s_manOn( variant ManOn )
    function setManOn( ManOn ){ switchOnOff.checked = ManOn }



    signal s_KpChanged( variant Kp )
    signal s_KiChanged( variant Ki )
    signal s_KdChanged( variant Kd )

    function setKp( Kp ) { mfuKp.setValue(Kp) }
    function setKi( Ki ) { mfuKi.setValue(Ki) }
    function setKd( Kd ) { mfuKd.setValue(Kd) }

    function setKpOut( KpOut ) { mfuKpOut.setValue(KpOut) }
    function setKiOut( KiOut ) { mfuKiOut.setValue(KiOut) }
    function setKdOut( KdOut ) { mfuKdOut.setValue(KdOut) }

    function setProcess ( Process  ) { mfuProcess.setValue(Process) }

    signal s_setPtChanged( variant SetPt )
    function setSetPt ( SetPt ) { mfuSetPt.setValue(SetPt) }
    signal s_setPtMaxChanged(variant SetPtMax)
    function setSetPtMax ( SetPtMax ) { mfuToProcess.setValue(SetPtMax) }
    signal s_setPtMinChanged(variant SetPtMin)
    function setSetPtMin ( SetPtMin ) { mfuFromProcess.setValue(SetPtMin) }

    signal s_impactChanged( variant Impact )
    function setImpact( Impact ) { mfuImpact.setValue(Impact) }
    signal s_impMore( variant More )
    signal s_impLess( variant Less )
    signal s_impulseOn( variant ImpulseOn )
    function setImpulseOn( ImpulseOn ){ impulsOnOff.checked = ImpulseOn }

    signal s_manImpactChanged( variant ManImp)
    function setManImpact ( ManImp ) { mfuManImpact.setValue(ManImp) }

    signal s_impactMaxChanged(variant ImpactMax)
    function setImpactMax ( ImpactMax ) { mfuToImpact.setValue(ImpactMax) }
    signal s_impactMinChanged(variant ImpactMin)
    function setImpactMin ( ImpactMin ) { mfuFromImpact.setValue(ImpactMin) }

    function setFeedback ( Feedback ) { mfuFeedback.setValue(Feedback) }

    onVisibleChanged: {
        if (visible == true) {
            var absolutePos = mapToGlobal(0, 0)
            x = absolutePos.x
            y = absolutePos.y
            requestActivate()
        }
    }

    Item{
        id: itemPr
        width: parent.width * 0.08
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        Rectangle {
            id: rectPros
            width: parent.width * 0.6
            color: "#7a7a85"
            border.width: 1
            anchors.left: parent.left
            anchors.top: mfuToProcess.bottom
            anchors.bottom: mfuFromProcess.top
            Rectangle {
                height: {
                    parent.height * (mfuProcess.valueReal - mfuFromProcess.valueReal )
                            /(mfuToProcess.valueReal - mfuFromProcess.valueReal)}
                color: colorProcess
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                anchors.leftMargin: parent.border.width
                anchors.rightMargin: 0
            }
            anchors.bottomMargin: -border.width
            anchors.topMargin: -border.width
        }
        Rectangle {
            id: rectSetPt
            color: rectPros.color
            border.width: 1
            anchors.left: rectPros.right
            anchors.right: parent.right
            anchors.top: mfuToProcess.bottom
            anchors.bottom: mfuFromProcess.top
            Rectangle {
                height: {
                    parent.height * (mfuSetPt.valueReal - mfuFromProcess.valueReal )
                            /(mfuToProcess.valueReal - mfuFromProcess.valueReal)}
                color: colorSetPt
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
            }
            anchors.bottomMargin: -border.width
            anchors.leftMargin: -rectPros.border.width
            anchors.topMargin: -border.width
        }
        MFUnit {
            id: mfuToProcess
            height: wind.height * 0.05
            width: wind.width * 0.2
            anchors.left: parent.left
            anchors.top: parent.top
            valueReal: 100
            correctingButtons: false
            borderColor: "#000000"
            readOnly: false
            limited: false
            tooltipText: "Max"
            backgroundColor: "#e6e6e6"
            confmOnEnter: wind.confmOnEnter
            onValueChanged: s_setPtMaxChanged( Value )
        }
        MFUnit {
            id: mfuFromProcess
            width: mfuToProcess.width
            height: mfuToProcess.height
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            correctingButtons: false
            anchors.bottomMargin: 0
            borderColor: "#000000"
            readOnly: false
            anchors.leftMargin: 0
            limited: false
            tooltipText: "Min"
            backgroundColor: mfuToProcess.backgroundColor
            confmOnEnter: wind.confmOnEnter
            onValueChanged: s_setPtMinChanged( Value )
        }
    }
    Column{
        id: colMain
        anchors.left: itemPr.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.leftMargin: 5
        anchors.rightMargin: 5
        anchors.bottomMargin: 0
        anchors.topMargin: parent.height * 0.01
        spacing: height * 0.012
        anchors.right: rectImpact.left
        SimpleButton {
            id: switchOnOff
            width: parent.width * 0.3
            height: parent.height * 0.1
            radius: height / 2
            anchors.horizontalCenter: parent.horizontalCenter
            checkable: true
            pressCheckColor: "gray"
            unPressCheckColor: "#8afda6"
            nameText.text: "ВКЛ"
            onS_checkedUserChanged: s_manOn(Checked)
            onCheckedChanged: {
                if (checked)
                    nameText.text = "ОТКЛ"
                else
                    nameText.text = "ВКЛ"
            }
        }
        Text {
            height: parent.height * 0.07
            text: processName
            anchors.left: parent.left
            anchors.right: parent.right
            font.pixelSize: 300
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignBottom
            wrapMode: Text.WordWrap
            fontSizeMode: Text.Fit
            maximumLineCount: 2
            anchors.rightMargin: 0
            anchors.leftMargin: 0
        }
        MFUnit {
            id: mfuProcess
            height: parent.height * 0.15
            anchors.left: parent.left
            anchors.right: parent.right
            valueReal: 0
            anchors.rightMargin: 0
            anchors.leftMargin: 0
            backgroundColor: colorProcess
            limited: false
            readOnly: true
            borderColor: "Black"
            correctingButtons: false
            tooltipText: "Контролируемый параметр"
            confmOnEnter: wind.confmOnEnter
        }
        //        Text {
        //            id: textFrom1
        //            height: parent.height * 0.07
        //            text: "Задание:"
        //            anchors.left: parent.left
        //            anchors.right: parent.right
        //            font.pixelSize: height * 0.8
        //            horizontalAlignment: Text.AlignLeft
        //            verticalAlignment: Text.AlignBottom
        //            fontSizeMode: Text.Fit
        //            anchors.leftMargin: 0
        //            anchors.rightMargin: 0
        //        }

        MFUnit {
            id: mfuSetPt
            //width: parent.width *0.7
            height: parent.height * 0.15
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.leftMargin: 0
            readOnly: false
            correctingButtons: true
            borderColor: "Black"
            tooltipText: "Задание"
            limited: false
            backgroundColor: colorSetPt
            textInput.color: "White"
            maxBtn.nameText.color: "white"
            minBtn.nameText.color: "white"
            onValueChanged:  s_setPtChanged( Value )
            confmOnEnter: wind.confmOnEnter
            //textInput.text
        }

        Text {
            id: textFrom2
            height: parent.height * 0.07
            text: impactName
            anchors.left: parent.left
            anchors.right: parent.right
            font.pixelSize: 300
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignBottom
            wrapMode: Text.WordWrap
            maximumLineCount: 2
            fontSizeMode: Text.Fit
            anchors.leftMargin: 0
            anchors.rightMargin: 0
        }
        Row{
            id: row
            height: parent.height * 0.1
            anchors.left: parent.left
            anchors.right: parent.right
            layoutDirection: Qt.LeftToRight
            spacing: 1

            SimpleButton {
                id: impulsOnOff
                width: parent.width * 0.08
                height: parent.height * 0.8
                //radius: height / 2
                visible: impIs2DisctOuts
                anchors.verticalCenter: parent.verticalCenter
                checkable: true
                pressCheckColor: "#8afda6"
                unPressCheckColor: "gray"
                toolTipText: "Вкл/Откл импульсный режим для прямого управления дискретными выходами управляемого устройства при отключенном ПИД-регуляторе."
                nameText.text: "ИР"
                onS_checkedUserChanged: s_impulseOn(Checked)
                checked: false
            }
            MFUnit {
                id: mfuFeedback
                width: parent.width *0.4
                tooltipText: "Ответ от управляемого механизма. В ручном режиме можно управлять напрямую с помощью +/- (дискретные сигналы 'больше' и 'меньше')."
                visible: impulsOnOff.checked //&& impIs2DisctOuts
                anchors.right: mfuImpact.left//impIs2DisctOuts
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.rightMargin: 2
                readOnly: true
                correctingButtons: impulsOnOff.checked
                limited: false
                backgroundColor: "darkgrey"
                textInput.color: "White"
                maxBtn.nameText.color: "white"
                minBtn.nameText.color: "white"
                onS_more: s_impMore(More)
                onS_less: s_impLess(Less)
                separCorrButtons: true
                confmOnEnter: wind.confmOnEnter
            }
             MFUnit {
                id: mfuManImpact
                width: parent.width *0.4
                tooltipText: "Ручное воздействие.\nЗначение на выходе ПИД-регулятора\nкогда он выключен."
                visible: impIsAnlgOut && ! impulsOnOff.checked
                anchors.right: mfuImpact.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.rightMargin: 2
                //readOnly: true
                //correctingButtons: manOnOff
                limited: false
                backgroundColor: "black"
                textInput.color: "White"
                maxBtn.nameText.color: "white"
                minBtn.nameText.color: "white"
                onValueChanged: s_manImpactChanged( Value )
                //separCorrButtons: false
                confmOnEnter: wind.confmOnEnter
            }

            MFUnit {
                id: mfuImpact
                width: parent.width *0.4
                anchors.right: parent.right
                tooltipText: "Итоговое воздействие. Вычисляется если ПИД-регулятор включен. Если выключен, берется из поля\"Ручное воздействие\"."
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                readOnly: true
                correctingButtons: false
                limited: false
                backgroundColor: colorImpact
                onValueChanged: s_impactChanged( Value )
                confmOnEnter: wind.confmOnEnter
                //separCorrButtons: (impulsOnOff.checked && impIs2DisctOuts)
            }
        }
        Column{
            id: column
            height: parent.height * 0.2
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 0
            anchors.rightMargin: 0
            spacing: parent.width *0.015
            Row{
                id: kpRow
                height: parent.height * 0.3
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: parent.width *0.01
                MFUnit {
                    id: mfuKp
                    width: parent.width *0.48
                    visible: adminView
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    readOnly: false
                    correctingButtons: false
                    backgroundColor: "#ffffff"
                    mantissa: 4
                    tooltipText: "Коэфициент пропорциональности"
                    onValueChanged:s_KpChanged(Value)
                    confmOnEnter: wind.confmOnEnter
                }
                Text {
                    width: parent.width *0.1
                    visible: mfuKp.visible || mfuKpOut.visible
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    font.pixelSize: 300
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    fontSizeMode: Text.Fit
                    text: "Кп"
                }

                MFUnit {
                    id: mfuKpOut
                    width: parent.width *0.4
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.topMargin: 0
                    anchors.bottomMargin: 0
                    readOnly: true
                    correctingButtons: false
                    limited: false
                    backgroundColor: "#ffffff"
                    tooltipText: "Пропорциональная составляющая воздействия"
                    confmOnEnter: wind.confmOnEnter
                    mantissa: mfuImpact.mantissa + 1
                }
            }
            Row{
                id: kiRow
                height: parent.height * 0.3
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: parent.width *0.01
                MFUnit {
                    id: mfuKi
                    width: parent.width *0.48
                    visible: adminView
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    readOnly: false
                    correctingButtons: false
                    limited: false
                    backgroundColor: "#ffffff"
                    mantissa: 4
                    tooltipText: "Интегральный коэфициент"
                    onValueChanged: s_KiChanged( Value )
                    confmOnEnter: wind.confmOnEnter
                }

                Text {
                    width: parent.width *0.1
                    visible: mfuKi.visible || mfuKiOut.visible
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    font.pixelSize: 300
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    fontSizeMode: Text.Fit
                    text: "Ки"
                }

                MFUnit {
                    id: mfuKiOut
                    width: parent.width *0.4
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.topMargin: 0
                    anchors.bottomMargin: 0
                    readOnly: true
                    correctingButtons: false
                    limited: false
                    backgroundColor: "#ffffff"
                    tooltipText: "Интегральная составляющая воздействия"
                    confmOnEnter: wind.confmOnEnter
                    mantissa: mfuImpact.mantissa + 1
                }
            }
            Row{
                id: kdRow
                height: parent.height * 0.3
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: parent.width *0.01
                MFUnit {
                    id: mfuKd
                    width: parent.width *0.48
                    visible: adminView
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    readOnly: false
                    correctingButtons: false
                    limited: false
                    backgroundColor: "#ffffff"
                    mantissa: 4
                    tooltipText: "Дифференциальный коэфициент"
                    onValueChanged: s_KdChanged( Value )
                    confmOnEnter: wind.confmOnEnter
                }

                Text {
                    width: parent.width *0.1
                    visible: mfuKd.visible || mfuKdOut.visible
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    font.pixelSize: 300
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    fontSizeMode: Text.Fit
                    text: "Кд"
                }

                MFUnit {
                    id: mfuKdOut
                    width: parent.width *0.4
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.topMargin: 0
                    anchors.bottomMargin: 0
                    readOnly: true
                    correctingButtons: false
                    limited: false
                    backgroundColor: "#ffffff"
                    tooltipText: "Дифференциаьная составляющая воздействия"
                    confmOnEnter: wind.confmOnEnter
                    mantissa: mfuImpact.mantissa + 1
                }
            }
        }
    }
    Rectangle {
        id: rectImpact
        width: parent.width * 0.05
        color: rectPros.color
        border.width: 1
        anchors.right: parent.right
        anchors.top: mfuToImpact.bottom
        anchors.bottom: mfuFromImpact.top
        anchors.bottomMargin: -border.width
        anchors.topMargin: -border.width
        Rectangle {
            color: colorImpact
            height: {
                parent.height * (mfuImpact.valueReal - mfuFromImpact.valueReal )
                        /(mfuToImpact.valueReal - mfuFromImpact.valueReal)
            }
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: parent.border.width
            anchors.leftMargin: parent.border.width
            anchors.bottomMargin: 0
        }
    }
    MFUnit {
        id: mfuToImpact
        height: mfuToProcess.height
        width: mfuToProcess.width
        anchors.right: parent.right
        anchors.top: parent.top
        valueReal: 100
        anchors.rightMargin: 0
        limited: false
        anchors.topMargin: 0
        correctingButtons: false
        tooltipText: "Max"
        backgroundColor: mfuToProcess.backgroundColor
        readOnly: false
        borderColor: "Black"
        confmOnEnter: wind.confmOnEnter
        onValueChanged: s_impactMaxChanged( Value )
    }
    MFUnit {
        id: mfuFromImpact
        width: mfuToImpact.width
        height: mfuToImpact.height
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 0
        anchors.bottomMargin: 0
        limited: false
        correctingButtons: false
        tooltipText: "Min"
        backgroundColor: mfuToProcess.backgroundColor
        readOnly: false
        borderColor: "Black"
        confmOnEnter: wind.confmOnEnter
        onValueChanged: s_impactMinChanged( Value )
    }
}








