//#include <qdebug.h>
#include "regValveDO.h"
#include "SCADAenums.h"
#include "InETag.h"
#include "OutETag.h"
#include "InDiscretETag.h"
#include "OutDiscretETag.h"

RegValveDO::RegValveDO(int *Id,
    QString Name,
    QString TagPrefix,
    bool SefResetAlarm,
    const regValve::tagsMap *TagsMap )
    :Unit( TypeNoDef,
        Id,
        Name,
        TagPrefix,
        SefResetAlarm,
        Prom::UnMdNoDef )
{
    posSet = new OutETag( this, Prom::TpOut, Prom::PreSet, "уставка позиции",  TagsMap->at(regValve::posSetDBN), false, false, false, true);
    pos = new InETag( this, Prom::TpIn, "позиция", TagsMap->at(regValve::posDBN), true, 100, 0.5, false, false, false, false, true );
    rangeTop = new OutETag( this, Prom::TpOut, Prom::PreSet, "макс. открытие",  TagsMap->at(regValve::rangeTopDBN), false, false, false, true, Prom::VCNo, false, false, 0, true);
    rangeBottom = new OutETag( this, Prom::TpOut, Prom::PreSet, "макс. закрытие",  TagsMap->at(regValve::rangeBottomDBN), false, false, false, true, Prom::VCNo, false, false, 0, true);
    openOut = new OutDiscretETag( this, Prom::PreSet, "руч. приоткрыть", TagsMap->at(regValve::openOutDBN), true, false,false,false );
    closeOut = new OutDiscretETag( this, Prom::PreSet, "руч. призакрыть", TagsMap->at(regValve::closeOutDBN), true, false,false,false );
}

//------------------------------------------------------------------------------
void RegValveDO::_customConnectToGUI(QObject *guiItem, QObject *)
{
    connect( guiItem, SIGNAL(s_openLtl(QVariant) ), openOut  , SLOT( setValue(QVariant) ), Qt::QueuedConnection );
    connect( guiItem, SIGNAL(s_closeLtl(QVariant)), closeOut , SLOT( setValue(QVariant) ), Qt::QueuedConnection );
    connect( guiItem, SIGNAL(s_valvePosChanged(QVariant)), posSet , SLOT( setValue(QVariant) ), Qt::QueuedConnection );
    connect( pos, SIGNAL( s_valueChd(QVariant) ), guiItem, SLOT( setValvePosition(QVariant) ), Qt::QueuedConnection );
}
//------------------------------------------------------------------------------
