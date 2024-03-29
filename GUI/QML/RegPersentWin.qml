﻿import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    id: root
    width: 180
    height: 150
    property alias mfuCurValue: mfuCurValue
    title: "РК"
    flags: Qt.Window | Qt.Dialog
    minimumWidth: 180
    maximumHeight: 170
    property alias sepCorBtn: mfuCurValue.separCorrButtons

    property alias value: mfuCurValue.valueReal
    property alias step: regStep.valueReal

    property alias valueMax: maxValue.valueReal
    property alias valueMin: minValue.valueReal
    property alias readOnly: mfuCurValue.readOnly
    property color mainColor: "#a3fa96"
    property color scaleColor: "#1a6b14"
    property bool confmOnEnter: false
    property alias upLimit: maxValue.upLimit
    property alias downLimit: minValue.downLimit
    property string unitOfmeg: "%"
    property alias levelText: textLvl.text

    function setValueMinRange( MinRg ) { minValue.setValue( MinRg ) }
    function setValueMaxRange( MaxRg ) { maxValue.setValue( MaxRg ) }
    function setValue(Value) { mfuCurValue.setValue( Value ) }
    function setStep( Step ) { regStep.setValue(Step)}
    signal s_moreVal( variant More )
    signal s_lessVal( variant Less )
    signal s_valueChenged(variant Value)
    signal s_valueMaxChenged(variant Value)
    signal s_valueMinChenged(variant Value)

    onVisibleChanged: {
        if (visible == true) {
            var absolutePos = root.mapToGlobal(0, 0)
            x = absolutePos.x
            y = absolutePos.y
            requestActivate()
        }
    }

    Text {
        id: textWrkDp
        height: 20
        text: "РАБОЧИЙ ДИАПАЗОН " + unitOfmeg
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        font.pixelSize: height * 0.6
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    Rectangle {
        color: "#6e9ec8"
    }
    Rectangle {
        color: "#c36b6b"
    }

    MFUnit {
        id: maxValue
        height: 20
        valueReal: 100
        backgroundColor: "#c36b6b"
        borderColor: "#c36b6b"
        tooltipText: "максимальное значение"
        readOnly: false
        visible: true
        anchors.left: parent.horizontalCenter
        anchors.right: parent.right
        anchors.top: textWrkDp.bottom
        mantissa: 2
        correctingButtons: true
        limited: true
        downLimit: minValue.valueReal + 1
        upLimit: 100
        onValueChanged: s_valueMaxChenged( Value )
        confmOnEnter: root.confmOnEnter
    }
    MFUnit {
        id: minValue
        height: 20
        valueReal: 0
        backgroundColor: "#6e9ec8"
        borderColor: "#6e9ec8"
        tooltipText: "минимальное значение"
        readOnly: false
        visible: true
        anchors.left: parent.left
        anchors.right: parent.horizontalCenter
        anchors.top: textWrkDp.bottom
        mantissa: 2
        correctingButtons: true
        limited: true
        upLimit: maxValue.valueReal - 1
        onValueChanged: s_valueMinChenged( Value )
        confmOnEnter: root.confmOnEnter
    }
    Item {
        id: item1
        height: 30
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: minValue.bottom
        Rectangle {
            id: min
            width: parent.width * valueMin / 100
            color: "#6e9ec8"
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
        }
        Rectangle {
            id: wrk
            color: scaleColor
            anchors.left: min.right
            anchors.right: max.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
        }
        Rectangle {
            id: max
            width: parent.width * (1 -valueMax / 100)
            color: "#c36b6b"
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
        }
        Rectangle {
            id: recLvl
            x: value / (upLimit - downLimit) * parent.width
            width: 2
            height: parent.height * 1.1
            color: mainColor
        }
    }
    Rectangle {
        color: mainColor
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: item1.bottom
        anchors.bottom: stepTxt.bottom
    }
    Text {
        id: textLvl
        height: 20
        text: "ТЕКУЩЕЕ ЗНАЧЕНИЕ " + unitOfmeg
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: item1.bottom
        font.pixelSize: height * 0.6
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    MFUnit {
        id: mfuCurValue
        height: 40
        valueReal: 60
        backgroundColor: mainColor
        borderColor: mainColor
        tooltipText: "Min"
        readOnly: false
        visible: true
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: textLvl.bottom
        mantissa: 0
        correctingButtons: true
        limited: true
        upLimit: maxValue.valueReal
        downLimit: minValue.valueReal
        step: regStep.valueReal
        onS_more: s_moreVal( More )
        onS_less: s_lessVal( Less )
        onValueChanged: s_valueChenged( Value )
        confmOnEnter: root.confmOnEnter
    }
    Text {
        id: stepTxt
        height: 20
        width: text.length * font.pixelSize * 0.7
        visible: !mfuCurValue.readOnly
        text: "ШАГ РЕГУЛИРОВКИ -"
        anchors.left: parent.left
        anchors.top: mfuCurValue.bottom
        font.pixelSize: height * 0.6
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    MFUnit {
        id: regStep
        valueReal: 1
        height: 20
        visible: !mfuCurValue.readOnly
        backgroundColor: mainColor
        borderColor: mainColor
        anchors.left: stepTxt.right
        anchors.right: parent.right
        anchors.top: mfuCurValue.bottom
        textInput.font.bold: true
        correctingButtons: false
        upLimit: 10
        downLimit: 1
        confmOnEnter: root.confmOnEnter
    }
}




