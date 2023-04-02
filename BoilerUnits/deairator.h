#ifndef DEAIRATOR_H
#define DEAIRATOR_H

//#ifndef UNIT_H
//#include "unit.h"
//#endif
//#include "SCADAenums.h"
#include "PID.h"
#include "tank.h"

class OutETag;
class MxMnInETag;
class OutDiscretETag;
class FCUnitSFREFF;
class SimpElecEngine;
class RegValveDOMMS;
//class PIDstep;
class InDiscretETag;

class Deairator : public Tank
{
    Q_OBJECT
public:
    explicit Deairator(int *Id,
        QString Name,
        QString TagPrefix,
        QString lvlPIDPefix,
        QString steamPIDPefix,
        bool SelfAlarmReset = false,
        const pid::tagsMap *PIDTagsNames = &pid::StdPIDTagsNames);

    MxMnInETag *tWater;
    MxMnInETag *pSteam;

    InDiscretETag * alarm;
    OutDiscretETag * reset;

    PID *lvlPID;
    PID *steamPID;
    FCUnitSFREFF *waterFC;
    SimpElecEngine *waterPump1;
    SimpElecEngine *waterPump2;
    RegValveDOMMS *vrSteam;
public slots:
    bool resetAlarm() override;

protected slots:
    Prom::SetModeResp _customSetMode( Prom::UnitModes */*mode*/, bool /*UserOrSys*/ ) override{return Prom::DoneAlready;};
    void _customConnectToGUI( QObject * /*guiItem*/,  QObject * /*propWin*/ ) override;
    void _updateStateAndMode() override{};
    void _doOnModeChange()override{};
};


#endif // DEAIRATOR_H
