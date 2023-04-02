#ifndef BURNER_H
#define BURNER_H

#ifndef UNIT_H
#include "unit.h"
#endif
//#include "SCADAenums.h"
#include "PID.h"

class OutETag;
class MxMnInETag;
class OutDiscretETag;
class FCUnitSFREFF;
class SimpElecEgine;
class ActWorkSt;
class RegValveDO;
class RegValveDOMMS;
class InDiscretETag;
class ActWorkStWk;

class Burner : public Unit
{
    Q_OBJECT
public:
    explicit Burner(int *Id,
        QString Name,
        QString TagPrefix,
        QString pGasPIDPrefix,
        bool SelfResetAlarm,
        const pid::tagsMap *PIDTagsNames = &pid::StdPIDTagsNames);

    InETag *pGas;

    InDiscretETag * alarm;
    InDiscretETag * alarmIgnition;
    InDiscretETag * alarmFlame;
    OutDiscretETag * reset;
    InETag * state;
    OutDiscretETag * disabled;
    InDiscretETag * flameS;
    InDiscretETag * ignitionS;
    OutETag *ignitionAlarmDelay;
    OutETag *ignitionStableDelay;
    OutETag *flameStartDelay;
    OutETag *flameStableDelay;

    PIDstep *gasPID;

    ActWorkSt *ignition;
    ActWorkSt *vIgnition;
    ActWorkSt *vGas;
    RegValveDO *vrGas;
    //RegValveDOMMS *vrAir;

public slots:
    bool resetAlarm() override;

protected slots:
    Prom::SetModeResp _customSetMode( Prom::UnitModes */*mode*/, bool /*UserOrSys*/ ) override{return Prom::DoneAlready;};
    void _customConnectToGUI( QObject * /*guiItem*/,  QObject * /*propWin*/ ) override;
    void _updateStateAndMode() override{};
    void _doOnModeChange()override{};
};


#endif // BURNER_H
