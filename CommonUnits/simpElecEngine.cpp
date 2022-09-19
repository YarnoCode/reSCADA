//#include <qdebug.h>
#include "simpElecEngine.h"
#include "SCADAenums.h"
//#include "MxMnInETag.h"
#include "InETag.h"
#include "OutETag.h"
#include "InDiscretETag.h"
#include "OutDiscretETag.h"

SimpElecEngine::SimpElecEngine(
    Prom::UnitType Type,
    int *Id,
    QString Name,
    QString TagPrefix,
    bool SelfResetAlarm)

    : Unit( Type,
        Id,
        Name,
        TagPrefix,
        SelfResetAlarm,
        Prom::UnMdStop)
{
    _alarm = new InDiscretETag(this, "авария", ".alarm",true,false,true,false,false,false);
    _alarm->setAlarmSelfReset(SelfResetAlarm);
    _alarm->needBeUndetectedAlarm();
    _alarmKM = new InDiscretETag(this, "авария контактора", ".alarmKM",true,false,true,false,false,false);
    _alarmKM->setAlarmSelfReset(SelfResetAlarm);
    _alarmKM->needBeUndetectedAlarm();
    _alarmQF= new InDiscretETag(this, "авария автомата", ".alarmQF",true,false,true,false,false,false);
    _alarmQF->setAlarmSelfReset(SelfResetAlarm);
    _alarmQF->needBeUndetectedAlarm();
    _reset = new OutDiscretETag( this, Prom::PreSet, "сброс ошибок", ".resetAlarm",
        true, false, false, false, false, true, false, false,
        false, true,Prom::VCNo, true );
    _reset->setImpulseDuration(5);

    _start= new OutDiscretETag( this, Prom::PreSet, "старт", ".start",
        true, false, false, false, false, true );
    _start->setAlarmSelfReset(SelfResetAlarm);
    connect(_start, &OutDiscretETag::s_on, this, &SimpElecEngine::updateState);
    connect(_start, &OutDiscretETag::s_off, this, &SimpElecEngine::updateState);

    _started = new InDiscretETag(this, "работа", ".started",true,false,true,false,false,false);
    _started->setAlarmSelfReset(SelfResetAlarm);
    connect(_started, &InDiscretETag::s_detected, this, &SimpElecEngine::updateState);
    connect(_started, &InDiscretETag::s_undetected, this, &SimpElecEngine::updateState);

    _QF = new InDiscretETag(this, "автомат", ".QF",true,false,true,false,false,false);
    _KM = new InDiscretETag(this, "контактор", ".KM",true,false,true,false,false,false);
}
//------------------------------------------------------------------------------
bool SimpElecEngine::resetAlarm()
{
    _reset->on();
    return Unit::resetAlarm();
}
//------------------------------------------------------------------------------
Prom::SetModeResp SimpElecEngine::_customSetMode(Prom::UnitModes *Mode, bool)
{
    switch(*Mode) {
    case Prom::UnMdFreeze:
    case Prom::UnMdStop:{
        stop();
        if(currentState() == Prom::UnStStoped)
            return Prom::DoneAlready;
        else{
            //            _setSetedMode(*Mode);
            return Prom::DoneWhait;
        }

        break;
    }
    case Prom::UnMdStart:
        if( _sensorsConnected && ! _alarm) {
            if(currentState() == Prom::UnStStarted)
                return Prom::DoneAlready;
            else if(start()){
                //                _setSetedMode(*Mode);
                return Prom::DoneWhait;
            }
        }
        break;
    default:;
    }
    return RejAnnown;
}
//------------------------------------------------------------------------------
void SimpElecEngine::_updateStateAndMode()
{
    if(_start && _started){

        if(_start->isOn()){
            if(_started->isDetected() ){
                _setCurrentState(Prom::UnStStarted);
                _setCurrentMode(Prom::UnMdStart);
                emit s_started();
            }
            else {
                _setCurrentState(Prom::UnStStartCommand);
                emit s_startComand();
            }
        }
        else {
            if(_started->isDetected() ){
                if( currentState() == Prom::UnStStarted){
                    _setCurrentState(Prom::UnStStopCommand);
                    emit s_stopComand();
                }
                else{
                    _setCurrentState(Prom::UnStManualStarted);
                    _setCurrentMode(Prom::UnMdManualStarted);
                    emit s_manualStarted();
                }
            }
            else{
                _setCurrentState(Prom::UnStStoped);
                _setCurrentMode(Prom::UnMdStop);
                emit s_stoped();
            }
        }
    }
}
//------------------------------------------------------------------------------
bool SimpElecEngine::start()
{
    if(_start) {
        return _start->on();
    }
    else return false;
}
//------------------------------------------------------------------------------
bool SimpElecEngine::stop()
{
    if(_start) {
        return _start->off();
    }
    else return false;
}
//------------------------------------------------------------------------------
void SimpElecEngine::_customConnectToGUI(QObject *guiItem,  QObject */*propWin*/)
{
    connect(this,    SIGNAL(s_startComand()),           guiItem, SLOT(startComand()),             Qt::QueuedConnection);
    connect(this,    SIGNAL(s_stopComand()),            guiItem, SLOT(stopComand()),              Qt::QueuedConnection);
    connect(guiItem, SIGNAL(s_start()),                 this,    SLOT(start()),                   Qt::QueuedConnection);
    connect(guiItem, SIGNAL(s_stop()),                  this,    SLOT(stop()),                    Qt::QueuedConnection);
    connect(this,    SIGNAL(s_stoped()),                guiItem, SLOT(stoped()) ,                 Qt::QueuedConnection);
    connect(this,    SIGNAL(s_manualStarted()),         guiItem, SLOT(manualWork()) ,             Qt::QueuedConnection);
    connect(this,    SIGNAL(s_started()),               guiItem, SLOT(started()),                 Qt::QueuedConnection);
}
//------------------------------------------------------------------------------
