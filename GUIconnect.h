#ifndef GUICONNECT_H
#define GUICONNECT_H
//#ifndef SCADAENUMS_H

//#include <QVariant>
#include <QObject>
//#include <QDateTime>
//#include "SCADAenums.h"
//#include "QTimerExt.h"

class ETag;
class InETag;
class MxMnInETag;
struct PID;
struct PIDstep;

bool AnalogSignalVar1Connect( QObject *rootItem, QString ElementName, ETag *Tag );
bool AnalogSignalVar2Connect(QObject *rootItem, QString ElementName, InETag *Tag );
bool AnalogSignalVar2Connect(QObject *rootItem, QString ElementName, MxMnInETag *Tag );
bool PIDwinConnect( QObject *rootItem, QString ElementName, PID * PID );
bool PIDwinConnect( QObject *rootItem, QString ElementName, PIDstep * PIDstep );
#endif
