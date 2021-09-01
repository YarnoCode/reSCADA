﻿//#include <Simargl/score.h>
#include <qdebug.h>
#include "TransporterPS1CB1.h"
#include "electroengine.h"
#include "../../SCADAenums.h"
#include "InDiscretETag.h"
#include "OutDiscretETag.h"


TransporterPS1CB1::TransporterPS1CB1( int ID,
                                  QString Name,
                                  QString TagPefix,
                                  std::vector<QString> EngSensorNames,
                                  bool PS_NOnotNC,
                                  bool CB_NOnotNC )

    : OneEngRouteUnit(  Prom::TypeTransporter,
                        ID,
                        Name,
                        TagPefix,
                        true,
                        EngSensorNames )
{
    _PS = new InDiscretETag( this,
                             "Датчик подпора",
                             ".PS", true, false,
                             PS_NOnotNC, true );

    _PS->needBeUndetectedAlarm();

    _CB = new InDiscretETag( this,
                             "Датчик обрава цепи",
                             ".CB", true, false,
                             CB_NOnotNC, false );
    _CB->needBeDetectedAlarm();
}
