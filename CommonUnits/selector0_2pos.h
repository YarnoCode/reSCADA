#ifndef SELECTOR0_2POS_H
#define WORKUNIT_H

#ifndef UNIT_H
#include "unit.h"
#endif

//class MxMnInETag;
//class InETag;
class OutETag;
//class InDiscretETag;
//class OutDiscretETag;

//------------------------------------------------------------------------------
class Selector0_2pos : public Unit
{
    Q_OBJECT
public:
    explicit Selector0_2pos(int *Id,
        QString Name,
        QString TagPrefix,
        QString posSigName = "позиция",
        QString posSigDBName = ".pos",
        bool SelfAlarmReset = false,
        Prom::UnitModes SaveMode = Prom::UnMdStop);

    OutETag *pos {nullptr};

signals:
 void toFirst();
 void toSecond();
 void toNoOne();

protected:
    Prom::SetModeResp _customSetMode(Prom::UnitModes */*mode*/, bool /*UserOrSys*/)override{return Prom::RejAnnown;};
    void _doOnModeChange()override{};
protected slots:
    void _customConnectToGUI(QObject *guiItem, QObject *) override;

    // Unit interface
protected slots:
    void _updateStateAndMode()override;
};

//------------------------------------------------------------------------------
#endif//SELECTOR02POS_H
