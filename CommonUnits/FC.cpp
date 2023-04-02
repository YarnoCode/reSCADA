//#include <qdebug.h>
#include "FC.h"
#include "SCADAenums.h"
//#include "MxMnInETag.h"
#include "InETag.h"
#include "OutETag.h"
#include "InDiscretETag.h"
#include "OutDiscretETag.h"

FCUnitRstFwdFqFq::FCUnitRstFwdFqFq(int *Id,
    QString Name,
    QString TagPrefix,
    bool SelfResetAlarm)

    : Unit( Prom::TypeNoDef,
        Id,
        Name,
        TagPrefix,
        SelfResetAlarm,
        Prom::UnMdStop)
{
    reset = new OutDiscretETag( this, Prom::PreSet, "сброс ошибок", ".resetAlarm",
        true, false, false, false, false, true, false, false,
        false, true,Prom::VCNo, true );
    reset->setImpulseDuration(5);

    fwd = new InDiscretETag(this, "работа", ".FWD",true,false,true,false,false,false);
    connect(fwd, &InDiscretETag::s_qualityChd, this, &FCUnitRstFwdFqFq::updateState);
    connect(fwd, &InDiscretETag::s_detected, this, &FCUnitRstFwdFqFq::updateState);
    connect(fwd, &InDiscretETag::s_undetected, this, &FCUnitRstFwdFqFq::updateState);

    freqPID = new InETag(this, ///*Prom::TpIn,*/
        "установка частоты ЧП от ПИД рег-ра",
        ".freqPID", true, 50, 1, false, false, false, false, true, Prom::VCdiv2);

    freqMan = new OutETag(this, /*Prom::TpOut,*/ Prom::PreSet,
        "ручная установка частоты ЧП", ".freqMan", false, false, false, true, Prom::VCdiv2);
}
//------------------------------------------------------------------------------
bool FCUnitRstFwdFqFq::resetAlarm()
{
    reset->on();
    return Unit::resetAlarm();
}
//------------------------------------------------------------------------------
void FCUnitRstFwdFqFq::_updateStateAndMode()
{
    if(fwd->connected()){

        if(fwd->isDetected()){
            _setCurrentState(Prom::UnStStarted);
            _setCurrentMode(Prom::UnMdStart);
            emit s_started();
        }
        else {
            _setCurrentState(Prom::UnStStoped);
            _setCurrentMode(Prom::UnMdNoDef);
            emit s_stoped();
        }
    }
}
//------------------------------------------------------------------------------
void FCUnitRstFwdFqFq::_customConnectToGUI(QObject *guiItem,  QObject */*propWin*/)
{
    //    connect( reset,   SIGNAL(s_off()), guiItem, SLOT(stoped()) , Qt::QueuedConnection);
    //    connect( reset,   SIGNAL(s_on()),  guiItem, SLOT(started()), Qt::QueuedConnection);
    //    connect( guiItem, SIGNAL( s_start() ), reset, SLOT( on() ), Qt::QueuedConnection );
    connect( freqMan, SIGNAL( s_valueChd(QVariant) ),    guiItem, SLOT( setFreq(QVariant) ), Qt::QueuedConnection );
    connect( guiItem, SIGNAL( s_freqChanged(QVariant) ), freqMan, SLOT( setValue(QVariant) ), Qt::QueuedConnection );
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

FCUnitSFREFF::FCUnitSFREFF(
    int *Id,
    QString Name,
    QString TagPrefix,
    bool SelfResetAlarm)
    : Unit( Prom::TypeNoDef,
        Id,
        Name,
        TagPrefix,
        SelfResetAlarm,
        Prom::UnMdStop)
{
    start = new OutDiscretETag( this, Prom::PreSet, "старт", ".start");
    fwd = new InDiscretETag(this, "вращение", ".fwd",true,false,true,false,false,false);
    fwdAlarm = new InDiscretETag(this, "авария задержки начала вращения", ".alarmFwd",true,false,true,false,false,false);
    fwdAlarm->setAlarmSelfReset(SelfResetAlarm);
    fwdAlarm->needBeUndetectedAlarm();
    reset= new OutDiscretETag( this, Prom::PreSet, "сброс ошибок", ".resetAlarm",
        true, false, false, false, false, true, false, false,
        false, true,Prom::VCNo, true );
    reset->setImpulseDuration(1);
    error = new InDiscretETag(this, "сигнал ошибки ЧП", ".error",true,false,true,false,false,false);
    errorAlarm = new InDiscretETag(this, "авария по сигналу ошибки ЧП", ".error.alarm",true,false,true,false,false,false);
    errorAlarm->needBeUndetectedAlarm();
    //InDiscretETag  *alarm =
    //freqPID = new InETag(this, /*Prom::TpIn,*/"частота от ПИД-регулятора", "!!!!", true, 0, 0, false, false,false,false);
    //freqMan = new InETag(this, /*Prom::TpIn,*/"частота %", ".freq", true, 0, 0, false, false,false,false);
    freq = new InETag(this, /*Prom::TpIn,*/"частота %", ".freq", true, 0, 0, false, false,false,false);

    connect(start, &OutDiscretETag::s_valueChd, this, &FCUnitSFREFF::updateState);
    connect(fwd, &OutDiscretETag::s_valueChd,   this, &FCUnitSFREFF::updateState);
}

//------------------------------------------------------------------------------
void FCUnitSFREFF::setFreqMan(OutETag *newFreqMan)
{
    freqMan = newFreqMan;
    addETag(freqMan);
}
//------------------------------------------------------------------------------
bool FCUnitSFREFF::resetAlarm()
{
    reset->on();
    return Unit::resetAlarm();
}
//------------------------------------------------------------------------------
void FCUnitSFREFF::setFreqPID(InETag *newFreqPID)
{
    freqPID = newFreqPID;
    addETag(freqPID);
}
//------------------------------------------------------------------------------
void FCUnitSFREFF::_updateStateAndMode()
{
    if( fwd->isDetected() ){
        if(start->isOn()){
            _setCurrentState(Prom::UnStStarted);
            _setCurrentMode(Prom::UnMdStart);
            emit s_started();
        }
        else{
            _setCurrentState(Prom::UnStStopCommand);
            _setCurrentMode(Prom::UnMdStart);
            emit s_stopComand();
        }
    }
    else{
        if(start->isOn()){
            _setCurrentState(Prom::UnStStartCommand);
            _setCurrentMode(Prom::UnMdStart);
            emit s_startComand();
        }
        else{
            _setCurrentState(Prom::UnStStoped);
            _setCurrentMode(Prom::UnMdStop);
            emit s_stoped();
        }
    }
}
//------------------------------------------------------------------------------
void FCUnitSFREFF::_customConnectToGUI(QObject *guiItem, QObject *)
{
    connect( freqMan, SIGNAL( s_valueChd(QVariant) ),    guiItem, SLOT( setFreq(QVariant) ), Qt::QueuedConnection );
    connect( guiItem, SIGNAL( s_freqChanged(QVariant) ), freqMan, SLOT( setValue(QVariant) ), Qt::QueuedConnection );
    connect( freq, SIGNAL( s_valueChd(QVariant) ),       guiItem, SLOT( setFreqLive(QVariant) ), Qt::QueuedConnection );

    connect(this,    SIGNAL(s_startComand()),           guiItem, SLOT(startComand()),             Qt::QueuedConnection);
    connect(this,    SIGNAL(s_stopComand()),            guiItem, SLOT(stopComand()),              Qt::QueuedConnection);
    //    connect(guiItem, SIGNAL(s_start()),                 this,    SLOT(start()),                   Qt::QueuedConnection);
    //    connect(guiItem, SIGNAL(s_stop()),                  this,    SLOT(stop()),                    Qt::QueuedConnection);
    connect(this,    SIGNAL(s_stoped()),                guiItem, SLOT(stoped()) ,                 Qt::QueuedConnection);
    connect(this,    SIGNAL(s_manualStarted()),         guiItem, SLOT(manualWork()) ,             Qt::QueuedConnection);
    connect(this,    SIGNAL(s_started()),               guiItem, SLOT(started()),                 Qt::QueuedConnection);

}
//------------------------------------------------------------------------------
