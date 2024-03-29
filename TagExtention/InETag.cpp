﻿#include "InETag.h"
#include <QDebug>
#include "unit.h"
#include <QSettings>
#include "OutETag.h"

using Prom::MessType;
//using Prom::PropType;

//extern QObject * Ob;

InETag::InETag(Unit * Owner,
    //Prom::ESTagType Type,
    QString Name,
    QString DBName,
    bool HighOrLow,
    QVariant DetectLevel,
    QVariant ChageStep,
    bool TunableSetTime,
    bool TunablePulseTime,
    bool TunabDetectLevel,
    bool EgnorableAlarm,
    bool InGUI,
    Prom::ETagValConv Convertion,
    int TimeMax)
    : ETag(Owner,
        //Type,
        Name,
        DBName,
        TunableSetTime,
        TunablePulseTime,
        EgnorableAlarm,
        InGUI,
        Convertion,
        ChageStep),
    _tunabDetectLevel(TunabDetectLevel),
    _highOrLow(HighOrLow),
    _detectLevel(DetectLevel)
{
    _timeMax = new QTimerExt(this);
    _timeMax->setInterval(TimeMax * 1000);
    _timeMax->setSingleShot( true );
    connect( _timeMax, &QTimerExt::timeout, this, &InETag::_timeMaxStep, Qt::QueuedConnection );
}
//------------------------------------------------------------------------------
void InETag::saveParam()
{
    ETag::saveParam();
    _owner->ini->setValue(_owner->tagPrefix+ "/" + _DBName + "/" + "detectLevel", _detectLevel);
}

//------------------------------------------------------------------------------
void InETag::loadParam()
{
    if( _owner->ini->contains(_owner->tagPrefix+ "/" + _DBName + "/" + "detectLevel") )
        _detectLevel = _owner->ini->value(_owner->tagPrefix+ "/" + _DBName + "/" + "detectLevel", 0).toDouble();
    ETag::loadParam();
}
//------------------------------------------------------------------------------
bool InETag::connectTagToLimit(OutETag *Tag)
{
    bool res = true;
    if( Tag == nullptr ) return false;
    if( !Tag->isOk() ) return false;
    setDetectLevel( Tag->value() );
    res = res && connect( this, SIGNAL(s_delectLevelChanged(QVariant)), Tag,SLOT(setValue(QVariant)), Qt::QueuedConnection);
    res = res && connect( Tag,  &OutETag::s_valueChd,           this, &InETag::setDetectLevel, Qt::QueuedConnection);
    if( !res ) {
        disconnect( this, SIGNAL(s_delectLevelChanged(QVariant)), Tag,  SLOT(setValue(QVariant)) );
        disconnect( Tag,  &OutETag::s_valueChd,           this, &InETag::setDetectLevel );
    }
    return res;
}
//------------------------------------------------------------------------------
bool InETag::findLimTag()
{
    bool res = true;
    QString tmp = _DBName;
    tmp = tmp.remove(".value");
    res &= connectTagToLimit( new OutETag(_owner, Prom::PreSet,
        _name + (highOrLow()? " макс.":" мин."), tmp + ".alarmLim",false,false,false,true,
        Prom::VCNo,false,false,0,true));
    _tunabDetectLevel = !res;
    return res;
}

//------------------------------------------------------------------------------
void InETag::reInitialise()
{
    ETag::reInitialise();
    emit s_delectLevelChanged(_detectLevel);
    if(_detect) emit s_detected();
    else emit s_undetected();
}

//------------------------------------------------------------------------------
QVariant InETag::detectLevel() const
{
    return _detectLevel;
}

//------------------------------------------------------------------------------
void InETag::setDetectLevel(QVariant detectLevel)
{
    //    Ob = sender();
    if( _detectLevel != detectLevel.toDouble() ){
        _detectLevel = detectLevel.toDouble();
        _logging(Prom::MessInfo, "уровень срабатывания изменён на -" + _detectLevel.toString(), false);
        //    if(_DBName == ".QK")
        //        qDebug()<<".QK";
        //_detect = _Detect();
        _checkVal();
        emit s_delectLevelChanged(_detectLevel);
    }
}

//------------------------------------------------------------------------------
void InETag::writeImit(bool setImit)
{
    if(_imit != setImit){
        _imit = setImit;

        if(_imit){
            //            if(_pulse) disconnect(_tag ,SIGNAL(onValueChanged(QVariant)), this, SLOT(pulse()));
            //            else disconnect(_tag ,SIGNAL(onValueChanged(QVariant)), this, SLOT(CheckVal()));
            _logging(Prom::MessInfo, "имитация включена", false);
            emit s_qualityChd(true);
            if(_imitVal != _value)_checkVal();
        }
        else{
            //            if(_pulse) connect(_tag ,SIGNAL(onValueChanged(QVariant)), this, SLOT(pulse()));
            //            else connect(_tag ,SIGNAL(onValueChanged(QVariant)), this, SLOT(CheckVal()));
            _logging(Prom::MessInfo, "имитация отключена", false);
            if(_ok){
                if(_pulse) _pulseTimer->start();
                else if(_imitVal != _value)
                    _checkVal();
                emit s_qualityChd(_tag->readQuality() == Prom::Good);
            }
            else emit s_qualityChd(false);
        }
    }
}

//------------------------------------------------------------------------------
void InETag::writeImitVal(QVariant setVal)
{
    if(_imitVal != setVal){
        _preValue = _imitVal;
        _imitVal = setVal;
        _logging(Prom::MessInfo, "имитация значения - " +  setVal.toString(), false);
        if(_imit){
            if(_pulse) _checkPulse();
            else _checkVal();
        }
        emit s_imitationValueChd(_imitVal);
    }
}

//------------------------------------------------------------------------------
void InETag::_qualityChangedSlot()
{
    ETag::_qualityChangedSlot();
    if(_tag->readQuality() == Prom::Good && ! _imit) {
        if(_pulse){
            _pulseTimer->start();
        }
        else{
            _checkVal();
        }
    }
}

//------------------------------------------------------------------------------
void InETag::needBe(bool DtctOrNot, bool AlarmOn, bool SetTimer)
{
    if(_DnotU != DtctOrNot || _alarmOn != AlarmOn){
        _logging (Prom::MessVerbose, QString("установлен режим обработки сигнала - 'необходтимо быть " + QString(DtctOrNot ? "" : "не")
                                        + "сработавшим (значение ") + QString(_highOrLow ? "больше":"меньше") + " или равно - "
                + _detectLevel.toString() + ")'"
                +  QString(_alarmOn ? " с генерацией":" без генерации ") + " аварии,"
                + QString(SetTimer ? " с таймером":" без таймера") + " на установку нужного состояния"
            , false);

    }
    _DnotU = DtctOrNot;
    _alarmOn = AlarmOn;
    _onlyChange = false;
    _setTimer->stop();
    if(SetTimer && connected()){
        _mayResetAlarm = true;
        if(_setTimer->interval() > 0){
            setTimerStart();
        }
        else _logging(Prom::MessWarning,  "установлено бесконечное время на принятие сигналом нужного состояния", false);
    }
    else {
        _detect = _checkDetect();
        _preDetect = _detect;
        if(_detect == _DnotU){
            _mayResetAlarm = true;
        }
        else{
            if((_detect != _DnotU && _alarmOn)){
                if(_ignorAlarm) {
                    _mayResetAlarm = true;
                    emit s_alarm("");
                    _logging(Prom::MessInfo,  "проигнорирована авария недупустимого состояния, при смене режима обработки сигнала", false);
                }
                else {
                    _mayResetAlarm = false;
                    _alarm = true;
                    emit s_alarm(objectName() + " - авария недупустимого состояния, при смене режима обработки сигнала");
                }
            }
        }
    }
}

//------------------------------------------------------------------------------
void InETag::onlyChange()
{
    if(! _onlyChange)
        _logging (Prom::MessVerbose, "установлен режим 'только информироввание об изменениях'", false);
    _onlyChange = true;
    _mayResetAlarm = true;
    _alarmOn = false;
    _setTimer->stop();
}

//------------------------------------------------------------------------------
void InETag::pulsSensor(bool On)
{
    _pulse = On;
    if(_pulse){
        if(_setTimer->interval() < _pulseTimer->interval()){
            _setTimer->setInterval(_pulseTimer->interval() + 1000);
            emit s_pulseDelayChd(_setTimer->interval()/1000);
        }
        //if(! _imit) {
        disconnect(_tag ,SIGNAL(onValueChanged(QVariant)), this, SLOT(_checkVal()));
        connect(_tag ,SIGNAL(onValueChanged(QVariant)), this, SLOT(_checkPulse()));
        //}
        _trig = true;
        _detectPulse = false;
        _detect = false;
        _setTimer->start();
        _logging (Prom::MessInfo, "установлен режим детектирования пульсации тэга", false);
    }
    else {
        disconnect(_tag, SIGNAL(onValueChanged(QVariant)), this, SLOT(_checkPulse()));
        connect(_tag, SIGNAL(onValueChanged(QVariant)), this, SLOT(_checkVal()));
        if(_detect != _checkDetect())
            _checkVal();
        _logging (Prom::MessInfo, "выключен режим детектирования пульсации тэга", false);
    }
}

//------------------------------------------------------------------------------
void InETag::_setTimerEnd()
{
    _setTimer->stop(); //Для сторонних сигналов
    if(! _onlyChange){
        if((_DnotU && ! _detect) || (! _DnotU && _detect)){
            if(_ignorAlarm) {
                _logging (Prom::MessAlarm, "проигнорирована авария, превышения времени на установку необходимого состояния", _imit);
                emit s_alarm("");
            }
            else {
                _alarm = true;
                _alarmStr = "превышение времени на установку необходимого состояния";
                emit s_alarm( _name + " " + _alarmStr );
            }
        }
    }
}

//------------------------------------------------------------------------------
bool InETag::_checkDetect()
{
    return _highOrLow ? (value().toDouble() >= _detectLevel.toDouble())
                      : (value().toDouble() <= _detectLevel.toDouble());
}
//------------------------------------------------------------------------------
void InETag::setTimeMax( int TimeMax )
{
    _timeMax->setInterval(TimeMax*1000);
}

//------------------------------------------------------------------------------
int InETag::timeMax()
{
    if( _timeMax != nullptr ){
        return _timeMax->interval()/1000;
    }
    else{
        return 0;
    }
}

//------------------------------------------------------------------------------
void InETag::_timeMaxStep()
{
    if( _imit ) {
        _imitVal = _timeMaxValue;
        emit s_imitationValueChd( _imitVal );
    }
    else {
        _value = _timeMaxValue;
    }
    _preValue = _timeMaxValue.toDouble() - 1;
    _checkVal();
    if( _timeLastValue.toDouble() < _timeMaxValue.toDouble() ){
        _timeMaxValue = _timeLastValue;
        _timeMax->start();
    }
}

//------------------------------------------------------------------------------
void InETag::_checkVal()
{
    if( _timeMax->interval() > 0 ){
        if( value().toDouble() < _preValue.toDouble() ){
            if( _timeMax->isActive() ){
                //коплю максимум после падения
                _timeMaxValue = qMax( value(), _timeMaxValue );
                _timeLastValue = value().toDouble();
            }
            else {//запускаю защитный период
                _timeMaxValue = value().toDouble();
                _timeLastValue = value().toDouble();
                _timeMax->start();
            }
            //пока идет защитный период сбрасываю на старый максимум
            if( _imit ) {
                _imitVal = _preValue;
                emit s_imitationValueChd( _imitVal );
            }
            else {
                _value = _preValue;
            }
            return;
        }
        else {
            _timeMax->stop();
        }
    }

    static quint8 ChDt;//чтобы emit s_valueChd и detrct/undetect шли после логов и т.п.

    if (_pulse){
        _trig = ! _detectPulse;
        _detect = _detectPulse;
        ChDt = 0;
    }
    else {
        _detect = _checkDetect();
        if(value() != _preValue){
            ChDt = 1;
            //_preValue = value();
        }
    }
    if(_preDetect != _detect) {
        if(_onlyChange){// ---- Обработка без аварий ----
            if(_detect) {
                _logging(Prom::MessChangeSensor, "активирован ", _imit);
            }
            else {
                _logging(Prom::MessChangeSensor, "деактивирован ", _imit);
            }
        }
        else {// ---- Обработка с аварями ----
            _mayResetAlarm = false;
            if(_detect == _DnotU){//значение НЕ вышло за предел
                _mayResetAlarm = true;
                _logging(Prom::MessChangeSensor,"установлено нормальное состояние ", _imit);
            }
            else {//значение вышло за предел
                if(_alarmOn){
                    if(_setTimer->isActive()){
                        _logging(Prom::MessChangeSensor, "состояние допустимо изменено в рамках времени на установку", _imit);
                    }
                    else {
                        if(_ignorAlarm)
                            emit s_alarm("");
                        else{
                            _alarmStr = "выход за предельное значение: значение - "
                                + value().toString() + ", предел - "
                                + _detectLevel.toString();
                            if( _alarm ){
                                emit s_alarm("");
                                //_logging(Prom::MessAlarm, _alarmStr, _imit);
                            }
                            else {
                                _alarm = true;
                                emit s_alarm( _alarmStr );
                            }
                        }
                    }
                }
                else{
                    _mayResetAlarm = true;
                    _logging(Prom::MessChangeSensor, "нормальное состояние допустимо изменено", _imit);
                }
            }
        }
        ChDt += 2;
        _preDetect = _detect;
    }

    switch (ChDt) {
    case 1:
        emit s_valueChd(value());
        break;
    case 2:
        if(_detect)emit s_detected();
        else emit s_undetected();
        break;
    case 3:
        emit s_valueChd(value());
        if(_detect)emit s_detected();
        else emit s_undetected();
        break;
    }
    if(_alarmSelfReset && _mayResetAlarm){
        resetAlarm();
    }
}

//------------------------------------------------------------------------------
void InETag::_checkPulse()
{
    emit s_valueChd(value());
    if(_trig){
        if(_detectPulse)
            _checkVal();
        else {
            _detectPulse = true;
        }
    }
    _pulseTimer->start();
}

//------------------------------------------------------------------------------
void InETag::pulseTimerEnd()
{
    _detectPulse = false;
    if(! _trig) _checkVal();
}
//------------------------------------------------------------------------------
//bool InETag::findLimitTags()
//{
//    bool res = true;
//    res &= connectTagToMaxLevel( new OutETag(_owner, /*Prom::TpOut,*/ Prom::PreSet, _name + " макс.", _DBName + ".max",false,false,false,true,Prom::VCNo,false,false,0,true));
//    res &= connectTagToMinLevel( new OutETag(_owner, /*Prom::TpOut,*/ Prom::PreSet, _name + " мин.",  _DBName + ".min",false,false,false,true,Prom::VCNo,false,false,0,true));
//    _tunabDetectLevel = !res;
//    return res;
//}

//------------------------------------------------------------------------------

void InETag::_customConnectToGUI(QObject *, QObject *engRow)
{
    QVariant ret;
    QObject * tmpSgSt;

    //!создал в строке главный раздел
    QMetaObject::invokeMethod(engRow, "addPropertyValue", Qt::DirectConnection,
        Q_RETURN_ARG(QVariant, ret),
        Q_ARG(QVariant, this->fullTagName() + "_PrVal"),
        Q_ARG(QVariant, this->getName()));

    //tmpSgSt = propWin->findChild<QObject*>(est->fullTagName() + "_PrSig");
    tmpSgSt = qvariant_cast< QObject* >(ret);
    //получил указатель на главный раздел
    //-----подключил сигналы к значению и имитации
    connect(tmpSgSt, SIGNAL(s_imChanged(bool)),               this,    SLOT(writeImit(bool)),           Qt::QueuedConnection);
    connect(tmpSgSt, SIGNAL(s_imValChanged(QVariant)),        this,    SLOT(writeImitVal(QVariant)),    Qt::QueuedConnection);
    connect(this,    SIGNAL(s_imitationChd(QVariant)),      tmpSgSt, SLOT(setIm(QVariant)),        Qt::QueuedConnection);
    connect(this,    SIGNAL(s_imitationValueChd(QVariant)), tmpSgSt, SLOT(setImVal(QVariant)),     Qt::QueuedConnection);
    connect(this,    SIGNAL(s_liveValueChd(QVariant)),      tmpSgSt, SLOT(setVal(QVariant)),       Qt::QueuedConnection);
    connect(this,    SIGNAL(s_qualityChd(QVariant)),        tmpSgSt, SLOT(setConnected(QVariant)), Qt::QueuedConnection);
    //-----подключил сигналы к значению и имитации

    //!добавляю уровень срабатывания
    if(_tunabDetectLevel){

        QMetaObject::invokeMethod(engRow, "addPropertySetting", Qt::DirectConnection,
            Q_RETURN_ARG(QVariant, ret),
            Q_ARG(QVariant, this->getDBName() + "_delay"),
            Q_ARG(QVariant, " - уровень срабатывания"),
            Q_ARG(QVariant, -1));
        //tmpSgSt = guiItem->findChild<QObject*>(est->getDBName() + "_delay");
        tmpSgSt = qvariant_cast< QObject* >(ret);//получаю указатель на уровень срабатывания
        //подключаю сигналы к уровням срабатывания
        connect(tmpSgSt, SIGNAL(s_valChanged(QVariant)),        this,    SLOT(setDetectLevel(QVariant)), Qt::QueuedConnection);
        connect(this,    SIGNAL(s_delectLevelChanged(QVariant)), tmpSgSt, SLOT(setVal(QVariant)),      Qt::QueuedConnection);
        //подключаю сигналы к уровням срабатывания
    }
}
//------------------------------------------------------------------------------
