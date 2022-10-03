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
class SimpElecEngine;
class RegValveDO;
class ActWorkSt;
class InDiscretETag;
class Burner;

class Boiler : public Unit
{
    Q_OBJECT
public:
    explicit Boiler(int *Id,
        QString Name,
        QString TagPrefix,
        QString lvlPIDPefix,
        QString steamPIDPefix,
        QString smokePIDPefix,
        QString airPIDPefix,
        bool SelfAlarmReset,
        const pid::tagsMap *PIDTagsNames = &pid::StdPIDTagsNames);

    enum states{
        st_stop         =0,
        st_start        =1,
        st_work         =2,
        st_ignition     =3,
        st_heating      =4,
        st_cooling      =5,
        st_blowdown     =6,
        st_startHeating =7,
        st_alarmStop    =8
    };
    Q_ENUM(states)

    InDiscretETag *lvlLowWork;
    InDiscretETag *lvlHiWork;
    InDiscretETag *pumpWaterRes_onOff;
    OutDiscretETag *autoMod;
    InETag *state;
    OutDiscretETag *startCmd;
    OutDiscretETag *stopCmd;
    OutDiscretETag *alarmStopCmd;
    InDiscretETag *reqAlarmBtnPress;
    InDiscretETag *reqUserConf;
    OutDiscretETag *userConfd;
    OutDiscretETag *blowdownCmd;
    InETag *blowdownET;
    OutETag *blowdownFCArFreq;
    OutETag *blowdownPSmoke;//
    InETag *startHeatingET;
    InETag *heatingET;
    InETag *coolingET;
    InDiscretETag *alarm;
    OutDiscretETag *reset;
    OutDiscretETag *germTestStart;
    InETag *germTestStage;
    InETag *lastGermTest;
    OutETag *pAirIgnition;
    OutETag *pSmokeIgnition;
    OutETag *pGasStart;
    OutETag *pGasHeating;


    MxMnInETag *lvlWater;//.value;
    MxMnInETag *pGas;//.value;
    MxMnInETag *pAir;//.value;
    MxMnInETag *pSmoke;//.value;
    MxMnInETag *pSteam;//.value;
    MxMnInETag *tSmoke;//.value;
    InETag *pGasBV;

    InDiscretETag *alarmBtn;//.alarm;
    InDiscretETag *lvlLowAlarm;//.alarm;
    InDiscretETag *lvlHiAlarm;//.alarm;
    InDiscretETag *alarmGermVCandle;//.alarm;
    InDiscretETag *alarmGermVBurnersOrCandle;//.alarm;
    InDiscretETag *alarmGermVGas;//.alarm;
    InDiscretETag *alarmGermTestStage;
    InDiscretETag *pGasBV_alarm;//.alarm;

    // *pumpWater_selectReserv;

    OutETag *blowdownDelay;
    InETag  *startStage;
    OutETag *heatingDelay;
    OutETag *startHeatingDelay;
    OutETag *coolingDelay;

    PIDstep *lvlPID;
    PID *steamPID;
    PID *smokePID;
    PID *airPID;

    FCUnitOkSrtFq0Fq0 *waterFC;
    FCUnitOkSrtFq0Fq0 *smokeFC;
    FCUnitOkSrtFq0Fq0 *airFC;

    SimpElecEngine *waterPump;
    SimpElecEngine *waterPumpReserv;
    SimpElecEngine *ventSmoke;
    SimpElecEngine *ventAir;

    ActWorkSt *vGas;
    ActWorkSt *vGasSml;
    ActWorkSt *vCandle;

    Burner *burner1;
    Burner *burner2;

signals:
//    void s_state(QVariant);
//    void s_startStage(QVariant);
//    void s_startHeating(QVariant);
//    void s_heating(QVariant);
//    void s_ventilating(QVariant);

public slots:
    bool resetAlarm() override;
//    void start()     { setMode(Prom::UnMdAutoStart, true); };
//    void stop()      { setMode(Prom::UnMdStop,      true); };
//    void alarmStop() { setMode(Prom::UnMdFreeze,    true); };
//    void blowdown()  { setMode(Prom::UnMdBlowdown,  true); };
//    void germTest()  { setMode(Prom::UnMdGermTest, true); };

protected slots:
    Prom::SetModeResp _customSetMode( Prom::UnitModes */*mode*/, bool /*UserOrSys*/ ) override{return Prom::RejAnnown;};
    void _customConnectToGUI( QObject * /*guiItem*/,  QObject * /*propWin*/ ) override;
    void _updateStateAndMode() override;
    void _doOnModeChange()override{};
};


#endif // BOILER_H
