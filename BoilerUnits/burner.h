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
class FCUnitOkSrtFq0Fq0;
class SimpElecEgine;
class RegValveDO;
//class PIDstep;
class InDiscretETag;

class Deairator : public Tank
{
    Q_OBJECT
public:
    explicit Deairator(
        int *Id,
        QString Name,
        QString TagPefix,
        QString lvlPIDPefix,
        QString steamPIDPefix,
        const pid::tagsMap *PIDTagsNames = &pid::StdPIDTagsNames);

    MxMnInETag *tWater;
    MxMnInETag *pSteam;

    InDiscretETag * alarm;
    OutDiscretETag * reset;

    PIDstep *lvlPID;
    PIDstep *steamPID;
    FCUnitOkSrtFq0Fq0 *waterFC;
    SimpElecEgine *waterPump1;
    SimpElecEgine *waterPump2;
    RegValveDO *vSteam;
public slots:
    bool resetAlarm() override;

protected slots:
    Prom::SetModeResp _customSetMode( Prom::UnitModes */*mode*/, bool /*UserOrSys*/ ) override{return Prom::DoneAlready;};
    void _customConnectToGUI( QObject * /*guiItem*/,  QObject * /*propWin*/ ) override;
    void _updateStateAndMode() override{};
    void _doOnModeChange()override{};
};


#endif // DEAIRATOR_H
