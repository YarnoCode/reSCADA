#ifndef BOILER_H
#define BOILER_H

#ifndef UNIT_H
#include "unit.h"
#endif

#include "PID.h"

class OutETag;
class InETag;
class MxMnInETag;
class OutDiscretETag;
class FCUnitOkSrtFq0Fq0;
class SimpElecEgine;
class RegValveDO;
//class PIDstep;
class InDiscretETag;

class Boiler : public Unit
{
    Q_OBJECT
public:
    explicit Boiler(
        int *Id,
        QString Name,
        QString TagPefix,
        QString lvlPIDPefix,
        QString steamPIDPefix,
        QString smokePIDPefix,
        QString airPIDPefix,
        bool SelfAlarmReset,
        const pid::tagsMap *PIDTagsNames = &pid::StdPIDTagsNames);

    InDiscretETag *lvlLowWork;
    InDiscretETag *lvlHiWork;
    OutDiscretETag *vGas_open;
    OutDiscretETag *vGasSml_open;
    OutDiscretETag *vCandle_close;
    InDiscretETag *pumpWaterRes_onOff;
    OutDiscretETag *autoMod;
    InETag *stay;
    OutDiscretETag *startCmd;
    InDiscretETag *reqAlarmBtnPress;
    InDiscretETag *reqUserConf;
    OutDiscretETag *userConfd;
    OutDiscretETag *blowdownCmd;
    InETag *coldStartHating;
    InETag *hot;
    InDiscretETag *alarm;
    OutDiscretETag *reset;
    OutDiscretETag *germTestStart;
    InETag *germTestStage;
    InETag *lastGermTest;
    OutETag *pGasIgnition;
    OutETag *pGasHeating;
    InETag *pGasBV;

    MxMnInETag *lvlWater;//.value;
    MxMnInETag *pGas;//.value;
    MxMnInETag *pAir;//.value;
    MxMnInETag *pSmoke;//.value;
    MxMnInETag *pSteam;//.value;
    MxMnInETag *tSmoke;//.value;
    InDiscretETag *alarmBtn;//.alarm;
    InDiscretETag *lvlLowAlarm;//.alarm;
    InDiscretETag *lvlHiAlarm;//.alarm;
    InDiscretETag *alarmGermVCandle;//.alarm;
    InDiscretETag *alarmGermVBurnersOrCandle;//.alarm;
    InDiscretETag *alarmGermVGas;//.alarm;
    InDiscretETag *alarmGermTestStage;
    InDiscretETag *pumpWater_selectReserv;

    OutETag *blowdownDelay;
    InETag *startStage;
    OutETag *hotDelay;
    OutETag *coldStartHotDelay;
    OutETag *unhotDelay;

    PIDstep *lvlPID;
    PID *steamPID;
    PID *smokePID;
    PID *airPID;

    FCUnitOkSrtFq0Fq0 *waterFC;
    SimpElecEgine *waterPump1;
    SimpElecEgine *waterPump2;
    RegValveDO *vSteam;

public slots:
    bool resetAlarm() override;

protected slots:
    Prom::SetModeResp _customSetMode( Prom::UnitModes */*mode*/, bool /*UserOrSys*/ ) override{return Prom::DoneAlready;};
    void _customConnectToGUI( QObject * /*guiItem*/,  QObject * /*propWin*/ ) override;
    void _updateStateAndMode() override;
    void _doOnModeChange()override{};
};


#endif // BOILER_H
