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
    pos = new InETag( this, "позиция", TagsMap->at(regValve::posDBN), true, 100, 0.5, false, false, false, false, true );
    open  = new InDiscretETag( this, "открытие", TagsMap->at(regValve::openDBN),  true, false, true, false );
    close = new InDiscretETag( this, "закрытие", TagsMap->at(regValve::closeDBN), true, false, true, false );
}

//------------------------------------------------------------------------------
void RegValveDO::_customConnectToGUI(QObject *guiItem, QObject *)
{
    connect( pos, SIGNAL( s_valueChd(QVariant) ), guiItem, SLOT( setPos(QVariant) ), Qt::QueuedConnection );
    connect( open, SIGNAL( s_valueChd(QVariant) ), guiItem, SLOT( setOpenLtl(QVariant) ), Qt::QueuedConnection );
//    connect( guiItem, SIGNAL(s_openLtl(QVariant)), open , SLOT( setValue(QVariant) ), Qt::QueuedConnection );
    connect( close, SIGNAL( s_valueChd(QVariant) ), guiItem, SLOT( setCloseLtl(QVariant) ), Qt::QueuedConnection );
//    connect( guiItem, SIGNAL(s_closeLtl(QVariant)), close , SLOT( setValue(QVariant) ), Qt::QueuedConnection );
}

//------------------------------------------------------------------------------
RegValveDOMMS::RegValveDOMMS(int *Id,
    QString Name,
    QString TagPrefix,
    bool SefResetAlarm,
    const regValve::tagsMap *TagsMap )
    :RegValveDO( Id,
                 Name,
                 TagPrefix,
                 SefResetAlarm,
                 TagsMap )
{
    posSet      = new OutETag( this, Prom::PreSet, "уставка позиции", TagsMap->at(regValve::posSetDBN),      false, false, false, true, Prom::VCNo, false, false, 0, true);
    rangeMax    = new OutETag( this, Prom::PreSet, "макс. открытие",  TagsMap->at(regValve::rangeMaxDBN),    false, false, false, true, Prom::VCNo, false, false, 0, true);
    rangeMin = new OutETag( this, Prom::PreSet, "макс. закрытие",  TagsMap->at(regValve::rangeMinDBN), false, false, false, true, Prom::VCNo, false, false, 0, true);
}
//------------------------------------------------------------------------------
void RegValveDOMMS::_customConnectToGUI(QObject *guiItem, QObject *)
{
    RegValveDO::_customConnectToGUI(guiItem, nullptr);
    connect( guiItem, SIGNAL(s_setMaxRange(QVariant)), rangeMax , SLOT( setValue(QVariant) ), Qt::QueuedConnection );
    connect( rangeMax,  SIGNAL( s_valueChd(QVariant) ), guiItem, SLOT( setMaxRange(QVariant) ), Qt::QueuedConnection );
    connect( guiItem, SIGNAL(s_setMinRange(QVariant)), rangeMin , SLOT( setValue(QVariant) ), Qt::QueuedConnection );
    connect( rangeMin,  SIGNAL( s_valueChd(QVariant) ), guiItem, SLOT( setMinRange(QVariant) ), Qt::QueuedConnection );
    connect( guiItem, SIGNAL(s_setTargetPos(QVariant)), posSet , SLOT( setValue(QVariant) ), Qt::QueuedConnection );
    connect( posSet, SIGNAL( s_valueChd(QVariant) ), guiItem, SLOT( setTargetPos(QVariant) ), Qt::QueuedConnection );
}
//------------------------------------------------------------------------------
