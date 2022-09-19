//#include <qdebug.h>
#include "workUnit.h"
#include "SCADAenums.h"
//#include "MxMnInETag.h"
#include "InETag.h"
#include "OutETag.h"
#include "InDiscretETag.h"
#include "OutDiscretETag.h"

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
ActWorkSt::ActWorkSt(
    int *Id,
    QString Name,
    QString TagPrefix,
    bool ReverseStartSig,
    QString startSigName,
    QString startSigDBName,
    bool SelfAlarmReset,
    Prom::UnitModes SaveMode)
        : Unit( TypeNoDef,
        Id,
        Name,
        TagPrefix,
        SelfAlarmReset,
        SaveMode)
{
    start = new OutDiscretETag(this,Prom::PreSet, startSigName, startSigDBName, !ReverseStartSig, ReverseStartSig);
    connect(start, &OutDiscretETag::s_qualityChd, this, &ActWorkStWk::updateState);
    connect(start, &OutDiscretETag::s_on,   this, &ActWorkStWk::updateState);
    connect(start, &OutDiscretETag::s_off,  this, &ActWorkStWk::updateState);
}
//------------------------------------------------------------------------------
void ActWorkSt::_updateStateAndMode()
{
    if(start->connected()){

        if(start->isOn()){
            _setCurrentState(Prom::UnStStarted);
            _setCurrentMode(Prom::UnMdStart);
        }
        else {
            _setCurrentState(Prom::UnStStoped);
            _setCurrentMode(Prom::UnMdStop);
        }
    }
    else{
        _setCurrentState(Prom::UnStNotConnected);
        _setCurrentMode(Prom::UnMdNoDef);
    }
}
//------------------------------------------------------------------------------
SetModeResp ActWorkSt::_customSetMode(Prom::UnitModes *Mode, bool)
{
    switch(*Mode) {
    case Prom::UnMdStop:{
        start->off();
        _setSetedMode(*Mode);
        return Prom::DoneAlready;
        break;
    }
    case Prom::UnMdStart:{
        if(_alarm)return Prom::RejAlarm;
        if(currentState() == Prom::UnStStoped) {
            if(start->on())
                _setSetedMode(*Mode);
            return Prom::DoneAlready;
        }
        else
            return Prom::RejNoCond;
        break;
    }
    default: return Prom::RejAnnown;
    }
}
//------------------------------------------------------------------------------
void ActWorkSt::on()
{
    setMode(Prom::UnMdStart, true);
}
//------------------------------------------------------------------------------
void ActWorkSt::off()
{
    setMode(Prom::UnMdStop, true);
}
//------------------------------------------------------------------------------
void ActWorkSt::_customConnectToGUI(QObject *guiItem, QObject *)
{
    connect( start,   SIGNAL(s_on()),    guiItem, SLOT(started()), Qt::QueuedConnection);
    connect( start,   SIGNAL(s_off()),   guiItem, SLOT(stoped()),  Qt::QueuedConnection);
    connect( guiItem, SIGNAL(s_start()), this,    SLOT(on()),      Qt::QueuedConnection);
    connect( guiItem, SIGNAL(s_stop()),  this,    SLOT(off()),     Qt::QueuedConnection);
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
ActWorkStWk::ActWorkStWk(int *Id,
    QString Name,
    QString TagPrefix,
    bool ReverseWorkSig,
    QString workSigName,
    QString workSigDBName,
    bool ReverseStartSig,
    QString startSigName,
    QString startSigDBName,
    bool SelfAlarmReset,
    Prom::UnitModes SaveMode)
    : Unit( TypeNoDef,
        Id,
        Name,
        TagPrefix,
        SelfAlarmReset,
        SaveMode)
{
    work = new InDiscretETag(this, workSigName, workSigDBName, !ReverseWorkSig, ReverseWorkSig, true, false, false, false, true );
    connect(work, &InDiscretETag::s_qualityChd, this, &ActWorkStWk::updateState);
    connect(work, &InDiscretETag::s_detected,   this, &ActWorkStWk::updateState);
    connect(work, &InDiscretETag::s_undetected, this, &ActWorkStWk::updateState);

    start = new OutDiscretETag(this,Prom::PreSet, startSigName, startSigDBName, !ReverseStartSig, ReverseStartSig);
    connect(start, &OutDiscretETag::s_qualityChd, this, &ActWorkStWk::updateState);
    connect(start, &OutDiscretETag::s_on,   this, &ActWorkStWk::updateState);
    connect(start, &OutDiscretETag::s_off, this, &ActWorkStWk::updateState);
}
//------------------------------------------------------------------------------
void ActWorkStWk::on()
{
    setMode(Prom::UnMdStart, true);
}
//------------------------------------------------------------------------------
void ActWorkStWk::off()
{
    setMode(Prom::UnMdStop, true);
}
//------------------------------------------------------------------------------
void ActWorkStWk::_updateStateAndMode()
{
    if(work->connected()){

        if(work->isDetected()){
            _setCurrentState(Prom::UnStStarted);
            _setCurrentMode(Prom::UnMdStart);
        }
        else {
            _setCurrentState(Prom::UnStStoped);
            _setCurrentMode(Prom::UnMdStop);
        }
    }
    else{
        _setCurrentState(Prom::UnStNotConnected);
        _setCurrentMode(Prom::UnMdNoDef);
    }
}
//------------------------------------------------------------------------------
SetModeResp ActWorkStWk::_customSetMode(Prom::UnitModes *mode, bool /*UserOrSys*/)
{
    switch(*mode) {
    case Prom::UnMdStop:{
        start->off();
        _setSetedMode(*mode);
        return Prom::DoneAlready;
        break;
    }
    case Prom::UnMdStart:{
        if(_alarm)return Prom::RejAlarm;
        if(currentState() == Prom::UnStStoped) {
            if(start->on())
                _setSetedMode(*mode);
            return Prom::DoneAlready;
        }
        else
            return Prom::RejNoCond;
        break;
    }
    default: return Prom::RejAnnown;
    }
}
//------------------------------------------------------------------------------
void ActWorkStWk::_customConnectToGUI(QObject *guiItem, QObject *)
{
    connect( work,    SIGNAL(s_undetected()), guiItem, SLOT(stoped()) , Qt::QueuedConnection);
    connect( work,    SIGNAL(s_detected()),   guiItem, SLOT(started()), Qt::QueuedConnection);
    connect( guiItem, SIGNAL(s_start()),      this,    SLOT(on()),   Qt::QueuedConnection);
    connect( guiItem, SIGNAL(s_stop()),       this,    SLOT(off()),    Qt::QueuedConnection);
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
ActWorkOnOff::ActWorkOnOff(int *Id,
    QString Name,
    QString TagPrefix,
    bool ReverseWorkSig,
    QString workSigName,
    QString workSigDBName,
    bool ReverseStartSig,
    QString startSigName,
    QString startSigDBName,
    bool SelfAlarmReset,
    Prom::UnitModes SaveMode)
    :ActWorkStWk(
        Id,
        Name,
        TagPrefix,
        ReverseWorkSig,
        workSigName,
        workSigDBName,
        ReverseStartSig,
        startSigName,
        startSigDBName,
        SelfAlarmReset,
        SaveMode)
{
    on_off = new OutDiscretETag(this,Prom::PreSet, "вкл/откл", ".on_off");
}
//------------------------------------------------------------------------------
void ActWorkOnOff::_customConnectToGUI(QObject *guiItem, QObject*)
{
    ActWorkStWk::_customConnectToGUI(guiItem, nullptr);
    connect( on_off,  SIGNAL(s_on()),  guiItem, SLOT(on()) ,   Qt::QueuedConnection);
    connect( on_off,  SIGNAL(s_off()), guiItem, SLOT(off()),   Qt::QueuedConnection);
    connect( guiItem, SIGNAL(s_on()),  on_off,  SLOT(on()), Qt::QueuedConnection);
    connect( guiItem, SIGNAL(s_off()), on_off,  SLOT(off()),  Qt::QueuedConnection);
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
PsvWork::PsvWork(
    int *Id,
    QString Name,
    QString TagPrefix,
    bool SelfAlarmReset,
    Prom::UnitModes SaveMode)
    : Unit( TypeNoDef,
        Id,
        Name,
        TagPrefix,
        SelfAlarmReset,
        SaveMode)
{
    work = new InDiscretETag(this, "работа", ".work",true,false,true,false,false,false);
    work->needBeDetectedAlarm();
    connect(work, &InDiscretETag::s_qualityChd, this, &PsvWork::updateState);
    connect(work, &InDiscretETag::s_detected,   this, &PsvWork::updateState);
    connect(work, &InDiscretETag::s_undetected, this, &PsvWork::updateState);
}

//------------------------------------------------------------------------------
void PsvWork::_updateStateAndMode()
{
    if(work->connected()){

        if(work->isDetected()){
            _setCurrentMode(Prom::UnMdStart);
        }
        else {
            _setCurrentMode(Prom::UnMdStop);
        }
    }
    else{
        _setCurrentMode(Prom::UnMdNoDef);
    }
}

//------------------------------------------------------------------------------
void PsvWork::_customConnectToGUI(QObject *guiItem, QObject *)
{
    connect( work,    SIGNAL(s_undetected()),  guiItem, SLOT(stoped()) , Qt::QueuedConnection);
    connect( work,    SIGNAL(s_detected()),    guiItem, SLOT(started()), Qt::QueuedConnection);
}
//------------------------------------------------------------------------------
