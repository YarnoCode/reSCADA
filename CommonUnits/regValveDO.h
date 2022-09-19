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
    rangeTopDBN,
    rangeBottomDBN,
    openOutDBN,
    closeOutDBN,
    };
typedef std::map< tagsNom, QString> tagsMap;
static const tagsMap StdTagsNames{
        {posSetDBN,      ".posSet"},
        {posDBN,         ".pos"},
        {rangeTopDBN,    ".rangeTop"},
        {rangeBottomDBN, ".rangeBottom"},
        {openOutDBN,     ".openOut"},
        {closeOutDBN,    ".closeOut"}
        };
static const tagsMap SiemensPIDTagsNames{
        {posSetDBN,      ".MAN"},
        {posDBN,         ".pos"},//".LMN"
        {rangeTopDBN,    ".LMN_HLM"},
        {rangeBottomDBN, ".LMN_LLM"},
        {openOutDBN,     ".LMNUP"},
        {closeOutDBN,    ".LMNDN"},
    };
}

class RegValveDO : public Unit
{
    Q_OBJECT
public:
    explicit RegValveDO(int *Id,
        QString Name,
        QString TagPrefix,
        bool SefResetAlarm,
        const regValve::tagsMap *TagsMap);

    OutETag        *posSet      { nullptr };
    InETag         *pos         { nullptr };
    OutETag        *rangeTop    { nullptr };
    OutETag        *rangeBottom { nullptr };
    OutDiscretETag *openOut     { nullptr };
    OutDiscretETag *closeOut    { nullptr };



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

#endif // REGVALVEDO_H
