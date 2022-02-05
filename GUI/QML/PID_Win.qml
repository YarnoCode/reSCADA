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

    property string processName: "Температура куба РК1"
    property string impactName: "Положение клапана подачи пара"

    property alias isOn: switchOnOff.checked

    property color colorProcess: "YellowGreen"
    property color colorSetPt: "black"
    property color colorImpact: "DarkGoldenRod"

    property alias process: mfuProcess.valueReal
    property alias setPt: mfuSetPt.valueReal
    property alias impact: mfuImpact.valueReal

    property alias kp: mfuProcess.valueReal
    property alias ki: mfuSetPt.valueReal
    property alias kd: mfuImpact.valueReal

    function setKp( Kp ) { kp = Kp }
    function setKi( Ki ) { ki = Ki }
    function setKd( Kd ) { kd = Kd }

    function setProcess ( Process  ) { process  = Process  }
    function setSetPt ( SetPt  ) { setPt  = SetPt  }
    function setImpact( Impact ) { impact = Impact }

    Item{
        id: itemPr
        width: parent.width * 0.08
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        Rectangle {
            id: rectPros
            width: parent.width * 0.6
            color: "#b2b2b8"
            border.width: 1
            anchors.left: parent.left
            anchors.top: mfuToProcess.bottom
            anchors.bottom: mfuFromProcess.top
            Rectangle {
                height: {
                    parent.height * (wind.process - mfuFromProcess.valueReal )
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
            checkLimit: false
            tooltip: "Max"
            backgroundColor: "#e6e6e6"
        }

        Rectangle {
            id: rectSetPt
            color: "#b2b2b8"
            border.width: 1
            anchors.left: rectPros.right
            anchors.right: parent.right
            anchors.top: mfuToProcess.bottom
            anchors.bottom: mfuFromProcess.top
            Rectangle {
                height: {
                    parent.height * (wind.setPt - mfuFromProcess.valueReal )
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
            id: mfuFromProcess
            width: mfuToProcess.width
            height: mfuToProcess.height
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            valueReal: 10
            correctingButtons: false
            anchors.bottomMargin: 0
            borderColor: "#000000"
            readOnly: false
            anchors.leftMargin: 0
            checkLimit: false
            tooltip: "Min"
            backgroundColor: mfuToProcess.backgroundColor
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
        anchors.topMargin: 0
        spacing: height * 0.012
        anchors.right: rectImpact.left
        Switch {
            id: switchOnOff
            height: parent.height * 0.1
            text: qsTr("Вкл.")
            anchors.horizontalCenter: parent.horizontalCenter
            autoRepeat: false
            autoExclusive: false
            font.weight: Font.Bold
            font.pointSize: 10
            checked: false
            onCheckedChanged: {
                if (checked)
                    text = "Вкл."
                else
                    text = "Выкл."
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
            visible: true
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.leftMargin: 0
            valueReal: 85
            backgroundColor: colorProcess
            checkLimit: false
            readOnly: true
            borderColor: "Black"
            correctingButtons: false
            tooltip: "Контролируемый параме"
            mantissa: 2
        }
        Text {
            id: textFrom1
            height: parent.height * 0.07
            text: "Задание:"
            anchors.left: parent.left
            anchors.right: parent.right
            font.pixelSize: height * 0.8
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignBottom
            fontSizeMode: Text.Fit
            anchors.leftMargin: 0
            anchors.rightMargin: 0
            visible: false
        }

        MFUnit {
            id: mfuSetPt
            //width: parent.width *0.7
            height: parent.height * 0.15
            visible: true
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.leftMargin: 0
            readOnly: false
            correctingButtons: true
            valueReal: 60
            borderColor: "Black"
            tooltip: "Задание"
            checkLimit: false
            backgroundColor: colorSetPt
            textInput.color: "White"
            mantissa: 2
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

        MFUnit {
            id: mfuImpact
            width: parent.width *0.7
            height: parent.height * 0.1
            visible: true
            anchors.right: parent.right
            anchors.rightMargin: 0
            readOnly: switchOnOff.checked
            correctingButtons: ! switchOnOff.checked
            valueReal: 568
            tooltip: "Воздействие"
            checkLimit: false
            backgroundColor: colorImpact
            mantissa: 2
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
                height: parent.height * 0.3
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: parent.width *0.01
                MFUnit {
                    id: mfuKp
                    width: parent.width *0.48
                    visible: true
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    readOnly: false
                    correctingButtons: false
                    valueReal: 999.99
                    checkLimit: false
                    backgroundColor: "#ffffff"
                    mantissa: 4
                    tooltip: "Коэфициент пропорциональности"
                }

                Text {
                    width: parent.width *0.1
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
                    visible: true
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.topMargin: 0
                    anchors.bottomMargin: 0
                    readOnly: true
                    correctingButtons: false
                    valueReal: 999.99
                    checkLimit: false
                    backgroundColor: "#ffffff"
                    tooltip: "Пропорциональная составляющая воздействия"
                }
            }
            Row{
                height: parent.height * 0.3
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: parent.width *0.01
                MFUnit {
                    id: mfuKi
                    width: parent.width *0.48
                    visible: true
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    readOnly: false
                    correctingButtons: false
                    valueReal: 999.99
                    checkLimit: false
                    backgroundColor: "#ffffff"
                    mantissa: 4
                    tooltip: "Интегральный коэфициент"
                }

                Text {
                    width: parent.width *0.1
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
                    visible: true
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.topMargin: 0
                    anchors.bottomMargin: 0
                    readOnly: true
                    correctingButtons: false
                    valueReal: 999.99
                    checkLimit: false
                    backgroundColor: "#ffffff"
                    tooltip: "Интегральная составляющая воздействия"
                }
            }
            Row{
                height: parent.height * 0.3
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: parent.width *0.01
                MFUnit {
                    id: mfuKd
                    width: parent.width *0.48
                    visible: true
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    readOnly: false
                    correctingButtons: false
                    valueReal: 999.99
                    checkLimit: false
                    backgroundColor: "#ffffff"
                    mantissa: 4
                    tooltip: "Дифференциальный коэфициент"
                }

                Text {
                    width: parent.width *0.1
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
                    visible: true
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.topMargin: 0
                    anchors.bottomMargin: 0
                    readOnly: true
                    correctingButtons: false
                    valueReal: 999.99
                    checkLimit: false
                    backgroundColor: "#ffffff"
                    tooltip: "Дифференциаьная составляющая воздействия"
                }
            }
        }
    }


    Rectangle {
        id: rectImpact
        width: parent.width * 0.05
        color: "#00ffffff"
        border.width: 1
        anchors.right: parent.right
        anchors.top: mfuToImpact.bottom
        anchors.bottom: mfuFromImpact.top
        anchors.bottomMargin: -border.width
        anchors.topMargin: -border.width
        Rectangle {
            color: colorImpact
            height: {
                parent.height * (wind.impact - mfuFromImpact.valueReal )
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
        anchors.rightMargin: 0
        checkLimit: false
        anchors.topMargin: 0
        correctingButtons: false
        tooltip: "Max"
        backgroundColor: mfuToProcess.backgroundColor
        readOnly: false
        valueReal: 200
        borderColor: "Black"
    }
    MFUnit {
        id: mfuFromImpact
        width: mfuToImpact.width
        height: mfuToImpact.height
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 0
        anchors.bottomMargin: 0
        checkLimit: false
        correctingButtons: false
        tooltip: "Min"
        backgroundColor: mfuToProcess.backgroundColor
        readOnly: false
        valueReal: 100
        borderColor: "Black"
    }
}







