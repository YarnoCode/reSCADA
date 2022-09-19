//#include <qdebug.h>
#include "GUIconnect.h"
#include "SCADAenums.h"
#include "ETag.h"
#include "InETag.h"
#include "MxMnInETag.h"
#include "OutETag.h"
#include "InDiscretETag.h"
#include "OutDiscretETag.h"
#include "PID.h"
//#include "promobject.h"
//#include "QTimerExt.h"

//------------------------------------------------------------------------------

bool AnalogSignalVar1Connect(QObject *rootItem, QString ElementName, ETag *Tag)
{
    QObject * tmpElem;
    if( ElementName != "")tmpElem = rootItem->findChild<QObject*>(ElementName);
    else tmpElem = rootItem;
    if( tmpElem != nullptr ){
        QMetaObject::invokeMethod(tmpElem, "setLinked", Qt::DirectConnection);
        QMetaObject::invokeMethod(tmpElem, "setConnected", Qt::DirectConnection);
        QMetaObject::invokeMethod(tmpElem, "setName", Qt::DirectConnection,
            Q_ARG(QVariant, Tag->getName()));
        QObject::connect( Tag, SIGNAL( s_valueChd(QVariant) ), tmpElem, SLOT( setValue(QVariant) ), Qt::QueuedConnection );
        QObject::connect( Tag, SIGNAL( s_alarm(QVariant) ), tmpElem, SLOT( setAlarmComb(QVariant) ), Qt::QueuedConnection );
        QObject::connect( Tag, SIGNAL( s_alarmReseted() ), tmpElem, SLOT( alarmReseted() ), Qt::QueuedConnection );
        return true;
    }
    return false;
}

//------------------------------------------------------------------------------
bool AnalogSignalVar2Connect(QObject *rootItem, QString ElementName, ETag *Tag)
{
    QObject * tmpElem;
    if( ElementName != ""){
        tmpElem = rootItem->findChild<QObject*>(ElementName);
    }
    else tmpElem = rootItem;
    if( tmpElem != nullptr ){
        AnalogSignalVar1Connect(rootItem, ElementName, Tag);
        if( Tag->ttype == Prom::TpIn ){
            try {
                if(static_cast<InETag*>(Tag)->highOrLow()){
                    QObject::connect( Tag, SIGNAL(s_delectLevelChanged(QVariant)), tmpElem, SLOT( setMaxLimit(QVariant) ), Qt::QueuedConnection );
                    QObject::connect( tmpElem, SIGNAL(s_maxLimitChanged(QVariant)), Tag, SLOT( setDetectLevel(QVariant) ), Qt::QueuedConnection );
                }
                else{
                    QObject::connect( Tag, SIGNAL(s_delectLevelChanged(QVariant)), tmpElem, SLOT( setMinLimit(QVariant) ), Qt::QueuedConnection );
                    QObject::connect( tmpElem, SIGNAL(s_minLimitChanged(QVariant)), Tag, SLOT( setDetectLevel(QVariant) ), Qt::QueuedConnection );
                }
            }  catch (...) {//Если тег не InETag и метода highOrLow() у него нет, то будет ошибка и тут она отлавливается
                QObject::connect( Tag, SIGNAL(s_delectLevelChanged(QVariant)), tmpElem, SLOT( setMaxLimit(QVariant) ), Qt::QueuedConnection );
                QObject::connect( tmpElem, SIGNAL(s_maxLimitChanged(QVariant)), Tag, SLOT( setDetectLevel(QVariant) ), Qt::QueuedConnection );
            }

        }
        else if(Tag->ttype == Prom::TpMxMnIn ){
            QObject::connect( Tag, SIGNAL(s_maxLevelChanged(QVariant)), tmpElem, SLOT( setMaxLimit(QVariant) ), Qt::QueuedConnection );
            QObject::connect( tmpElem, SIGNAL(s_maxLimitChanged(QVariant)), Tag, SLOT( setMaxLevel(QVariant) ), Qt::QueuedConnection );
            QObject::connect( Tag, SIGNAL(s_minLevelChanged(QVariant)), tmpElem, SLOT( setMinLimit(QVariant) ), Qt::QueuedConnection );
            QObject::connect( tmpElem, SIGNAL(s_minLimitChanged(QVariant)), Tag, SLOT( setMinLevel(QVariant) ), Qt::QueuedConnection );
        }
        return true;
    }
    return false;
}

//------------------------------------------------------------------------------
bool PIDwinConnect(QObject *rootItem, QString ElementName, PID * PID)
{
    QObject * tmpElem;
    if( ElementName != "")
        tmpElem = rootItem->findChild<QObject*>(ElementName);
    else
        tmpElem = rootItem;
    if( tmpElem != nullptr ){

        QObject::connect( tmpElem, SIGNAL(s_manOn(QVariant)), PID->manOn , SLOT( setValue(QVariant) ), Qt::QueuedConnection );
        QObject::connect( PID->manOn, SIGNAL( s_valueChd(QVariant) ), tmpElem, SLOT( setManOn(QVariant) ), Qt::QueuedConnection );

        QObject::connect( PID->process, SIGNAL( s_valueChd(QVariant) ), tmpElem, SLOT( setProcess(QVariant) ), Qt::QueuedConnection );

        QObject::connect( tmpElem, SIGNAL(s_setPtChanged(QVariant)), PID->setPt , SLOT( setValue(QVariant) ), Qt::QueuedConnection );
        QObject::connect( PID->setPt, SIGNAL( s_valueChd(QVariant) ), tmpElem, SLOT( setSetPt(QVariant) ), Qt::QueuedConnection );
        QObject::connect( tmpElem, SIGNAL(s_setPtMaxChanged(QVariant)), PID->setPtMax , SLOT( setValue(QVariant) ), Qt::QueuedConnection );
        QObject::connect( PID->setPtMax, SIGNAL( s_valueChd(QVariant) ), tmpElem, SLOT( setSetPtMax(QVariant) ), Qt::QueuedConnection );
        QObject::connect( tmpElem, SIGNAL(s_setPtMinChanged(QVariant)), PID->setPtMin , SLOT( setValue(QVariant) ), Qt::QueuedConnection );
        QObject::connect( PID->setPtMin, SIGNAL( s_valueChd(QVariant) ), tmpElem, SLOT( setSetPtMin(QVariant) ), Qt::QueuedConnection );

        if(PID->impIn){
            QObject::connect(PID->impIn, SIGNAL( s_valueChd(QVariant) ), tmpElem, SLOT( setImpact(QVariant) ), Qt::QueuedConnection );
        }
        if(PID->kPimp)
            QObject::connect(PID->kPimp, SIGNAL( s_valueChd(QVariant) ), tmpElem, SLOT( setKpOut(QVariant) ), Qt::QueuedConnection );
        if(PID->kIimp)
            QObject::connect(PID->kIimp, SIGNAL( s_valueChd(QVariant) ), tmpElem, SLOT( setKiOut(QVariant) ), Qt::QueuedConnection );
        if(PID->kDimp)
            QObject::connect(PID->kDimp, SIGNAL( s_valueChd(QVariant) ), tmpElem, SLOT( setKdOut(QVariant) ), Qt::QueuedConnection );
        if(PID->kP){
            QObject::connect( tmpElem, SIGNAL(s_KpChanged(QVariant)), PID->kP , SLOT( setValue(QVariant) ), Qt::QueuedConnection );
            QObject::connect(PID->kP, SIGNAL( s_valueChd(QVariant) ), tmpElem, SLOT( setKp(QVariant) ), Qt::QueuedConnection );
        }
        if(PID->kI){
            QObject::connect( tmpElem, SIGNAL(s_KiChanged(QVariant)), PID->kI , SLOT( setValue(QVariant) ), Qt::QueuedConnection );
            QObject::connect(PID->kI, SIGNAL( s_valueChd(QVariant) ), tmpElem, SLOT( setKi(QVariant) ), Qt::QueuedConnection );
        }
        if(PID->kD){
            QObject::connect( tmpElem, SIGNAL(s_KdChanged(QVariant)), PID->kD , SLOT( setValue(QVariant) ), Qt::QueuedConnection );
            QObject::connect(PID->kD, SIGNAL( s_valueChd(QVariant) ), tmpElem, SLOT( setKd(QVariant) ), Qt::QueuedConnection );
        }

        QObject::connect(PID->impIn, SIGNAL( s_valueChd(QVariant) ), tmpElem, SLOT( setImpact(QVariant)), Qt::QueuedConnection );

        QObject::connect(tmpElem, SIGNAL(s_manImpactChanged(QVariant)),  PID->manImp, SLOT(setValue(QVariant)), Qt::QueuedConnection );
        QObject::connect(PID->manImp, SIGNAL(s_valueChd(QVariant)), tmpElem, SLOT(setManImpact(QVariant)), Qt::QueuedConnection );

        QObject::connect( tmpElem, SIGNAL(s_impactMaxChanged(QVariant)), PID->impMax , SLOT( setValue(QVariant) ), Qt::QueuedConnection );
        QObject::connect( PID->impMax, SIGNAL( s_valueChd(QVariant) ), tmpElem, SLOT( setImpactMax(QVariant) ), Qt::QueuedConnection );
        QObject::connect( tmpElem, SIGNAL(s_setPtMinChanged(QVariant)), PID->setPtMin , SLOT( setValue(QVariant) ), Qt::QueuedConnection );
        QObject::connect( PID->setPtMin, SIGNAL( s_valueChd(QVariant) ), tmpElem, SLOT( setImpactMin(QVariant) ), Qt::QueuedConnection );
        if(PID->feedback)
            QObject::connect(PID->feedback, SIGNAL( s_valueChd(QVariant) ), tmpElem, SLOT( setFeedback(QVariant) ), Qt::QueuedConnection );
        return true;
    }
    return false;
}

//------------------------------------------------------------------------------
bool PIDwinConnect(QObject *rootItem, QString ElementName, PIDstep *PIDst)
{
    QObject * tmpElem;
    if( ElementName != "")tmpElem = rootItem->findChild<QObject*>(ElementName);
    else tmpElem = rootItem;
    if( tmpElem != nullptr ){
        PIDwinConnect(rootItem, ElementName, (PID*)PIDst);
        QObject::connect( tmpElem, SIGNAL(s_impMore(QVariant)), PIDst->manImplUp , SLOT( setValue(QVariant) ), Qt::QueuedConnection );
        QObject::connect( tmpElem, SIGNAL(s_impLess(QVariant)), PIDst->manImplDown , SLOT( setValue(QVariant) ), Qt::QueuedConnection );

        QObject::connect( tmpElem, SIGNAL(s_impulseOn(QVariant)), PIDst->manImpulseOn , SLOT( setValue(QVariant) ), Qt::QueuedConnection );
        QObject::connect( PIDst->manImpulseOn, SIGNAL( s_valueChd(QVariant) ), tmpElem, SLOT( setImpulseOn(QVariant) ), Qt::QueuedConnection );

        return true;
    }
    return false;
}

//------------------------------------------------------------------------------

