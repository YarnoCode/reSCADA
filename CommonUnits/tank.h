#ifndef TANK_H
#define TANK_H

#ifndef UNIT_H
#include "unit.h"
#endif
#include "PID.h"
//#include "PID.h"

class OutETag;
class MxMnInETag;
class OutDiscretETag;
class FCUnitRstFwdFqFq;
class PID;

class Tank : public Unit
{
    Q_OBJECT
public:
    explicit Tank( int *Id, QString Name, QString TagPefix, bool SelfResetAlarm = false );
    //~expenSpan();
    MxMnInETag * level { nullptr };

protected slots:
    Prom::SetModeResp _customSetMode( Prom::UnitModes */*mode*/, bool /*UserOrSys*/ ) override{return Prom::DoneAlready;};
    void _customConnectToGUI(QObject * /*guiItem*/,  QObject * = nullptr/*propWin*/) override;
    void _updateStateAndMode() override{};
    void _doOnModeChange()override{};
};

//------------------------------------------------------------------------------
class TankPIDFC : public Tank
{
    Q_OBJECT
public:
    explicit TankPIDFC(int *Id, QString Name, QString TagPefix, QString PIDPrefix, bool SelfResetAlarm = false,
        pid::tagsMap PIDTagsNames = pid::StdPIDTagsNames/*набор значений имен тегов ПИД регулятора*/);

    PID * freqPID;

protected slots:
    void _customConnectToGUI( QObject * /*guiItem*/,  QObject * /*propWin*/ ) override;

};

//------------------------------------------------------------------------------
class TankAL : public Tank
{
    Q_OBJECT
public:
    explicit TankAL( int *Id, QString Name, QString TagPefix, bool SelfResetAlarm = false );
    //~expenSpan();
    OutDiscretETag *autoLvl1 {nullptr};
    OutDiscretETag *autoLvl2 {nullptr};
    OutETag *autoMaxLvl {nullptr};
    OutETag *autoMinLvl {nullptr};
protected slots:
    void _customConnectToGUI( QObject * /*guiItem*/,  QObject * /*propWin*/ ) override;

};
//------------------------------------------------------------------------------



#endif // TANK_H
