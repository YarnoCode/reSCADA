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

    freqPID = new InETag(this, Prom::TpIn,
        "установка частоты ЧП от ПИД рег-ра",
        ".freqPID", true, 50, 1, false, false, false, false, true, Prom::VCdiv2);

    freqMan = new OutETag(this, Prom::TpOut, Prom::PreSet,
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

FCUnitOkSrtFq0Fq0::FCUnitOkSrtFq0Fq0(
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
    ok = new InDiscretETag(this, "ошибка", ".ok.alarm",true,false,true,false,false,false);
    ok->setAlarmSelfReset(SelfResetAlarm);
    ok->needBeUndetectedAlarm();
    reset = new OutDiscretETag( this, Prom::PreSet, "сброс ошибок", ".ok.resetAlarm",
        true, false, false, false, false, true, false, false,
        false, true,Prom::VCNo, true );
    reset->setImpulseDuration(1);
    start = new InDiscretETag(this, "старт", ".start",true,false,true,false,false,false);
    connect(start, &InDiscretETag::s_qualityChd, this, &FCUnitRstFwdFqFq::updateState);
    connect(start, &InDiscretETag::s_detected, this, &FCUnitRstFwdFqFq::updateState);
    connect(start, &InDiscretETag::s_undetected, this, &FCUnitRstFwdFqFq::updateState);
}

//------------------------------------------------------------------------------
void FCUnitOkSrtFq0Fq0::setFreqMan(OutETag *newFreqMan)
{
    freqMan = newFreqMan;
    addETag(freqMan);
}
//------------------------------------------------------------------------------
bool FCUnitOkSrtFq0Fq0::resetAlarm()
{
    reset->on();
    return Unit::resetAlarm();
}
//------------------------------------------------------------------------------
void FCUnitOkSrtFq0Fq0::setFreqPID(InETag *newFreqPID)
{
    freqPID = newFreqPID;
    addETag(freqPID);
}
//------------------------------------------------------------------------------
void FCUnitOkSrtFq0Fq0::_updateStateAndMode()
{
        if(start->connected()){

        if(start->isDetected()){
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
void FCUnitOkSrtFq0Fq0::_customConnectToGUI(QObject *guiItem, QObject *)
{
    connect( freqMan, SIGNAL( s_valueChd(QVariant) ),    guiItem, SLOT( setFreq(QVariant) ), Qt::QueuedConnection );
    connect( guiItem, SIGNAL( s_freqChanged(QVariant) ), freqMan, SLOT( setValue(QVariant) ), Qt::QueuedConnection );
}
//------------------------------------------------------------------------------
