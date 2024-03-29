#ifndef GROUP_H
#define GROUP_H

#include <QObject>
#include <QDateTime>
#include <QList>

#include "tag.h"
#include "listOfTags.h"

class Group : public QObject
{
    Q_OBJECT
public:
    //constructor
    Group(int Id,
        int DriverId,
        QString Name,
        int Delay,
        int OptimizerRangeInterval = 4,
        int OptimizerRangeMax = 70,
        QString Comment = "");
    //destructor
    ~Group();
    //variables
    int delay;
    QDateTime lastUpdate;
    int id;
    int optimRangeInterval;
    int optimRangeMax;
    QString options;
    QString comment;
    int driverId;
    double updateFreq;
    //methods
    void update(bool updateTime = true);
    bool insertTag(Tag *tag);
    ListOfTags listOfTags;
    ListOfTags listOfVirtualTags;
private:
    //variables
    Quality quality = Unknown;
    bool tagsSorted {false};
    //methods
    void setQuality(Quality quality);
signals:
    void s_onQualityChanged(); //for external use
    void s_onWriteRequested(Tag * tag, QVariant NewValue = 0);
    void s_onUpdated();
    void s_logging(Prom::MessType MessTypeID,  QDateTime DateTime, bool UserOrSys, QString Source, QString Message);
    void s_onTagInserted(Group *);
public slots:
    Prom::Quality readQuality(); //for external use
};

#endif // GROUP_H
