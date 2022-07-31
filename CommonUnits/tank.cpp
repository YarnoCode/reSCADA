#include "tank.h"
#include "MxMnInETag.h"
#include "OutDiscretETag.h"
#include "FC.h"
#include "GUIconnect.h"

//------------------------------------------------------------------------------
Tank::Tank(int *Id, QString Name, QString TagPefix, bool SelfResetAlarm)
    : Unit( TypeNoDef,
        Id,
        Name,
        TagPefix,
        SelfResetAlarm)
{
    _currentMode = Prom::UnMdCantHaveMode;
    level = new MxMnInETag(this, Prom::TpMxMnIn, "уровень", ".lvl", 100, 0, 2, false, false );
    level->needBeUndetectedAlarm();
    level->findMaxMinTags();
}

//------------------------------------------------------------------------------
void Tank::_customConnectToGUI(QObject *guiItem, QObject *)
{
    QObject * tmpElem;
    tmpElem = guiItem->findChild<QObject*>("tank");
    if(tmpElem == nullptr)
        tmpElem = guiItem;
    if( tmpElem != nullptr ){
        connect( level, SIGNAL(s_valueChd(QVariant)),  tmpElem, SLOT(setLevel(QVariant)) , Qt::QueuedConnection);
        QObject::connect( level, SIGNAL(s_maxLevelChanged(QVariant)), tmpElem, SLOT( setAlarmLevelTop(QVariant) ), Qt::QueuedConnection );
        QObject::connect( tmpElem, SIGNAL(s_alarmTopLevelChanged(QVariant)), level, SLOT( setMaxLevel(QVariant) ), Qt::QueuedConnection );
        QObject::connect( level, SIGNAL(s_minLevelChanged(QVariant)), tmpElem, SLOT( setAlarmLevelBottom(QVariant) ), Qt::QueuedConnection );
        QObject::connect( tmpElem, SIGNAL(s_alarmBottomLevelChanged(QVariant)), level, SLOT( setMinLevel(QVariant) ), Qt::QueuedConnection );
    }
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//template<class T>
TankPIDFC::TankPIDFC(int *Id,
    QString Name,
    QString TagPefix,
    QString PIDPrefix,
    bool SelfResetAlarm,
    pid::tagsMap PIDTagsNames)

    : Tank(Id,
        Name,
        TagPefix,
        SelfResetAlarm)
{
    freqPID = new PID(this, "ПИД рег-р уровня", "воздействие", PIDPrefix,&PIDTagsNames, PIDopt::allOn );
    //freqPID->process = level;
}
//------------------------------------------------------------------------------
//template<>
//TankPIDFC<PIDstep>::TankPIDFC(int *Id,
//    QString Name,
//    QString TagPefix,
//    QString PIDPrefix,
//    std::map< pidTags, QString> PIDTagsNames)

//    : Tank(Id,
//        Name,
//        TagPefix)
//{
//    freqPID = new PIDstep(this, "ПИД рег-р уровня", PIDPrefix, PIDopt::allOn, PIDTagsNames );
//}
//------------------------------------------------------------------------------
//template<class T>
void TankPIDFC::_customConnectToGUI(QObject *guiItem, QObject *propWin)
{
    Tank::_customConnectToGUI(guiItem, propWin);
    PIDwinConnect(guiItem, "PID", freqPID);
}


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
TankAL::TankAL(int *Id,
    QString Name,
    QString TagPefix, bool SelfResetAlarm)
    : Tank(Id,
        Name,
        TagPefix,
        SelfResetAlarm)
{
    autoLvl1 = new OutDiscretETag( this, Prom::PreSet, "вкл. автоуровень на насосе №1", ".autoLvl1" );
    autoLvl2 = new OutDiscretETag( this, Prom::PreSet, "вкл. автоуровень на насосе №2", ".autoLvl2" );
    autoMaxLvl = new OutETag( this, Prom::TpOut, Prom::PreSet, "авто уровень макс.",  ".autoMaxLvl");
    autoMinLvl = new OutETag( this, Prom::TpOut, Prom::PreSet, "авто уровень мин.",   ".autoMinLvl");
}
//------------------------------------------------------------------------------
void TankAL::_customConnectToGUI(QObject *guiItem, QObject *)
{
    Tank::_customConnectToGUI(guiItem, nullptr);
    connect( autoLvl1, SIGNAL( s_valueChd(QVariant) ), guiItem, SLOT( setAutoLevel1(QVariant) ), Qt::QueuedConnection );
    connect( guiItem , SIGNAL( s_autoLevelChanged1(QVariant) ), autoLvl1, SLOT( setValue(QVariant) ), Qt::QueuedConnection );
    connect( autoLvl2, SIGNAL( s_valueChd(QVariant) ), guiItem, SLOT( setAutoLevel2(QVariant) ), Qt::QueuedConnection );
    connect( guiItem , SIGNAL( s_autoLevelChanged2(QVariant) ), autoLvl2, SLOT( setValue(QVariant) ), Qt::QueuedConnection );

    connect( autoMaxLvl, SIGNAL( s_valueChd(QVariant) ),       guiItem,    SLOT( setAutoLevelMax( QVariant )), Qt::QueuedConnection );
    connect( guiItem,    SIGNAL( s_autoMaxChanged(QVariant) ), autoMaxLvl, SLOT( setValue(QVariant) ), Qt::QueuedConnection );
    connect( autoMinLvl, SIGNAL( s_valueChd(QVariant) ),       guiItem,    SLOT( setAutoLevelMin( QVariant )), Qt::QueuedConnection );
    connect( guiItem,    SIGNAL( s_autoMinChanged(QVariant) ), autoMinLvl, SLOT( setValue(QVariant) ), Qt::QueuedConnection );
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

