#ifndef FC_H
#define FC_H

#ifndef UNIT_H
#include "unit.h"
#endif

class OutETag;
class MxMnInETag;
class InETag;
class OutETag;
class InDiscretETag;
class OutDiscretETag;

class FCUnitRstFwdFqFq : public Unit
{
    Q_OBJECT
public:
    explicit FCUnitRstFwdFqFq(int *Id,
        QString Name,
        QString TagPrefix,
        bool SelfResetAlarm = false);

    OutDiscretETag *reset   {nullptr};
    InDiscretETag  *fwd     {nullptr};
    InETag         *freqPID {nullptr};
    OutETag        *freqMan {nullptr};

signals:
    void s_started();
    void s_stoped();
    void s_noDef();

public slots:
    bool resetAlarm() override;
    /*!для визуализации*/
    void _updateStateAndMode() override;
    // Unit interface
protected:
    Prom::SetModeResp _customSetMode(Prom::UnitModes */*mode*/, bool /*UserOrSys*/)override{return Prom::DoneAlready;};
    void _doOnModeChange()override{};


protected slots:
    void _customConnectToGUI(QObject *guiItem,  QObject *propWin) override;
};

//------------------------------------------------------------------------------
class FCUnitSFREFF : public Unit
{
    Q_OBJECT
public:
    explicit FCUnitSFREFF(int *Id,
        QString Name,
        QString TagPrefix,
        bool SelfResetAlarm = false);

    OutDiscretETag *start   {nullptr};
    InDiscretETag  *fwd     {nullptr};
    InDiscretETag  *fwdAlarm   {nullptr};
    OutDiscretETag *reset   {nullptr};
    InDiscretETag  *error   {nullptr};
    InDiscretETag  *errorAlarm   {nullptr};
    InDiscretETag  *alarm   {nullptr};
    InETag         *freqPID {nullptr};
    OutETag        *freqMan {nullptr};
    InETag         *freq {nullptr};

    void setFreqPID(InETag *newFreqPID);
    void setFreqMan(OutETag *newFreqMan);

signals:
    void s_startComand();      //для визуализации
    void s_started();         //для визуализации
    void s_stopComand();     //для визуализации
    void s_stoped();        //для визуализации
    void s_manualStarted();//для визуализации
    void s_noDef();

public slots:
    bool resetAlarm() override;
    /*!для визуализации*/
    void _updateStateAndMode() override;
    // Unit interface
protected:
    Prom::SetModeResp _customSetMode(Prom::UnitModes */*mode*/, bool /*UserOrSys*/)override{return Prom::DoneAlready;};
    void _doOnModeChange()override{};


protected slots:
    void _customConnectToGUI(QObject *guiItem, QObject *) override;
};
#endif // FC_H

//------------------------------------------------------------------------------
