#ifndef PID_H
#define PID_H

#ifndef UNIT_H
#include "unit.h"
#endif

class InDiscretETag;
class OutDiscretETag;
class MxMnInETag;
class InETag;
class OutETag;

namespace pid {

enum tagsNom{

    manOn,
    setPt,
    setPtMax,
    setPtMin,
    prossVal,
    kP,
    kI,
    kD,
    impUp,
    impDown,
    imp,
    kPimp,
    kIimp,
    kDimp,
    manImp,
    impMax,
    impMin,
    manImpulseOn,
    manImplMore,
    manImplLess,
    feedback
};
typedef std::map< tagsNom, QString> tagsMap;
static const tagsMap StdPIDTagsNames
    {
        {manOn,      ".manOn"},
        {setPt,      ".setPt"},
        {setPtMax,   "setPtMax"},
        {setPtMin,   "setPtMin"},
        {prossVal,   ".prossVal"},
        {kP,         ".kP"},
        {kI,         ".kI"},
        {kD,         ".kD"},
        {impUp,      ".impUp"},
        {impDown,    ".impDown"},
        {imp,        ".imp"},
        {kPimp,      ".kPimp"},
        {kIimp,      ".kIimp"},
        {kDimp,      ".kDimp"},
        {manImp,     ".manImp"},
        {impMax,     ".impLimMax"},
        {impMin,     ".impLimMin"},
        {manImpulseOn,".manImpulseOn"},
        {manImplMore,".manImplMore"},
        {manImplLess,".manImplLess"},
        {feedback,   ".feedback"},
        };
static const tagsMap SiemensPIDTagsNames
    {
        {manOn,      ".MAN_ON"},
        {setPt,      ".SP_INT"},
        {setPtMax,   ".SP_HLM"},
        {setPtMin,   ".SP_LLM"},
        {prossVal,   ".PV"},
        {kP,         ".GAIN"},
        {kI,         ".TI"},
        {kD,         ".TD"},
        {impUp,      ".QLMNUP"},
        {impDown,    ".QLMNDN"},
        {imp,        ".LMN"},
        {kPimp,      ".LMN_P"},
        {kIimp,      ".LMN_I"},
        {kDimp,      ".LMN_D"},
        {manImp,     ".MAN"},
        {impMax,     ".LMN_HLM"},
        {impMin,     ".LMN_LLM"},
        {manImpulseOn,".LMNS_ON"},
        {manImplMore,".LMNUP"},
        {manImplLess,".LMNDN"},
        {feedback,   ".MP10"},
        };
}
//------------------------------------------------------------------------------
struct PID{
    PID(Unit *Owner, QString Name, QString ImpName, QString TagPrefix, const pid::tagsMap *TagsNames,
        uint Option = Prom::PIDopt::allOn);
public:
    QString tagPrefix;
    //QString name;
    //const uint opt { Prom::PIDopt::allOn };

    OutDiscretETag * manOn { nullptr };
    OutETag * setPt { nullptr };
    OutETag * setPtMax { nullptr };
    OutETag * setPtMin { nullptr };
    InETag * process { nullptr };
    InETag * impIn { nullptr };
    OutETag * kP { nullptr };
    OutETag * kI { nullptr };
    OutETag * kD { nullptr };
    InETag * kPimp { nullptr };
    InETag * kIimp { nullptr };
    InETag * kDimp { nullptr };
    OutETag * manImp { nullptr };
    OutETag * impMax { nullptr };
    OutETag * impMin { nullptr };
    InETag * feedback { nullptr };
};
//------------------------------------------------------------------------------
struct PIDstep: public PID{
    PIDstep(Unit *Owner, QString Name, QString ImpName, QString TagPrefix, const pid::tagsMap *TagsNames, uint Option = Prom::PIDopt::allOn );
    OutDiscretETag * manImpulseOn { nullptr };
    OutDiscretETag * manImplUp { nullptr };
    OutDiscretETag * manImplDown { nullptr };
    InETag * impUp { nullptr };
    InETag * impDown { nullptr };
};

#endif // PID_H
