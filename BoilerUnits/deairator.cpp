
#include "deairator.h"

#include "FC.h"
#include "InETag.h"
#include "OutETag.h"
#include "InDiscretETag.h"
#include "OutDiscretETag.h"
#include "MxMnInETag.h"
#include "simpElecEngine.h"
#include "regValveDO.h"
#include "GUIconnect.h"


//------------------------------------------------------------------------------
Deairator::Deairator(int *Id,
    QString Name,
    QString TagPefix,
    QString lvlPIDPefix,
    QString steamPIDPefix,
    bool SelfAlarmReset,
    const pid::tagsMap *PIDTagsNames )
    : Tank( Id,
        Name,
        TagPefix,
        SelfAlarmReset)
{
    _currentMode = Prom::UnMdCantHaveMode;

    tWater = new MxMnInETag( this, Prom::TpMxMnIn, "t°C воды", ".tWater", 120, 5, 2, false, false );
    tWater->needBeUndetectedAlarm();
    tWater->findMaxMinTags();

    pSteam = new MxMnInETag( this, Prom::TpMxMnIn, "давление пара", ".pSteam", 4, 0.5, 0.05, false, false );
    pSteam->needBeUndetectedAlarm();
    pSteam->findMaxMinTags();

    alarm = new InDiscretETag(this, "aвария", ".alarm",true,false,true,false,false,false);
    alarm->needBeUndetectedAlarm();
    reset = new OutDiscretETag( this, Prom::PreSet, "сброс ошибок", ".resetAlarm",
        true, false, false, false, false, true, false, false,
        false, true,Prom::VCNo, true );
    reset->setImpulseDuration(5);

    lvlPID = new PIDstep(this, "ПИД уровня воды", "частота насоса",lvlPIDPefix,PIDTagsNames, PIDopt::allOn );
    steamPID = new PIDstep(this, "ПИД давления пара", "положение клапана", steamPIDPefix, PIDTagsNames, PIDopt::allOn );

    waterFC = new FCUnitOkSrtFq0Fq0(Id, "ЧП насосов воды", TagPefix + ".FCWater", true);
    waterFC->setFreqMan( lvlPID->manImp);
    waterFC->setFreqPID( lvlPID->impIn);
    addSubUnit(waterFC);

    waterPump1 = new SimpElecEgine( Prom::TypePump, Id, "Насос охл. воды 1", TagPefix + ".pumpWater1", true);
    addSubUnit(waterPump1);
    waterPump2 = new SimpElecEgine( Prom::TypePump, Id, "Насос охл. воды 2", TagPefix + ".pumpWater2", true);
    addSubUnit(waterPump2);

    vSteam = new RegValveDO( Id, "Клапан подачи пара", TagPefix + ".vSteam", true, &regValve::SiemensPIDTagsNames);
    addSubUnit(vSteam);
}

//------------------------------------------------------------------------------
bool Deairator::resetAlarm()
{
    reset->on();
    return Unit::resetAlarm();
}

//------------------------------------------------------------------------------
void Deairator::_customConnectToGUI(QObject *guiItem, QObject *)
{
    Tank::_customConnectToGUI(guiItem);

    if( guiItem != nullptr ){
        AnalogSignalVar2Connect(guiItem, tWater->getDBName(), tWater);
        AnalogSignalVar2Connect(guiItem, pSteam->getDBName(), pSteam);
        PIDwinConnect(guiItem, lvlPID->tagPrefix, lvlPID);
        PIDwinConnect(guiItem, steamPID->tagPrefix, steamPID);
    }
}
//------------------------------------------------------------------------------
