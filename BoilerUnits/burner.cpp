#include "burner.h"

#include "FC.h"
#include "InETag.h"
#include "OutETag.h"
#include "InDiscretETag.h"
#include "OutDiscretETag.h"
#include "MxMnInETag.h"
#include "simpElecEngine.h"
#include "regValveDO.h"
#include "GUIconnect.h"
#include "workUnit.h"

//------------------------------------------------------------------------------
Burner::Burner(int *Id,
    QString Name,
    QString TagPrefix,
    QString pGasPIDPrefix,
    bool SelfAlarmReset,
    const pid::tagsMap *PIDTagsNames )
    : Unit( Prom::TypeNoDef,
        Id,
        Name,
        TagPrefix,
        SelfAlarmReset)
{
    _currentMode = Prom::UnMdCantHaveMode;

    alarm = new InDiscretETag(this, "aвария", ".alarm",true,false,true,false,false,false);

    alarm->setAlarmSelfReset(SelfAlarmReset);
    alarm->needBeUndetectedAlarm();
    alarmFlame = new InDiscretETag(this, "aвария задержки на появление пламени горелки", ".alarmFlame",true,false,true,false,false,false);
    alarmFlame->setAlarmSelfReset(SelfAlarmReset);
    alarmFlame->needBeUndetectedAlarm();
    reset = new OutDiscretETag( this, Prom::PreSet, "сброс аварий", ".resetAlarm",
        true, false, false, false, false, true, false, false,
        false, true,Prom::VCNo, true );
    reset->setImpulseDuration(1);
    state = new InETag( this, /*Prom::TpIn,*/ "состояние горелки", ".state", true, 100, 1, false, false, false, false );
    disabled = new OutDiscretETag( this, Prom::PreSet, "отключена", +".disabled",true, false, false, false, false, true );
    pGas = new InETag( this, /*Prom::TpMxMnIn,*/ "давление газа", ".pGas", true, 4, 0.05, false, false, false, false );
    flameS    = new InDiscretETag(this, "датчик пламени горелки", ".flameS",true,false,true,false,false,false);
    ignitionAlarmDelay  = new OutETag(this, /*Prom::TpOut,*/Prom::PreSet,"задержка на появление пламени розжига с.", ".ignitionAlarmDelay", false,false,false,true,Prom::VCdiv1000,false,false,0,true);
    ignitionStableDelay = new OutETag(this, /*Prom::TpOut,*/Prom::PreSet,"задержка на стабилизацию пламени розжига с.",    ".ignitionStableDelay",false,false,false,true,Prom::VCdiv1000,false,false,0,true);
    flameStartDelay     = new OutETag(this, /*Prom::TpOut,*/Prom::PreSet,"задержка на появление пламени горелки с.", ".flameStartDelay",    false,false,false,true,Prom::VCdiv1000,false,false,0,true);
    flameStableDelay    = new OutETag(this, /*Prom::TpOut,*/Prom::PreSet,"задержка стабилизацию пламени горелки с.",    ".flameStableDelay",   false,false,false,true,Prom::VCdiv1000,false,false,0,true);

    gasPID = new PIDstep(this, "ПИД давления газа", "положение клапана", pGasPIDPrefix, &pid::SiemensCONT_CPIDTagsNames, PIDopt::SimensCONT_S & ~PIDopt::feedback );

    ignition = new ActWorkSt(Id, "Рожиг", tagPrefix + ".ignition", false, "искра", ".onOff", true);
    addSubUnit(ignition);
    ignitionS    = new InDiscretETag(this, "датчик пламени розжига", ".ignition.flameS",true,false,true,false,false,false);
    removeETag(ignitionS);
    ignition->addETag(ignitionS);
    alarmIgnition = new InDiscretETag(this, "aвария задержки на появление пламени розжига", ".alarmIgnition",true,false,true,false,false,false);
    alarmIgnition->setAlarmSelfReset(SelfAlarmReset);
    alarmIgnition->needBeUndetectedAlarm();
    removeETag(alarmIgnition);
    ignition->addETag(alarmIgnition);

    vIgnition = new ActWorkSt(Id, "Клапан розжига",  tagPrefix + ".vIgnition", false, "открыть", ".open", true );
    addSubUnit(vIgnition);
    vGas = new ActWorkSt(Id, "Клапан газа",  tagPrefix + ".vGas", false, "открыть", ".open", true );
    addSubUnit(vGas);
    vrGas = new RegValveDO( Id, "Рег-й клапан газа", tagPrefix + ".vrGas", true, &regValve::StdTagsNames);
    addSubUnit(vrGas);
}

//------------------------------------------------------------------------------
bool Burner::resetAlarm()
{
    reset->on();
    return Unit::resetAlarm();
}

//------------------------------------------------------------------------------
void Burner::_customConnectToGUI(QObject *guiItem, QObject *)
{
    if( guiItem != nullptr ){
        if( !AnalogSignalVar2Connect(guiItem, pGas->getDBName(),   pGas) )
            logging(Prom::MessAlarm, QDateTime::currentDateTime(), false, tagPrefix, "не найден " + pGas->getDBName() + " в GUI " + guiItem->objectName());
        PIDwinConnect(guiItem, gasPID->tagPrefix, gasPID);
        connect( flameS,    SIGNAL(s_valueChd(QVariant)), guiItem, SLOT(setFlameS(QVariant)),    Qt::QueuedConnection);

        //        connect( ignitionStart,  SIGNAL(s_valueChd(QVariant)), guiItem, SLOT(setIgnition(QVariant)),    Qt::QueuedConnection);
        //        connect( guiItem,   SIGNAL(s_ignition(QVariant)), ignitionStart, SLOT(setValue(QVariant)),    Qt::QueuedConnection);

        connect( ignitionS, SIGNAL(s_valueChd(QVariant)), guiItem, SLOT(setIgnitionS(QVariant)), Qt::QueuedConnection);

        connect( guiItem,  SIGNAL(s_blocked(QVariant)), disabled, SLOT(setValue(QVariant)),    Qt::QueuedConnection);
        connect( disabled, SIGNAL(s_valueChd(QVariant)), guiItem, SLOT(setBlocked(QVariant)), Qt::QueuedConnection);
        connect( state, SIGNAL(s_valueChd(QVariant)), guiItem, SLOT(setState(QVariant)), Qt::QueuedConnection);
    }
}
//------------------------------------------------------------------------------
