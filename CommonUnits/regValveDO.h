#ifndef REGVALVEDO_H
#define REGVALVEDO_H

#ifndef UNIT_H
#include "unit.h"
#endif

class OutETag;
class InETag;
class InDiscretETag;
class OutDiscretETag;
//
namespace regValve {
enum tagsNom
{
    posSetDBN,
    posDBN,
    rangeMaxDBN,
    rangeMinDBN,
    openDBN,
    closeDBN,
    };
typedef std::map< tagsNom, QString> tagsMap;
static const tagsMap StdTagsNames{
        {posSetDBN,      ".posSet"},
        {posDBN,         ".pos"},
        {rangeMaxDBN,    ".rangeMax"},
        {rangeMinDBN,    ".rangeMin"},
        {openDBN,     ".open"},
        {closeDBN,    ".close"}
        };
static const tagsMap SiemensPIDTagsNames{
        {posSetDBN,      ".MAN"},
        {posDBN,         ".pos"},//".LMN"
        {rangeMaxDBN,    ".LMN_HLM"},
        {rangeMinDBN,    ".LMN_LLM"},
        {openDBN,     ".LMNUP"},
        {closeDBN,    ".LMNDN"},
    };
}

class RegValveDO: public Unit
{
    Q_OBJECT
public:
    explicit RegValveDO(int *Id,
        QString Name,
        QString TagPrefix,
        bool SefResetAlarm,
        const regValve::tagsMap *TagsMap);

    InETag         *pos      { nullptr };
    InDiscretETag  *open     { nullptr };
    InDiscretETag  *close    { nullptr };

protected:
    void _alarmDo() override{}
    void _resetAlarmDo() override{}

protected slots:
    Prom::SetModeResp _customSetMode( Prom::UnitModes */*mode*/, bool /*UserOrSys*/ ) override{return Prom::DoneAlready;}
    void _customConnectToGUI( QObject * /*guiItem*/,  QObject * /*propWin*/ ) override;
protected:
    void _updateStateAndMode() override{}
    void _doOnModeChange()override{}
};

//------------------------------------------------------------------------------
class RegValveDOMMS : public RegValveDO
{
    Q_OBJECT
public:
    explicit RegValveDOMMS(int *Id,
        QString Name,
        QString TagPrefix,
        bool SefResetAlarm,
        const regValve::tagsMap *TagsMap);

    OutETag        *posSet      { nullptr };
    OutETag        *rangeMax    { nullptr };
    OutETag        *rangeMin    { nullptr };
protected:
        void _customConnectToGUI( QObject * /*guiItem*/,  QObject * /*propWin*/ ) override;
};

//------------------------------------------------------------------------------

#endif // REGVALVEDO_H
