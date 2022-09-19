#ifndef SIMPELECENGINE_H
#define SIMPELECENGINE_H

#ifndef UNIT_H
#include "unit.h"
#endif

class OutETag;
class MxMnInETag;
class InETag;
class OutETag;
class InDiscretETag;
class OutDiscretETag;

class SimpElecEngine : public Unit
{
    Q_OBJECT
public:
    explicit SimpElecEngine(Prom::UnitType Type,
        int *Id,
        QString Name,
        QString TagPrefix,
        bool SelfResetAlarm = false);

protected:
    InDiscretETag  *_alarm {nullptr};
    InDiscretETag  *_alarmKM {nullptr};
    InDiscretETag  *_alarmQF {nullptr};
    OutDiscretETag *_reset   {nullptr};

    OutDiscretETag *_start   {nullptr};
    InDiscretETag  *_started {nullptr};
    InDiscretETag  *_QF {nullptr};
    InDiscretETag  *_KM {nullptr};

    Prom::SetModeResp _customSetMode(Prom::UnitModes */*mode*/, bool /*UserOrSys*/)override;
    void _doOnModeChange()override{};

signals:
    void s_startComand();      //для визуализации
    void s_started();         //для визуализации
    void s_stopComand();     //для визуализации
    void s_stoped();        //для визуализации
    void s_cleaning();
    void s_manualStarted();//для визуализации
    void s_noDef();       //для визуализации

public slots:
    bool resetAlarm() override;
    void _updateStateAndMode() override;
    // Unit interface
    bool start();
    bool stop();

protected slots:
    void _customConnectToGUI(QObject *guiItem,  QObject *propWin) override;
};

//------------------------------------------------------------------------------
#endif//SIMPELECENGINE_H
