#include <qsettings.h>
#include <qdebug.h>

#include "unit.h"
#include "ETag.h"
#include "InETag.h"
#include "OutETag.h"
#include "InDiscretETag.h"
#include "OutDiscretETag.h"
#include "promobject.h"
#include "QTimerExt.h"

extern QSettings * g_unitINI;
//------------------------------------------------------------------------------
Unit::Unit( Prom::UnitType Type,
            int * Id,
            QString Name,
            QString TagPrefix,
            bool SelfAlarmReset,
            Prom::UnitModes SaveMode,
            QSettings * Ini)
    : unitType(Type),
      saveMode(SaveMode),
      tagPrefix(TagPrefix),
      ini(Ini),
      _id(*Id),
      _alarmSelfReset(SelfAlarmReset)
{
    *Id = *Id + 1;
    setObjectName(Name);

    if(ini == nullptr){
        if(g_unitINI != nullptr) ini = g_unitINI;
        else{
            ini = new QSettings(tagPrefix + ".ini", QSettings::IniFormat);
        }
    }
    //LoadParam();
}
//------------------------------------------------------------------------------
int Unit::id() const
{
    return _id;
}
//------------------------------------------------------------------------------
void Unit::setId(int Id)
{
    _id = Id;
}

//------------------------------------------------------------------------------
void Unit::setAlarmSelfReset(bool AlarmSelfReset)
{
    _alarmSelfReset = AlarmSelfReset;
    _resetAlarm();
}

//------------------------------------------------------------------------------
Prom::SetModeResp Unit::setMode(UnitModes Mode, bool UserOrSys)
{
    logging(Prom::MessChangeCommand, QDateTime::currentDateTime(), UserOrSys, "", "поступила команда - '" + Prom::modeToString(Mode) + "'");
    //_setSetedMode(Prom::UnMdNoDef);
    _setedMode = Mode;
    switch (_customSetMode(&Mode, UserOrSys)) {
    case RejNoCond :
        logging(Prom::MessWarning, QDateTime::currentDateTime(), UserOrSys, "", QString("отклонена из-за отсутствия условий команда - '")+ Prom::modeToString(Mode) + "'");
        _setedMode = Prom::UnMdNoDef;
        return RejNoCond;
    case RejTransPr:
        logging(Prom::MessWarning, QDateTime::currentDateTime(), UserOrSys, "", QString("отклонена из-за переходного процесса команда - '")+ Prom::modeToString(Mode) + "'");
        _setedMode = Prom::UnMdNoDef;
        return RejTransPr;
    case RejAlarm:
        logging(Prom::MessWarning, QDateTime::currentDateTime(), UserOrSys, "", QString("отклонена по аварии команда - '")+ Prom::modeToString(Mode) + "'");
        _setedMode = Prom::UnMdNoDef;
        return RejAlarm;
    case RejAnnown:
        logging(Prom::MessWarning, QDateTime::currentDateTime(), UserOrSys, "", QString("отклонена неизвестная команда - '")+ Prom::modeToString(Mode) + "'");
        _setedMode = Prom::UnMdNoDef;
        return  RejAnnown;
    case DoneAlready:
        _setedMode = Prom::UnMdNoDef;
        //_setCurrentMode(Mode);
        return DoneAlready;
    case DoneWhait:
        logging(Prom::MessChangeCommand, QDateTime::currentDateTime(), UserOrSys, "", QString("принята к исполнению команда - '")+ Prom::modeToString(Mode) + "'");
        return DoneWhait;
    }
    _setedMode = Prom::UnMdNoDef;
    return  RejAnnown;
}

//------------------------------------------------------------------------------
void Unit::setBlocked(bool blocked)
{
    _blocked = blocked;
}

//------------------------------------------------------------------------------
bool Unit::isCurrOrSetedModeIn(QVector<UnitModes> Modes)
{
    return (currentModeIn(Modes) || setedModeIn(Modes)) ;
}

//------------------------------------------------------------------------------
void Unit::addTimer(QTimerExt *Timer)
{
    if(Timer->thread() != this->thread()){
        //Timer->setParent(nullptr);
        Timer->moveToThread(ownThread);
    }
    //Timer->setParent(this);
    _allTimers.append(Timer);
}
//------------------------------------------------------------------------------
bool Unit::setedModeIn(QVector<UnitModes> modes)
{
    foreach (Prom::UnitModes m, modes){
        if(setedMode() == m)
            return true;
    }
    return false;
}
//------------------------------------------------------------------------------
bool Unit::setedModeNotIn(QVector<UnitModes> modes)
{
    foreach (Prom::UnitModes m, modes){
        if(setedMode() == m)
            return false;
    }
    return true;
}

//------------------------------------------------------------------------------
bool Unit::currentModeIn(QVector<Prom::UnitModes> modes)
{
    foreach (Prom::UnitModes m, modes){
        if(currentMode() == m)
            return true;
    }
    return false;
}

//------------------------------------------------------------------------------
bool Unit::currentModeNotIn(QVector<Prom::UnitModes> modes)
{
    foreach (Prom::UnitModes m, modes){
        if(currentMode() == m)
            return false;
    }
    return true;
}

//------------------------------------------------------------------------------
bool Unit::stateIn(QVector<UnitStates> states)
{
    foreach (Prom::UnitStates s, states){
        if(currentState() == s)
            return true;
    }
    return false;
}

//------------------------------------------------------------------------------
bool Unit::stateNotIn(QVector<UnitStates> states)
{
    foreach (Prom::UnitStates s, states){
        if(currentState() == s)
            return false;
    }
    return true;
}

//------------------------------------------------------------------------------
void Unit::_setCurrentMode(UnitModes currentMode, bool resultMode)
{
    if(_currentMode != currentMode || resultMode ) {
        if( _setedMode == currentMode  ) resultMode = true;
        if(_setedMode != Prom::UnMdNoDef && resultMode){

            logging(Prom::MessChangeState, QDateTime::currentDateTime(), false,
                    "", QString((icvalModes(_setedMode, _currentMode) ? "" : "не"))
                    + "выполнена команда - '" +  Prom::modeToString(_currentMode) + "'");
            _setedMode = Prom::UnMdNoDef;
            QString S = QString((icvalModes(_setedMode, _currentMode) ? "   " : "no "))
                    + "done - '" + _currentMode + "'";
            qDebug()<<S;
        }
        _prevMode = _currentMode;
        _currentMode = currentMode;
        if(resultMode)
            _doOnModeChange();
    }
    emit s_modeChange(this);
}

//------------------------------------------------------------------------------
void Unit::_setSetedMode(Prom::UnitModes setedMode)
{
    _setedMode = setedMode;
}

//------------------------------------------------------------------------------
void Unit::_rejectSetedMode()
{
    _setCurrentMode(_currentMode);
}

//------------------------------------------------------------------------------
void Unit::_setCurrentState(Prom::UnitStates currentState)
{
    if (currentState != _currentState){
        _prevState = _currentState;
        _currentState = currentState;
        logging(Prom::MessChangeState, QDateTime::currentDateTime(), false, "", QString("cмена состояния на '" +  Prom::stateToString(_currentState) + "'"));
        emit s_stateChange(this);
    }
}

//------------------------------------------------------------------------------
void Unit::subUnTagAlarmReseted()
{
    if( !_alarmSelfReset) return;

    static bool preAlarm { false };
    preAlarm = _alarm;
    _alarm = false;

    foreach(ETag * tag, _tags){
        _alarm |= tag->isAlarm();
    }
    foreach (Unit * unit, _subUnits) {
        _alarm |= unit->isAlarm();
    }
    _alarm |= _alarmConnection;

    if(_alarm){
        emit s_alarm("");
    }
    else {
        if(preAlarm)logging(Prom::MessInfo, QDateTime::currentDateTime(), false, "", "аварии сброшены");
        _resetAlarmDo();
        emit s_alarmReseted();
    }
}
//------------------------------------------------------------------------------
void Unit::allTimerStop()
{
    foreach (QTimerExt * timer, _allTimers) {
        timer->stop();
    }
}

//------------------------------------------------------------------------------
bool Unit::anySubUnitHaveMode(UnitModes Mode, UnitType Type)
{
    foreach (Unit * unit, _subUnits) {
        if(unit->unitType == Type || Type == Prom::TypeNoDef){
            if(unit->currentMode() == Mode)
                return true;
        }
    }
    return false;
}

PromObject *Unit::owner() const
{
    return _owner;
}
//------------------------------------------------------------------------------
void Unit::setOwner(PromObject *Owner)
{
    _owner = Owner;
}

//------------------------------------------------------------------------------
void Unit::updateState()
{
    if(_sensorsConnected)
        _updateStateAndMode();
    else {
        _setCurrentState(Prom::UnStNotConnected);
        _setCurrentMode(Prom::UnMdNoDef);
    }
}

//------------------------------------------------------------------------------
void Unit::moveToThread(QThread *thread)
{
    if(thread){
        ownThread = thread;
        this->QObject::moveToThread(thread);
        foreach (QTimerExt * timer, _allTimers) {
            if(timer->thread() != this->thread()){
                //timer->setParent(nullptr);
                timer->moveToThread(ownThread);
            }
            //timer->setParent(this);
            timer->moveToThread(ownThread);
        }
        foreach (ETag * tag, _tags) {
            tag->moveToThread(ownThread);
            //tag->setParent(this);
        }
        foreach (Unit * unit, _subUnits) {
            unit->moveToThread(ownThread);
            //unit->setParent(this);
        }
    }
}
//------------------------------------------------------------------------------
void Unit::addETag(ETag * tag)
{

    if(_tags.contains(tag)){
        return;
    }
    _tags.append(tag);
    if(ownThread)
        tag->moveToThread(ownThread);
    if(!tag->parent())
        //tag->setParent(this);
        connect(tag, &ETag::s_qualityChd, this, &Unit::_sensorConnect);
    connect(tag, &ETag::s_alarm, this, &Unit::detectAlarm);
    if(_alarmSelfReset)
        connect(tag, &ETag::s_alarmReseted, this, &Unit::subUnTagAlarmReseted);
    if(_sensorsConnected != tag->connected())
        _sensorConnect();
}

//------------------------------------------------------------------------------
void Unit::removeETag(ETag *tag)
{
    if(!_tags.contains(tag)){
        return;
    }
    _tags.removeOne(tag);

    if(tag->parent() == (QObject*)this)
        //tag->setParent(nullptr);
        disconnect(tag, &ETag::s_qualityChd, this, &Unit::_sensorConnect);
    disconnect(tag, &ETag::s_alarm, this, &Unit::detectAlarm);
    if(_alarmSelfReset)
        disconnect(tag, &ETag::s_alarmReseted, this, &Unit::subUnTagAlarmReseted);
    if(_sensorsConnected != tag->connected())
        _sensorConnect();
}

//------------------------------------------------------------------------------
bool Unit::addSubUnit(Unit * unit)
{
    if( unit != nullptr && _subUnits.indexOf( unit ) < 0 ){
        _subUnits.append(unit);
        if(ownThread)
            unit->moveToThread(ownThread);
        //unit->setParent(this);
        unit->ini = ini;
        connect(unit, &Unit::s_loggingSig, this, &Unit::logging, Qt::QueuedConnection);
        connect(unit, &Unit::s_alarmForAnderUnit, this, &Unit::detectSubUnitAlarm, Qt::QueuedConnection);
        connect(unit, &Unit::s_modeChange, this, &Unit::_updateSubUnitMode, Qt::QueuedConnection);
        connect(unit, &Unit::s_stateChange, this, &Unit::_updateSubUnitState, Qt::QueuedConnection);
        if(_alarmSelfReset)
            connect(unit, &Unit::s_alarmReseted, this, &Unit::subUnTagAlarmReseted);
        //    if( _owner != nullptr ){
        //      _owner->addSubUnit( unit );
        //    }
        return true;
    }
    return false;
}
//------------------------------------------------------------------------------
bool Unit::removeSubUnit(Unit *unit)
{
    if( unit != nullptr && _subUnits.indexOf( unit ) != 0 ){
        _subUnits.removeAll(unit);
        if(ownThread)
            unit->moveToThread( this->parent()->thread() );
        //unit->setParent(this->parent());
        unit->ini = ini;
        disconnect(unit, &Unit::s_loggingSig, this, &Unit::logging);
        disconnect(unit, &Unit::s_alarmForAnderUnit, this, &Unit::detectSubUnitAlarm);
        disconnect(unit, &Unit::s_modeChange, this, &Unit::_updateSubUnitMode);
        disconnect(unit, &Unit::s_stateChange, this, &Unit::_updateSubUnitState);
        if(_alarmSelfReset){
            disconnect(unit, &Unit::s_alarmReseted, this, &Unit::subUnTagAlarmReseted);
            resetAlarm();
        }
        return true;
    }
    return false;
}

//------------------------------------------------------------------------------
void Unit::detectAlarm(QVariant Description)
{
    static QString Source;
    if(Description == ""){
        return;
    }
    if(sender())
        Source = sender()->objectName();
    _alarm = true;
    //_mayResetAlarm = false;
    if( ! _firstLoad/*!Prom::icvalModes(_currentMode, saveMode) && _currentMode != Prom::UnMdNoDef &&*/) {
        emit s_quitAlarm(objectName() + " - " +  Description.toString());
        logging(Prom::MessQuitAlarm, QDateTime::currentDateTime(), false, Source, Description.toString());
    }
    else {
        emit s_alarm(objectName()  + " - " +  Description.toString());
        logging(Prom::MessAlarm, QDateTime::currentDateTime(), false, Source, Description.toString());
    }
    if(!_firstLoad)
        _alarmDo();
    emit s_alarmForAnderUnit(this, Description.toString());
}

//------------------------------------------------------------------------------
void Unit::detectSubUnitAlarm(Unit * unit, QString Description)
{
    if(Description == ""){
        return;
    }
    _alarm = true;
    if(!Prom::icvalModes(_currentMode, saveMode) && _currentMode != Prom::UnMdNoDef && ! _firstLoad) {
        emit s_quitAlarm(objectName() + " - " +  Description);
        //        Logging(Prom::MessQuitAlarm, QDateTime::currentDateTime(), false, "", "Авария внутреннего юнита "
        //                 + unit->objectName());
    }
    else {
        emit s_alarm(objectName()  + " - " +  Description);
        //        Logging(Prom::MessAlarm, QDateTime::currentDateTime(), false, "", "Авария внутреннего юнита "
        //                 + unit->objectName());
    }
    emit s_alarmForAnderUnit(this, Description);
    if(!_firstLoad)
        _alarmSubUnitDo(unit);
}

//------------------------------------------------------------------------------
void Unit::_alarmDo()
{
    //(Prom::UnMdStop, false);
}

//------------------------------------------------------------------------------
void Unit::_alarmSubUnitDo( Unit *)
{
    //setMode(Prom::UnMdStop, false);
    //foreach (Unit * unit, _subUnits) {
    //  unit->setMode(unit->saveMode, false);
    //}
}

//------------------------------------------------------------------------------
bool Unit::_resetAlarm(bool upClassAlarm)
{
    static bool preAlarm { false };
    _alarm = upClassAlarm;
    preAlarm = _alarm;
    foreach(ETag * tag, _tags){
        _alarm |= !tag->resetAlarm();
    }
    foreach (Unit * unit, _subUnits) {
        _alarm |= ! unit->_resetAlarm();
    }
    _alarm |= _alarmConnection;

    if(_alarm){
        logging(Prom::MessWarning, QDateTime::currentDateTime(), false, "", "аварии не сброшены");
        emit s_alarmReseted();
        emit s_alarm("");
    }
    else {
        if(preAlarm)logging(Prom::MessInfo, QDateTime::currentDateTime(), false, "", "аварии сброшены");
        _resetAlarmDo();
        emit s_alarmReseted();
    }
    return ! _alarm;
}

//------------------------------------------------------------------------------
void Unit::setAlarmTag(QString tagName)
{
    _alarmInit = true;
    logging(Prom::MessAlarm, QDateTime::currentDateTime(), false, "", "ошибка загрузки тега " + tagName);
    //_DetectAlarm("ошибка загрузки тега " + tagName);
}

//------------------------------------------------------------------------------
QVector<Unit *> Unit::subUnits() const
{
    return _subUnits;
}

//------------------------------------------------------------------------------
void Unit::logging(Prom::MessType MessTypeID, QDateTime DateTime, bool UserOrSys, QString Source, QString Message)
{
    emit s_loggingSig(MessTypeID, DateTime, UserOrSys, objectName(),
                      ((Source == "" && Source != objectName())? "" : Source + "->") + Message);
}

//------------------------------------------------------------------------------
bool Unit::connectToGUI(const QObject * GUI)
{
    QObject * guiItem = GUI->findChild<QObject*>(this->tagPrefix);
    if(!guiItem){
        if( GUI->parent() ){
            guiItem = GUI->parent()->findChild<QObject*>(this->tagPrefix);
        }
    }
    if(!guiItem){
        logging(Prom::MessAlarm, QDateTime::currentDateTime(), false, tagPrefix, "в " + GUI->objectName() + " GUI не обнаружен");
        return false;
    }
    QObject * guiItemUnit = guiItem->findChild<QObject*>("unit");
    if(!guiItemUnit) guiItemUnit = guiItem; //Если нет дочернего с .unit, то подключаем GUI как обычно к корневому.
    //Logging(Prom::MessChangeInfo, QDateTime::currentDateTime(), unit->objectName(), "GUI обнаружен");
    connect(this, SIGNAL(s_connected()), guiItemUnit, SLOT(setConnected()), Qt::QueuedConnection);
    connect(this, SIGNAL(s_disconnected()), guiItemUnit, SLOT(setDisconnected()), Qt::QueuedConnection);

    connect(this,        SIGNAL(s_alarm(QVariant)),     guiItemUnit, SLOT(setAlarm(QVariant)), Qt::QueuedConnection);
    connect(this,        SIGNAL(s_quitAlarm(QVariant)), guiItemUnit, SLOT(setQuitAlarm(QVariant)   ), Qt::QueuedConnection);
    connect(this,        SIGNAL(s_alarmReseted() ),     guiItemUnit, SLOT(alarmReseted()), Qt::QueuedConnection);
    connect(guiItemUnit, SIGNAL(s_resetAlarm()),          this,        SLOT(resetAlarm()  ), Qt::QueuedConnection);
    //QMetaObject::invokeMethod(guiItemUnit, "setName", Qt::DirectConnection, Q_ARG(QVariant, this->objectName()));
    QMetaObject::invokeMethod(guiItemUnit, "setLinked", Qt::DirectConnection);

    QObject * propWin =  guiItemUnit->findChild<QObject*>("propWindow");

    //QVariant ret;
    //QObject * tmpSgSt, * engRow;

    _customConnectToGUI(guiItem, propWin);
    foreach (ETag * ET , _tags) {
        ET->connectToGUI(guiItemUnit, propWin);
    }
    foreach (Unit * unit, _subUnits) {
        //Если ГУЙ дочернего юнита не найден в ГУЙ родителя, то ищем в общем ГУЙ уровнем выше
        //WRNING Возможны проблемы при совпадедии имён доченних объектов.
        if( ! unit->connectToGUI(guiItem) ){
            unit->connectToGUI(GUI);
        }
    }
    reInitialise();
    return true;
}

//------------------------------------------------------------------------------
void Unit::saveParam()
{
    ini->setValue(tagPrefix + "/exName", _exName);
    foreach(ETag * tag, _tags){
        tag->saveParam();
    }
    foreach (Unit * unit, _subUnits) {
        unit->saveParam();
    }
    //ini->sync();
}

//------------------------------------------------------------------------------
void Unit::loadParam()
{
    _exName = ini->value(tagPrefix + "/exName", "").toString();
    emit s_shangeExName(_exName);
    foreach (ETag * tag, _tags) {
        tag->loadParam();
    }
    foreach (Unit * unit, _subUnits) {
        unit->loadParam();
    }
    //rescanUnit();
}

//------------------------------------------------------------------------------
void Unit::reInitialise()
{
    emit s_shangeExName(_exName);
    _sensorConnect();
    foreach(ETag * tag, _tags){
        tag->reInitialise();
    }
    foreach (Unit * unit, _subUnits) {
        unit->reInitialise();
    }
}

//------------------------------------------------------------------------------
void Unit::_sensorConnect()
{
    _sensorsConnected = true;
    foreach(ETag * tag, _tags){
        _sensorsConnected &= tag->connected();
    }
    if(_firstLoad){
        if(_sensorsConnected) {
            _alarmConnection = false;
            emit s_connected();
            _firstLoad = false;
        }
    }
    else {
        if(_sensorsConnected){
            _alarmConnection = false;
            emit s_connected();
        }
        else{
            if(!_alarmConnection){
                _alarmConnection = true;
                detectAlarm("обрыв соединеия");
                _setCurrentState(Prom::UnStNotConnected);
                _setCurrentMode(Prom::UnMdNoDef);
                emit s_disconnected();
            }
        }
    }
    //UpdateState();
}

//------------------------------------------------------------------------------
