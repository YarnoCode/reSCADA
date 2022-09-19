#ifndef WORKUNIT_H
#define WORKUNIT_H

#ifndef UNIT_H
#include "unit.h"
#endif

class OutETag;
class MxMnInETag;
class InETag;
class OutETag;
class InDiscretETag;
class OutDiscretETag;

//------------------------------------------------------------------------------
class ActWorkSt : public Unit
{
    Q_OBJECT
public:
    explicit ActWorkSt(int *Id,
        QString Name,
        QString TagPrefix,
        bool ReverseStartSig = false,
        QString startSigName = "старт",
        QString startSigDBName = ".start",
        bool SelfAlarmReset = false,
        Prom::UnitModes SaveMode = Prom::UnMdStop);

    OutDiscretETag *start = nullptr;

public slots:
    void on();
    void off();
    /*!для визуализации*/
    void _updateStateAndMode() override;
    // Unit interface
protected:
    Prom::SetModeResp _customSetMode(Prom::UnitModes *mode, bool /*UserOrSys*/)override;
    void _doOnModeChange()override{};


protected slots:
    void _customConnectToGUI(QObject *guiItem, QObject *) override;
};

//------------------------------------------------------------------------------
class PsvWork : public Unit
{
    Q_OBJECT
public:
    explicit PsvWork(int *Id,
        QString Name,
        QString TagPrefix,
        bool SelfAlarmReset = false,
        Prom::UnitModes SaveMode = Prom::UnMdStop);

    InDiscretETag *work = nullptr;

public slots:
    /*!для визуализации*/
    void _updateStateAndMode() override;
    // Unit interface
protected:
    Prom::SetModeResp _customSetMode(Prom::UnitModes */*mode*/, bool /*UserOrSys*/)override{return Prom::DoneWhait;};
    void _doOnModeChange()override{};


protected slots:
    void _customConnectToGUI(QObject *guiItem,  QObject *propWin) override;
};

//------------------------------------------------------------------------------
class ActWorkStWk : public Unit
{
    Q_OBJECT
public:
    explicit ActWorkStWk(int *Id,
        QString Name,
        QString TagPrefix,
        bool ReverseWorkSig = false,
        QString workSigName = "работа",
        QString workSigDBName = ".work",
        bool ReverseStartSig = false,
        QString startSigName = "старт",
        QString startSigDBName = ".start",
        bool SelfAlarmReset = false,
        Prom::UnitModes SaveMode = Prom::UnMdStop);

    InDiscretETag  *work = nullptr;
    OutDiscretETag *start = nullptr;

public slots:

    // Unit interface
    void on();
    void off();
    void _updateStateAndMode() override;
protected:
    Prom::SetModeResp _customSetMode(Prom::UnitModes *mode, bool UserOrSys)override;
    void _doOnModeChange()override{};

protected slots:
    void _customConnectToGUI(QObject *guiItem,  QObject *propWin) override;
};

//------------------------------------------------------------------------------
class ActWorkOnOff : public ActWorkStWk
{
    Q_OBJECT
public:
    explicit ActWorkOnOff(int *Id,
        QString Name,
        QString TagPrefix,
        bool ReverseWorkSig = false,
        QString workSigName = "работа",
        QString workSigDBName = ".work",
        bool ReverseStartSig = false,
        QString startSigName = "старт",
        QString startSigDBName = ".start",
        bool SelfAlarmReset = false,
        Prom::UnitModes SaveMode = Prom::UnMdStop );

    OutDiscretETag *on_off = nullptr;

protected slots:
    void _customConnectToGUI(QObject *guiItem,  QObject *propWin) override;
};

//------------------------------------------------------------------------------
#endif//WORKUNIT_H
