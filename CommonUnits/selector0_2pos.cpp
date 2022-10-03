//#include <qdebug.h>
#include "selector0_2pos.h"
//#include "SCADAenums.h"
//#include "MxMnInETag.h"
//#include "InETag.h"
#include "OutETag.h"
//#include "InDiscretETag.h"
//#include "OutDiscretETag.h"

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
Selector0_2pos::Selector0_2pos(
    int *Id,
    QString Name,
    QString TagPrefix,
    QString posSigName,
    QString posSigDBName,
    bool SelfAlarmReset,
    Prom::UnitModes SaveMode)
    : Unit( TypeNoDef,
        Id,
        Name,
        TagPrefix,
        SelfAlarmReset,
        SaveMode)
{
    pos = new OutETag(this, Prom::PreSet,  posSigName, false, posSigDBName );
    connect( pos, &OutETag::s_valueChd, this, &Unit::updateState );
}

//------------------------------------------------------------------------------
void Selector0_2pos::_updateStateAndMode()
{

}
//------------------------------------------------------------------------------
void Selector0_2pos::_customConnectToGUI(QObject *guiItem, QObject *)
{
    connect( pos, SIGNAL(s_valueChd(QVariant)), guiItem, SLOT( setPos(QVariant) ), Qt::QueuedConnection );
    connect( guiItem, SIGNAL(s_posChd(QVariant)), pos, SLOT( setValue(QVariant) ), Qt::QueuedConnection );
}
//------------------------------------------------------------------------------

