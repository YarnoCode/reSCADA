#include "boiler.h"

#include "FC.h"
#include "InETag.h"
#include "OutETag.h"
#include "InDiscretETag.h"
#include "OutDiscretETag.h"
#include "MxMnInETag.h"
#include "simpElecEngine.h"
#include "GUIconnect.h"
#include "workUnit.h"
#include "burner.h"

//------------------------------------------------------------------------------
Boiler::Boiler(
    int *Id,
    QString Name,
    QString TagPrefix,
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
        TagPrefix,
        SelfAlarmReset)
{
    _currentMode = Prom::UnMdCantHaveMode;
    alarm = new InDiscretETag(this, "авария", ".alarm",true,false,true,false,false,false);
    alarm->setAlarmSelfReset(SelfAlarmReset);
    alarm->needBeUndetectedAlarm();
    alarmBtn = new InDiscretETag(this, "СТОП-КНОПКА", ".alarmBtn.alarm",true,false,true,false,false,false);
    alarmBtn->setAlarmSelfReset(SelfAlarmReset);
    alarmBtn->needBeUndetectedAlarm();

    alarmGermTestStage = new InDiscretETag(this, "авария стадии теста на герметичность", ".alarmGermTestStage",true,false,true,false,false,false);
    alarmGermTestStage->setAlarmSelfReset(SelfAlarmReset);
    alarmGermTestStage->needBeUndetectedAlarm();
    pGasBV_alarm = new InDiscretETag(this, "авария давления между клапанами", ".pGasBV.alarm",true,false,true,false,false,false);
    pGasBV_alarm->setAlarmSelfReset(SelfAlarmReset);
    pGasBV_alarm->needBeUndetectedAlarm();

    reset= new OutDiscretETag( this, Prom::PreSet, "сброс аварий", ".resetAlarm",
        true, false, false, false, false, true, false, false,
        false, true,Prom::VCNo, true );
    reset->setImpulseDuration(1);

    autoMod      = new OutDiscretETag( this, Prom::PreSet, "автоматический режим", ".autoMod");
    startCmd     = new OutDiscretETag( this, Prom::PreSet, "запуск", ".startCmd");
    stopCmd      = new OutDiscretETag( this, Prom::PreSet, "стоп", ".stopCmd");
    alarmStopCmd = new OutDiscretETag( this, Prom::PreSet, "аварийный стоп", ".alarmStopCmd");
    startStage = new InETag(this, /*Prom::TpIn,*/"№ этапа запуска", ".startStage", true, 0, 0, false, false,false,false);

    state = new InETag(this, /*Prom::TpIn,*/"№ состояния", ".state", true, 0, 0, false, false,false,false);

    blowdownCmd = new OutDiscretETag( this, Prom::PreSet, "продувка", ".blowdownCmd");
    blowdownET    = new InETag(this, /*Prom::TpIn,*/"продувка ост-ся время", ".blowdownET", true, 0, 0, false, false,false,false,true,Prom::VCdiv1000);
    blowdownDelay = new OutETag(this, /*Prom::TpOut,*/Prom::PreSet,"время продувки в с.", ".blowdownDelay",false,false,false,true,Prom::VCdiv1000,false,false,0,true);
    blowdownFCArFreq = new OutETag(this, /*Prom::TpOut,*/Prom::PreSet,"частота ЧП при продувке Гц", ".blowdownFCArFreq",false,false,false,true,Prom::VCNo,false,false,0,true);
    blowdownPSmoke   = new OutETag(this, /*Prom::TpOut,*/Prom::PreSet,"разряжение в котле при продувке кПа", ".blowdownPSmoke",false,false,false,true,Prom::VCNo,false,false,0,true);

    pAirIgnition  = new OutETag(this, /*Prom::TpOut,*/Prom::PreSet,"давление воздуха при позжиге кПа", ".pAirIgnition",false,false,false,true,Prom::VCNo,false,false,0,true);
    pSmokeIgnition= new OutETag(this, /*Prom::TpOut,*/Prom::PreSet,"разряжение в топке при позжиге кПа", ".pSmokeIgnition",false,false,false,true,Prom::VCNo,false,false,0,true);  ;
    pGasStart = new OutETag(this, /*Prom::TpOut,*/Prom::PreSet,"давление газа при позжиге кПа", ".pGasStart",false,false,false,true,Prom::VCNo,false,false,0,true);
    pGasHeating = new OutETag(this, /*Prom::TpOut,*/Prom::PreSet,"давление газа при прогреве кПа", ".pGasHeating",false,false,false,true,Prom::VCNo,false,false,0,true);

    germTestStart = new OutDiscretETag( this, Prom::PreSet, "запуск теста герметичности", ".germTestStart");
    germTestStage = new InETag(this, /*Prom::TpIn,*/"№ этапа теста", ".germTestStage", true, 0, 0, false, false,false,false);

    //pumpWater_selectReserv = new InDiscretETag(this, "выбран резервный водяной насос", ".pumpWater.selectReserv",true,false,true,false,false,false);

    startHeatingET = new InETag(this, /*Prom::TpIn,*/"оставшееся время прогрева холодной кладки с.", ".startHeatingET", true, 0, 0,false,false,false,false,true,Prom::VCdiv1000);
    startHeatingDelay = new OutETag(this, /*Prom::TpOut,*/Prom::PreSet,"время прогрева кладки в с.", ".startHeatingDelay",false,false,false,true,Prom::VCdiv1000,false,false,0,true);

    heatingET = new InETag(this, /*Prom::TpIn,*/"оставщееся время нагрева котла с.", ".heatingET", true, 0, 0,false,false,false,false,true,Prom::VCdiv1000);
    coolingET = new InETag(this, /*Prom::TpIn,*/"оставщееся время охлаждения котла с.", ".coolingET", true, 0, 0,false,false,false,false,true,Prom::VCdiv1000);

    heatingDelay = new OutETag(this, /*Prom::TpOut,*/Prom::PreSet,"время полного прогрева котла в с.", ".heatingDelay",false,false,false,true,Prom::VCdiv1000,false,false,0,true);

    coolingDelay = new OutETag(this, /*Prom::TpOut,*/Prom::PreSet,"время остывания котла с продувкой в с.", ".coolingDelay",false,false,false,true,Prom::VCdiv1000,false,false,0,true);



    reqAlarmBtnPress = new InDiscretETag(this, "нужно нажать СТОП-КНОПКУ", ".reqAlarmBtnPress",true,false,true,false,false,false);
    reqUserConf = new InDiscretETag(this, "нужно подтверждение от оператора", ".reqUserConf",true,false,true,false,false,false);
    userConfd = new OutDiscretETag( this, Prom::PreSet, "подтверждение от оператора", ".userConfd");

    lvlWater = new MxMnInETag( this, /*Prom::TpMxMnIn,*/ "уровень воды %", ".lvlWater", 100, 50, 2,false,false,false,false,false);
    lvlWater->setAlarmSelfReset(SelfAlarmReset);
    lvlWater->needBeUndetectedAlarm();
    lvlWater->findMaxMinTags();

    pGasBV = new InETag(this, /*Prom::TpIn,*/"давление газа между клапанами кПа", ".pGasBV", true, 0, 0.1, false, false,false,false);
    pGasBV->setAlarmSelfReset(SelfAlarmReset);

    pGas = new MxMnInETag( this, /*Prom::TpMxMnIn,*/ "давление газа кПа", ".pGas", 5, 1, 0.1,false,false,false,false,false );
    pGas->setAlarmSelfReset(SelfAlarmReset);
    pGas->needBeUndetectedAlarm();
    pGas->findMaxMinTags();

    pAir = new MxMnInETag( this, /*Prom::TpMxMnIn,*/ "давление воздуха кПа", ".pAir", 5, 0.1, 0.1,false,false,false,false,false );
    pAir->setAlarmSelfReset(SelfAlarmReset);
    pAir->needBeUndetectedAlarm();
    pAir->findMaxMinTags();

    pSmoke = new MxMnInETag( this, /*Prom::TpMxMnIn,*/ "разряжение в топке кПа", ".pSmoke", -0.1, -0.5, 0.1,false,false,false,false,false );
    pSmoke->setAlarmSelfReset(SelfAlarmReset);
    pSmoke->needBeUndetectedAlarm();
    pSmoke->findMaxMinTags();

    pSteam = new MxMnInETag( this, /*Prom::TpMxMnIn,*/ "давление пара кПа", ".pSteam", -0.1, -0.5, 0.1,false,false,false,false,false );
    pSteam->setAlarmSelfReset(SelfAlarmReset);
    pSteam->needBeUndetectedAlarm();
    pSteam->findMaxMinTags();

    tSmoke = new MxMnInETag( this, /*Prom::TpMxMnIn,*/ "t°C дыма", ".tSmoke", -0.1, -0.5, 0.1,false,false,false,false,false );
    tSmoke->setAlarmSelfReset(SelfAlarmReset);
    tSmoke->needBeUndetectedAlarm();
    tSmoke->findMaxMinTags();

    lvlHiAlarm  = new InDiscretETag(this, "верхний аварийный уровень воды", ".lvlHiAlarm.alarm", true,false,true,false,false,false);
    lvlHiAlarm->setAlarmSelfReset(SelfAlarmReset);
    lvlHiAlarm->needBeUndetectedAlarm();
    lvlLowAlarm = new InDiscretETag(this, "нижний аварийный уровень воды",  ".lvlLowAlarm.alarm",true,false,true,false,false,false);
    lvlLowAlarm->setAlarmSelfReset(SelfAlarmReset);
    lvlLowAlarm->needBeUndetectedAlarm();
    lvlHiWork   = new InDiscretETag(this, "верхний рабочий уровень воды",   ".lvlHiWork",        true,false,true,false,false,false);
    lvlLowWork  = new InDiscretETag(this, "нижний рабочий уровень воды",    ".lvlLowWork",       true,false,true,false,false,false);

    lvlPID   = new PIDstep(this, "ПИД уровня воды", "частота насоса",lvlPIDPefix,PIDTagsNames, PIDopt::allOn );
    steamPID = new PID(this, "ПИД давления пара", "давление газа в горелках", steamPIDPefix, PIDTagsNames, PIDopt::allOn & ~PIDopt::feedback );
    smokePID = new PID(this, "ПИД разряжение в топке", "частота дымососа", smokePIDPefix, PIDTagsNames, PIDopt::allOn & ~PIDopt::feedback);
    airPID   = new PID(this, "ПИД давления воздуха", "частота вентилятора", airPIDPefix,   PIDTagsNames, PIDopt::allOn & ~PIDopt::feedback);

    waterFC = new FCUnitOkSrtFq0Fq0(Id, "ЧП насосов воды", tagPrefix + ".FCWater", SelfAlarmReset);
    waterFC->setFreqMan( lvlPID->manImp);
    waterFC->setFreqPID( lvlPID->impIn);
    addSubUnit(waterFC);

    smokeFC = new FCUnitOkSrtFq0Fq0(Id, "ЧП дымососа", tagPrefix + ".FCSmoke", SelfAlarmReset);
    smokeFC->setFreqMan( smokePID->manImp);
    smokeFC->setFreqPID( smokePID->impIn);
    addSubUnit(smokeFC);

    airFC = new FCUnitOkSrtFq0Fq0(Id, "ЧП вентилятора", tagPrefix + ".FCAir", SelfAlarmReset);
    airFC->setFreqMan( airPID->manImp);
    airFC->setFreqPID( airPID->impIn);
    addSubUnit(airFC);

    waterPump = new SimpElecEngine( Prom::TypePump, Id, "Насос охл. воды", tagPrefix + ".pumpWater", SelfAlarmReset);
    addSubUnit(waterPump);
    waterPumpReserv = new SimpElecEngine( Prom::TypePump, Id, "Резервный насос охл. воды", tagPrefix + ".pumpWaterReserv", SelfAlarmReset);
    addSubUnit(waterPumpReserv);
    ventSmoke = new SimpElecEngine( Prom::TypeFan, Id, "Дымосос", tagPrefix + ".ventSmoke", SelfAlarmReset );
    addSubUnit( ventSmoke );
    ventAir = new SimpElecEngine( Prom::TypeFan, Id, "Воздушный вентилятор", tagPrefix + ".ventAir", SelfAlarmReset );
    addSubUnit( ventAir );

    vGas = new ActWorkSt(Id, "Гавный газовый клапан",  tagPrefix + ".vGas", false, "открыть", ".open", true );
    addSubUnit(vGas);

    alarmGermVGas = new InDiscretETag(this, "авария герметичности главного или перепускного клапана", ".alarmGermVGas.alarm",true,false,true,false,false,false);
    alarmGermVGas->setAlarmSelfReset(SelfAlarmReset);
    alarmGermVGas->needBeUndetectedAlarm();
    removeETag(alarmGermVGas);
    vGas->addETag(alarmGermVGas);

    vGasSml = new ActWorkSt(Id, "Перепускной газовый клапан",  tagPrefix + ".vGasSml", false, "открыть", ".open", true );
    addSubUnit( vGasSml );
    vGasSml->addETag(alarmGermVGas);

    vCandle = new ActWorkSt(Id, "Клапан свечи безопасности",   tagPrefix + ".vCandle", true, "закрыть", ".close", true );
    addSubUnit( vCandle );

    alarmGermVCandle = new InDiscretETag(this, "авария герметичности клапана свечи", ".alarmGermVCandle.alarm",true,false,true,false,false,false);
    alarmGermVCandle->setAlarmSelfReset(SelfAlarmReset);
    alarmGermVCandle->needBeUndetectedAlarm();
    removeETag(alarmGermVCandle);
    vCandle->addETag(alarmGermVCandle);

    alarmGermVBurnersOrCandle = new InDiscretETag(this, "авария герметичности глапанов горелок или клапана свечи", ".alarmGermVBurnersOrCandle.alarm",true,false,true,false,false,false);
    alarmGermVBurnersOrCandle->setAlarmSelfReset(SelfAlarmReset);
    alarmGermVBurnersOrCandle->needBeUndetectedAlarm();
    removeETag(alarmGermVBurnersOrCandle);
    vCandle->addETag(alarmGermVBurnersOrCandle);


    burner1 = new Burner(Id, "Горелка 1", tagPrefix + ".burner1", ".pGas_vrGasPosPID_ES", true, &pid::SiemensPIDTagsNames);
    addSubUnit( burner1 );
    burner1->vGas->addETag(alarmGermVBurnersOrCandle);

    burner2 = new Burner(Id, "Горелка 2", tagPrefix + ".burner2", ".pGas_vrGasPosPID_ES", true, &pid::SiemensPIDTagsNames);
    addSubUnit( burner2 );
    burner2->vGas->addETag(alarmGermVBurnersOrCandle);

}
//------------------------------------------------------------------------------

bool Boiler::resetAlarm()
{
    reset->on();
    return Unit::resetAlarm();
}

//------------------------------------------------------------------------------

void Boiler::_updateStateAndMode()
{
    if( state == 0){
        if(currentMode() == Prom::UnMdCollingStop)
            _setCurrentMode(Prom::UnMdCollingStoped);
        else
            _setCurrentMode(Prom::UnMdStop);
    }
    switch (state->value().toInt()) {
    case states::st_stop     : _setCurrentMode(Prom::UnMdStop);break;
    case states::st_start    : _setCurrentMode(Prom::UnMdAutoStart);break;
    case states::st_work     : _setCurrentMode(Prom::UnMdWork);break;
    case states::st_heating  : _setCurrentMode(Prom::UnMdHeating);break;
    case states::st_cooling  : _setCurrentMode(Prom::UnMdColling);break;
    case states::st_blowdown : _setCurrentMode(Prom::UnMdBlowdown);
    }
}
//------------------------------------------------------------------------------

void Boiler::_customConnectToGUI(QObject *guiItem, QObject *)
{
    if( guiItem != nullptr ){
        connect( guiItem, SIGNAL(s_autoMode(QVariant)), autoMod, SLOT( setValue(QVariant)),   Qt::QueuedConnection);
        connect( autoMod, SIGNAL(s_valueChd(QVariant)), guiItem, SLOT( setAutoMode(QVariant)),Qt::QueuedConnection);

        connect( guiItem,       SIGNAL(s_germTestStart(QVariant)), germTestStart, SLOT( setValue(QVariant)),   Qt::QueuedConnection);
        connect( germTestStart, SIGNAL(s_valueChd(QVariant)), guiItem,            SLOT( setGermTestStart(QVariant)),Qt::QueuedConnection);

        connect( guiItem, SIGNAL(s_start(QVariant)),    startCmd,SLOT(setValue(QVariant)), Qt::QueuedConnection);
        connect( startCmd,SIGNAL(s_valueChd(QVariant)), guiItem, SLOT(setStart(QVariant)), Qt::QueuedConnection);

        connect( guiItem, SIGNAL(s_stop(QVariant)),     stopCmd, SLOT(setValue(QVariant)),        Qt::QueuedConnection);
        connect( stopCmd, SIGNAL(s_valueChd(QVariant)), guiItem, SLOT(setStop(QVariant)), Qt::QueuedConnection);

        connect( guiItem,      SIGNAL(s_alarmStop(QVariant)), alarmStopCmd, SLOT(setValue(QVariant)), Qt::QueuedConnection);
        connect( alarmStopCmd, SIGNAL(s_valueChd(QVariant)),  guiItem, SLOT(setAlarmStop(QVariant)),  Qt::QueuedConnection);

        connect( guiItem,     SIGNAL(s_blowdown(QVariant)), blowdownCmd,  SLOT(setValue(QVariant)), Qt::QueuedConnection);
        connect( blowdownCmd, SIGNAL(s_valueChd(QVariant)), guiItem, SLOT(setBlowdown(QVariant)),   Qt::QueuedConnection);

        connect( state,          SIGNAL(s_valueChd(QVariant)), guiItem, SLOT(setState(QVariant)),          Qt::QueuedConnection);
        connect( startStage,     SIGNAL(s_valueChd(QVariant)), guiItem, SLOT(setStartStage(QVariant)),     Qt::QueuedConnection);
        connect( startHeatingET, SIGNAL(s_valueChd(QVariant)), guiItem, SLOT(setStartHeatingET(QVariant)), Qt::QueuedConnection);
        connect( heatingET,      SIGNAL(s_valueChd(QVariant)), guiItem, SLOT(setHeatingET(QVariant)),      Qt::QueuedConnection);
        connect( blowdownET,     SIGNAL(s_valueChd(QVariant)), guiItem, SLOT(setBlowdownET(QVariant)),     Qt::QueuedConnection);
        connect( coolingET,      SIGNAL(s_valueChd(QVariant)), guiItem, SLOT(setCoolingET(QVariant)),      Qt::QueuedConnection);

        connect( pGasBV_alarm, SIGNAL(s_valueChd(QVariant)), guiItem, SLOT(setAlarmPGasBV(QVariant)), Qt::QueuedConnection);

        connect( reqAlarmBtnPress, SIGNAL(s_valueChd(QVariant)),  guiItem,   SLOT(setReqAlarmBtnPress(QVariant)), Qt::QueuedConnection);
        connect( reqUserConf,      SIGNAL(s_valueChd(QVariant)),  guiItem,   SLOT(setReqUserConf(QVariant)),      Qt::QueuedConnection);
        connect( guiItem,          SIGNAL(s_userConfd(QVariant)), userConfd, SLOT(setValue(QVariant)),            Qt::QueuedConnection);

        if(! AnalogSignalVar2Connect(guiItem, tSmoke->getDBName(), tSmoke) )
            logging(Prom::MessAlarm, QDateTime::currentDateTime(), false, tagPrefix, "не найден " + tSmoke->getDBName() + " в GUI " + guiItem->objectName());
        if(! AnalogSignalVar2Connect(guiItem, pSteam->getDBName(), pSteam) )
            logging(Prom::MessAlarm, QDateTime::currentDateTime(), false, tagPrefix, "не найден " + pSteam->getDBName() + " в GUI " + guiItem->objectName());
        if(! AnalogSignalVar2Connect(guiItem, pSmoke->getDBName(), pSmoke) )
            logging(Prom::MessAlarm, QDateTime::currentDateTime(), false, tagPrefix, "не найден " + pSmoke->getDBName() + " в GUI " + guiItem->objectName());
        if(! AnalogSignalVar2Connect(guiItem, pAir->getDBName(),   pAir) )
            logging(Prom::MessAlarm, QDateTime::currentDateTime(), false, tagPrefix, "не найден " + pAir->getDBName() + " в GUI " + guiItem->objectName());
        if(! AnalogSignalVar2Connect(guiItem, pGas->getDBName(),   pGas) )
            logging(Prom::MessAlarm, QDateTime::currentDateTime(), false, tagPrefix, "не найден " + pGas->getDBName() + " в GUI " + guiItem->objectName());
        if(! AnalogSignalVar1Connect(guiItem, pGasBV->getDBName(), pGasBV) )
            logging(Prom::MessAlarm, QDateTime::currentDateTime(), false, tagPrefix, "не найден " + pGasBV->getDBName() + " в GUI " + guiItem->objectName());

        if( !PIDwinConnect(guiItem, lvlPID->tagPrefix,   lvlPID) )
            logging(Prom::MessAlarm, QDateTime::currentDateTime(), false, tagPrefix, "не найден " + lvlPID->tagPrefix + " в GUI " + guiItem->objectName());
        if( !PIDwinConnect(guiItem, steamPID->tagPrefix, steamPID) )
            logging(Prom::MessAlarm, QDateTime::currentDateTime(), false, tagPrefix, "не найден " + steamPID->tagPrefix + " в GUI " + guiItem->objectName());
        if( !PIDwinConnect(guiItem, smokePID->tagPrefix, smokePID) )
            logging(Prom::MessAlarm, QDateTime::currentDateTime(), false, tagPrefix, "не найден " + smokePID->tagPrefix + " в GUI " + guiItem->objectName());
        if( !PIDwinConnect(guiItem, airPID->tagPrefix,   airPID) )
            logging(Prom::MessAlarm, QDateTime::currentDateTime(), false, tagPrefix, "не найден " + airPID->tagPrefix + " в GUI " + guiItem->objectName());

        QObject * tmpElem;
        tmpElem = guiItem->findChild<QObject*>("tank");
        if(tmpElem == nullptr){
            logging(Prom::MessAlarm, QDateTime::currentDateTime(), false, tagPrefix, "не найден 'tank' в GUI " + guiItem->objectName());
            tmpElem = guiItem;
        }
        if( tmpElem != nullptr ){
            if( !connect( lvlWater, SIGNAL(s_valueChd(QVariant)),        tmpElem, SLOT(setLevel(QVariant)) , Qt::QueuedConnection))
                logging(Prom::MessAlarm, QDateTime::currentDateTime(), false, tagPrefix, "не найден 'lvl' в GUI " + guiItem->objectName());
            connect( lvlWater, SIGNAL(s_maxLevelChanged(QVariant)), tmpElem, SLOT( setAlarmLevelTop(QVariant) ),    Qt::QueuedConnection );
            connect( tmpElem,  SIGNAL(s_alarmTopLevelChanged(QVariant)), lvlWater, SLOT( setMaxLevel(QVariant) ),    Qt::QueuedConnection );
            connect( lvlWater, SIGNAL(s_minLevelChanged(QVariant)), tmpElem, SLOT( setAlarmLevelBottom(QVariant) ), Qt::QueuedConnection );
            connect( tmpElem,  SIGNAL(s_alarmBottomLevelChanged(QVariant)), lvlWater, SLOT( setMinLevel(QVariant) ), Qt::QueuedConnection );
        }
    }
}
//------------------------------------------------------------------------------


