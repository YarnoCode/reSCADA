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
        QString TagPefix,
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
class FCUnitOkSrtFq0Fq0 : public Unit
{
    Q_OBJECT
public:
    explicit FCUnitOkSrtFq0Fq0(int *Id,
        QString Name,
        QString TagPefix,
        bool SelfResetAlarm = false);

    InDiscretETag  *ok      {nullptr};
    OutDiscretETag *reset   {nullptr};
    InDiscretETag  *start   {nullptr};
    InETag         *freqPID {nullptr};
    OutETag        *freqMan {nullptr};

    void setFreqPID(InETag *newFreqPID);
    void setFreqMan(OutETag *newFreqMan);

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
    void _customConnectToGUI(QObject *guiItem, QObject *) override;
};
#endif // FC_H

//------------------------------------------------------------------------------
