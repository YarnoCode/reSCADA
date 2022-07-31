#include <QSettings>
#include "PID.h"
#include "OutDiscretETag.h"
#include "InDiscretETag.h"
#include "InETag.h"
#include "MxMnInETag.h"

PID::PID(Unit *Owner, QString Name, QString ImpName, QString TagPrefix, const pid::tagsMap *TagsNames , uint Option)
    :tagPrefix(TagPrefix)
    //name(Name),
    //:Option(Option)
{
    manOn = new OutDiscretETag( Owner, Prom::PreSet, Name + " ручной режим", TagPrefix + TagsNames->at( pid::manOn ) );
    setPt = new OutETag( Owner, Prom::TpOut, Prom::PreSet, Name + " уставка",  TagPrefix + TagsNames->at(pid::setPt));
    setPtMax = new OutETag( Owner, Prom::TpOut, Prom::PreSet, Name + " макс. уставка",  TagPrefix + TagsNames->at(pid::setPtMax));
    setPtMin = new OutETag( Owner, Prom::TpOut, Prom::PreSet, Name + " мин. уставка",  TagPrefix + TagsNames->at(pid::setPtMin));
    process = new InETag( Owner, Prom::TpIn, Name, TagPrefix + TagsNames->at(pid::prossVal), true, 0, 1, false, false, false, false);

    if( Option & PIDopt::kP ) kP = new OutETag( Owner, Prom::TpOut, Prom::PreSet, Name + " коэф. П",  TagPrefix + TagsNames->at(pid::kP) );
    if( Option & PIDopt::kI ) kI = new OutETag( Owner, Prom::TpOut, Prom::PreSet, Name + " коэф. И",  TagPrefix + TagsNames->at(pid::kI), false,false,false,true,Prom::VCdiv1000);
    if( Option & PIDopt::kD ) kD = new OutETag( Owner, Prom::TpOut, Prom::PreSet, Name + " коэф. Д",  TagPrefix + TagsNames->at(pid::kD), false,false,false,true,Prom::VCdiv1000);

    if( Option & PIDopt::kPimp ) kPimp = new InETag( Owner, Prom::TpIn, Name + " возд-е П",  TagPrefix + TagsNames->at(pid::kPimp), true, 100, 0.5, false, false, false, false, true);
    if( Option & PIDopt::kIimp ) kIimp = new InETag( Owner, Prom::TpIn, Name + " возд-е И",  TagPrefix + TagsNames->at(pid::kIimp), true, 100, 0.5, false, false, false, false, true);
    if( Option & PIDopt::kDimp ) kDimp = new InETag( Owner, Prom::TpIn, Name + " возд-е Д",  TagPrefix + TagsNames->at(pid::kDimp), true, 100, 0.5, false, false, false, false, true);

    if( Option & PIDopt::manImp )manImp = new OutETag( Owner, Prom::TpOut, Prom::PreSet, ImpName + " руч. упр-е",  TagPrefix + TagsNames->at(pid::manImp));
    if( Option & PIDopt::impIn )impIn = new InETag( Owner, Prom::TpIn, ImpName ,  TagPrefix + TagsNames->at(pid::imp), true, 100, 1, false, false, false, false, true);
    if( Option & PIDopt::impLimMax )impMax = new OutETag( Owner, Prom::TpOut, Prom::PreSet, ImpName + " макс. воздей-е",  TagPrefix + TagsNames->at(pid::impMax));
    if( Option & PIDopt::impLimMin )impMin = new OutETag( Owner, Prom::TpOut, Prom::PreSet, ImpName + " мин. воздей-е",  TagPrefix + TagsNames->at(pid::impMax));
}
//------------------------------------------------------------------------------
PIDstep::PIDstep(Unit *Owner, QString Name, QString ImpName, QString TagPrefix, const pid::tagsMap *TagsNames, uint Option )
    :PID(Owner, Name, ImpName, TagPrefix, TagsNames, Option)
{
    manImpulseOn = new OutDiscretETag( Owner, Prom::PreSet, ImpName + " ручной режим упр. импульсов", TagPrefix + TagsNames->at(pid::manImpulseOn) );
    manImplUp = new OutDiscretETag( Owner, Prom::PreSet, ImpName + " руч. импульс больше", TagPrefix + TagsNames->at(pid::manImplMore) );
    manImplDow = new OutDiscretETag( Owner, Prom::PreSet, ImpName + " руч. импульс меньше", TagPrefix + TagsNames->at(pid::manImplLess) );
    impUp = new InDiscretETag( Owner, ImpName + " авто. импульс меньше", TagPrefix + TagsNames->at(pid::impUp), true, false, true, false, false, false);
    impDown = new InDiscretETag( Owner, ImpName + " авто. импульс больше", TagPrefix + TagsNames->at(pid::impDown), true, false, true, false, false, false);
}

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

















