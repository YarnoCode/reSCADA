﻿#include <qdebug.h>
#include "EngRouteUnit.h"
#include "InDiscretETag.h"

EngRouteUnit::EngRouteUnit(Prom::UnitType Type,
                            int *Id,
                            QString Name,
                            QString TagPrefix,
                            bool Mover,
                            std::vector<QString>,
                            bool BlockedStop,
                            Prom::UnitModes SaveMode)
    : RouteUnit(Type,
                 Id,
                 Name,
                 TagPrefix,
                 Mover,
                 SaveMode),
      _blockedStop(BlockedStop)
{

}

//------------------------------------------------------------------------------
Prom::SetModeResp EngRouteUnit::_customSetMode(Prom::UnitModes *Mode, bool)
{
    switch(*Mode) {
    case Prom::UnMdFreeze:
    case Prom::UnMdStop:{
        _stop();
        if(currentState() == Prom::UnStStoped)
            return Prom::DoneAlready;
        else{
//            _setSetedMode(*Mode);
            return Prom::DoneWhait;
        }

        break;
    }
    case Prom::UnMdStart:
        if( _sensorsConnected && ! _alarm) {
            if(currentState() == Prom::UnStStarted)
                return Prom::DoneAlready;
            else if(_start()){
//                _setSetedMode(*Mode);
                return Prom::DoneWhait;
            }
        }
        break;
    default:;
    }
    return RejAnnown;
}

//------------------------------------------------------------------------------
void EngRouteUnit::_updateStateAndMode()
{
    switch(_getEngNowState()) {
    case Prom::EngNoDef:{
        _setCurrentState(Prom::UnStNoDef);
        _setCurrentMode(Prom::UnMdNoDef);
        emit s_stoped();
        break;
    }
    case Prom::EngToStopForward: {
        _setCurrentState(Prom::UnStStopCommand);
        emit s_stopComand();
        break;
    }
    case Prom::EngStoped: {
        _setCurrentState(Prom::UnStStoped);
            _setCurrentMode(Prom::UnMdStop);
        emit s_stoped();
        break;
    }
    case Prom::EngToForvard: {
        _setCurrentState(Prom::UnStStartCommand);
        emit s_startComand();
        break;
    }
    case Prom::EngForvard: {
//        _cleaned = false;
//        emit s_started();
//        if(mover && _cleanTimer->isActive()){
//            _setCurrentState(Prom::UnStClean);
//            _setCurrentMode(Prom::UnMdStart);
//            emit s_cleaning();
//        }
//        else{
//            if(_cleaned) {
//                _setCurrentState(Prom::UnStCleanStarted);
//                _setCurrentMode(Prom::UnMdCleanStart);
//            }
//            else {
                _setCurrentState(Prom::UnStStarted);
                _setCurrentMode(Prom::UnMdStart);
//            }
//        }
        break;
    }
    case Prom::EngManualForward: {
        _setCurrentState(Prom::UnStManualStarted);
        _setCurrentMode(Prom::UnMdNoDef);
        emit s_manualStarted();
        break;
    }
    case Prom::EngAlarm: {
        _setCurrentState(Prom::UnStNoDef);
        _setCurrentMode(Prom::UnMdNoDef);
        break;
    }
    default:{
        _setCurrentState(Prom::UnStNoDef);
        detectAlarm("недопустимое состояние электродвигателя");
    }
    }
}

//------------------------------------------------------------------------------
void EngRouteUnit::_customConnectToGUI(QObject * guiItem,  QObject *)
{
    connect(this,    SIGNAL(s_startComand()),           guiItem, SLOT(startComand()),             Qt::QueuedConnection);
    connect(this,    SIGNAL(s_stopComand()),            guiItem, SLOT(stopComand()),              Qt::QueuedConnection);
    connect(guiItem, SIGNAL(addToCurrentRoteStarted()), this,    SLOT(addToCurrentRoteStarted()), Qt::QueuedConnection);
    connect(guiItem, SIGNAL(addToCurrentRoteStoped()),  this,    SLOT(addToCurrentRoteStoped()),  Qt::QueuedConnection);
    connect(guiItem, SIGNAL(s_start()),                 this,    SLOT(start()),                   Qt::QueuedConnection);
    connect(guiItem, SIGNAL(s_stop()),                  this,    SLOT(stop()),                    Qt::QueuedConnection);
    connect(this,    SIGNAL(s_stoped()),                guiItem, SLOT(stoped()) ,                 Qt::QueuedConnection);
    connect(this,    SIGNAL(s_manualStarted()),         guiItem, SLOT(manualWork()) ,             Qt::QueuedConnection);
    connect(this,    SIGNAL(s_started()),               guiItem, SLOT(started()),                 Qt::QueuedConnection);
}

//------------------------------------------------------------------------------

