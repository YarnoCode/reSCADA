#ifndef MODBUSDRIVER_H
#define MODBUSDRIVER_H

#include <QObject>
#include <QSerialPort>
#include <QModbusDataUnit>
#include <QModbusRtuSerialMaster>
#include <QModbusTcpClient>
#include <QModbusDataUnit>
#include <QTimer>
#include "driver.h"

class ModBusDriver : public Driver
{
public:
    //constructor
    ModBusDriver(int Id, QString name, QString address, int port = 502, int timeout = 30, QString comment = "");
    ModBusDriver(int Id, QString name, QString port, QString baudrate, QSerialPort::DataBits databits = QSerialPort::Data8,
                 QSerialPort::Parity parity = QSerialPort::EvenParity, QSerialPort::StopBits stopbits = QSerialPort::OneStop, int timeout = 30, QString comment = "");
    //destructor
    ~ModBusDriver();
    //structs
    struct MBaddress{
        int devAddr, regAddr;
        QModbusDataUnit::RegisterType regType;
    };
    //methods
    void connect() override;
    void disconnect() override;
    // Driver interface
    bool insertGroup(Group *group)override;
private:
    //structs
    struct Task : public MBaddress, CommonTask{};
    //variables
    QList<Task*> listOfTasks;
    QModbusClient * modbusDevice = nullptr;
    //methods
    void initThread(QModbusClient * modbusDevice);
    void handleNextTask() override;
    void getTask();
    void valueFiller(QList<Tag*> listOfTags, QModbusDataUnit unit);
    void read(Task * task, const std::function<void()> doNext);
    void write(Task * task, const std::function<void()> doNext);
    static bool strToAddr(QString str, MBaddress * adress);
    void scheduleHandler();
    static void sortTags(QList<Tag *> &listOfTags);
    static inline bool compare(MBaddress a1, MBaddress a2);
public slots:
    void createWriteTask(Tag * tag, QVariant NewValue = 0 ) override;
};

#endif // MODBUSDRIVER_H
