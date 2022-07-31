
#include "boiler.h"

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
Boiler::Boiler(
    int *Id,
    QString Name,
    QString TagPefix,
    QString lvlPIDPefix,
    QString steamPIDPefix,
    QString smokePIDPefix,
    QString airPIDPefix,
    bool SelfAlarmReset,
    const pid::tagsMap *PIDTagsNames)
    : Unit(
        Prom::TypeBoiler,
        Id,
        Name,
        TagPefix,
        SelfAlarmReset)
{
    _currentMode = Prom::UnMdCantHaveMode;

    alarmBtn = new InDiscretETag(this, "СТОП-КНОПКА", ".alarmBtn.alarm",true,false,true,false,false,false);
    lvlLowAlarm = new InDiscretETag(this, "нижний аварийный уровень воды", ".lvlLowAlarm.alarm",true,false,true,false,false,false);
    lvlHiAlarm = new InDiscretETag(this, "верхний аварийный уровень воды", ".lvlHiAlarm.alarm",true,false,true,false,false,false);
    lvlLowWork = new InDiscretETag(this, "нижний рабочий уровень воды", ".lvlLowWork",true,false,true,false,false,false);
    lvlHiWork = new InDiscretETag(this, "верхний рабочий уровень воды", ".lvlHiWork",true,false,true,false,false,false);

    vGas_open = new OutDiscretETag( this, Prom::PreSet, "открыть главный газовый клапан", ".vGas.open");
    vGasSml_open = new OutDiscretETag( this, Prom::PreSet, "открыть перепускной газовый клапан", ".vGasSml.open");
    vCandle_close = new OutDiscretETag( this, Prom::PreSet, "закрыть клапан свечи безопасности", ".vGasSml.open");
    autoMod = new OutDiscretETag( this, Prom::PreSet, "автоматический режим", ".autoMod");

    stay = new InETag(this, Prom::TpIn,"№ состояния", ".stay", true, 0, 0, false, false,false,false);
    connect(stay, &InDiscretETag::s_detected,   this, &Boiler::updateState);
    connect(stay, &InDiscretETag::s_undetected, this, &Boiler::updateState);

    startCmd = new OutDiscretETag( this, Prom::PreSet, "запуск", ".startCmd");
    reqAlarmBtnPress = new InDiscretETag(this, "нужно нажать СТОП-КНОПКУ", ".reqAlarmBtnPress",true,false,true,false,false,false);
    reqUserConf = new InDiscretETag(this, "нужно подтверждение от оператора", ".reqUserConf",true,false,true,false,false,false);
    userConfd = new OutDiscretETag( this, Prom::PreSet, "подтверждение от оператора", ".userConfd");
    blowdownCmd = new OutDiscretETag( this, Prom::PreSet, "продувка", ".blowdownCmd");

    coldStartHating = new InETag(this, Prom::TpIn,"прогрев холодной кладки %", ".coldStartHating", true, 0, 0, false, false,false,false);
    hot = new InETag(this, Prom::TpIn,"нагрев котла %", ".hot", true, 0, 0, false, false,false,false);

    germTestStart = new OutDiscretETag( this, Prom::PreSet, "запуск теста герметичности", ".germTestStart");
    germTestStage = new InETag(this, Prom::TpIn,"№ этапа теста", ".germTestStage", true, 0, 0, false, false,false,false);

    pGasIgnition = new OutETag(this, Prom::TpOut,Prom::PreSet,"давление газа при позжиге кПа", ".pGasIgnition", true,false,false,true,Prom::VCNo,false, false,0,true);
    pGasHeating = new OutETag(this, Prom::TpOut,Prom::PreSet,"давление газа при прогреве кПа", ".pGasHeating", true,false,false,true,Prom::VCNo,false, false,0,true);
    pGasBV = new InETag(this, Prom::TpIn,"давление газа между клапанами кПа", ".pGasBV", true, 0, 0.1, false, false,false,false);

    lvlWater = new MxMnInETag( this, Prom::TpMxMnIn, "уровень воды %", ".lvlWater.value", 100, 50, 2, false, false );
    lvlWater->needBeUndetectedAlarm();
    lvlWater->findMaxMinTags();

    pGas = new MxMnInETag( this, Prom::TpMxMnIn, "давление газа кПа", ".pGas.value", 5, 1, 0.1, false, false );
    pGas->needBeUndetectedAlarm();
    pGas->findMaxMinTags();

    pAir = new MxMnInETag( this, Prom::TpMxMnIn, "давление воздуха кПа", ".pAir.value", 5, 0.1, 0.1, false, false );
    pAir->needBeUndetectedAlarm();
    pAir->findMaxMinTags();

    pSmoke = new MxMnInETag( this, Prom::TpMxMnIn, "разряжение в топке кПа", ".pSmoke.value", -0.1, -0.5, 0.1, false, false );
    pSmoke->needBeUndetectedAlarm();
    pSmoke->findMaxMinTags();

    pSteam = new MxMnInETag( this, Prom::TpMxMnIn, "разряжение в топке кПа", ".pSmoke.value", -0.1, -0.5, 0.1, false, false );
    pSteam->needBeUndetectedAlarm();
    pSteam->findMaxMinTags();

    tSmoke;//.value;

    reset = new OutDiscretETag( this, Prom::PreSet, "сброс аварий", ".resetAlarm");
    alarm = new InDiscretETag(this, "авария", ".alarm",true,false,true,false,false,false);
    alarmGermVCandle = new InDiscretETag(this, "авария герметичности клапана свечи", ".alarmGermVCandle.alarm",true,false,true,false,false,false);
    alarmGermVCandle->needBeUndetectedAlarm();
    alarmGermVBurnersOrCandle = new InDiscretETag(this, "авария герметичности глапанов горелок или клапана свечи", ".alarmGermVBurnersOrCandle.alarm",true,false,true,false,false,false);
    alarmGermVBurnersOrCandle->needBeUndetectedAlarm();
    alarmGermVGas = new InDiscretETag(this, "авария герметичности главного или перепускного клапана", ".alarmGermVGas.alarm",true,false,true,false,false,false);
    alarmGermVGas->needBeUndetectedAlarm();
    alarmGermTestStage = new InDiscretETag(this, "авария стадии теста на герметичность", ".alarmGermTestStage",true,false,true,false,false,false);
    alarmGermTestStage->needBeUndetectedAlarm();

    pumpWater_selectReserv = new InDiscretETag(this, "выбран резервный водяной насос", ".pumpWater.selectReserv",true,false,true,false,false,false);;

    blowdownDelay = new OutETag(this, Prom::TpOut,Prom::PreSet,"время продувки в с.", ".blowdownDelay", true,false,false,true,Prom::VCdiv1000,false, false,0,true);
    startStage = new InETag(this, Prom::TpIn,"№ этапа запуска", ".startStage", true, 0, 0, false, false,false,false);
    hotDelay = new OutETag(this, Prom::TpOut,Prom::PreSet,"время полного прогрева котла в с.", ".hotDelay", true,false,false,true,Prom::VCdiv1000,false, false,0,true);
    coldStartHotDelay = new OutETag(this, Prom::TpOut,Prom::PreSet,"время прогрева кладки в с.", ".coldStartHotDelay", true,false,false,true,Prom::VCdiv1000,false, false,0,true);
    unhotDelay = new OutETag(this, Prom::TpOut,Prom::PreSet,"время остывания котла с продувкой в с.", ".unhotDelay", true,false,false,true,Prom::VCdiv1000,false, false,0,true);



    tWater = new MxMnInETag( this, Prom::TpMxMnIn, "t°C воды", ".tWater", 120, 5, 2, false, false );
    tWater->needBeUndetectedAlarm();
    tWater->findMaxMinTags();

    pSteam = new MxMnInETag( this, Prom::TpMxMnIn, "давление пара", ".pSteam", 4, 0.5, 0.05, false, false );
    pSteam->needBeUndetectedAlarm();
    pSteam->findMaxMinTags();

    alarm = new InDiscretETag(this, "aвария", ".alarm",true,false,true,false,false,false);
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
bool Boiler::resetAlarm()
{
    reset->on();
    return Unit::resetAlarm();
}

//------------------------------------------------------------------------------
void Boiler::_customConnectToGUI(QObject *guiItem, QObject *)
{
    connect( this, SIGNAL(s_work()),      guiItem, SLOT(stateWork()),        Qt::QueuedConnection);
    connect( this, SIGNAL(s_vent()),      guiItem, SLOT(stateVent()),        Qt::QueuedConnection);
    connect( this, SIGNAL(s_ventStop() ), guiItem, SLOT(stateVentAndStop()), Qt::QueuedConnection);
    connect( this, SIGNAL(s_alarmVent()), guiItem, SLOT(stateAlarmVent()),   Qt::QueuedConnection);
    connect( this, SIGNAL(s_warmingUp()), guiItem, SLOT(stateWarmingUp()),   Qt::QueuedConnection);
    connect( this, SIGNAL(s_stoped()),    guiItem, SLOT(stateStoped()),      Qt::QueuedConnection);
    connect( this, SIGNAL(s_fireStart()), guiItem, SLOT(stateFireStart()),      Qt::QueuedConnection);
    if( guiItem != nullptr ){
        AnalogSignalVar2Connect(guiItem, tWater->getDBName(), tWater);
        AnalogSignalVar2Connect(guiItem, pSteam->getDBName(), pSteam);
        PIDwinConnect(guiItem, lvlPID->tagPrefix, lvlPID);
        PIDwinConnect(guiItem, steamPID->tagPrefix, steamPID);
    }
}
//------------------------------------------------------------------------------
void Boiler::_updateStateAndMode()
{
    if( mltSt == 0){
        if(currentMode() == Prom::UnMdCollingStop)
            _setCurrentMode(Prom::UnMdCollingStoped);
        else
            _setCurrentMode(Prom::UnMdStop);
        emit s_stoped();
    }
    if(work->isDetected()){
        _setCurrentMode(Prom::UnMdStart);
        emit s_work();
    }
    if( ventStop->isDetected()){
        _setCurrentMode(Prom::UnMdCollingStop);
        emit s_ventStop();
    }
    if( vent->isDetected()){
        _setCurrentMode(Prom::UnMdColling);
        emit s_vent();
    }
    if( warmingUp->isDetected()){
        _setCurrentMode(Prom::UnMdWarmingUp);
        emit s_warmingUp();
    }
    if( fireStart->isDetected()){
        _setCurrentMode(Prom::UnMdFireStart);
        emit s_fireStart();
    }
    if( alarmVent->isDetected()){
        _setCurrentMode(Prom::UnMdColling);
        emit s_alarmVent();
    }
}
//------------------------------------------------------------------------------


