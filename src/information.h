#pragma once

#include <QObject>
#include <QQmlListProperty>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>

#include "networkmanger.h"

class StationInfo: public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString id READ id NOTIFY idChanged)
    Q_PROPERTY(QString name READ name NOTIFY nameChanged)

public:
    explicit StationInfo(const QJsonObject value);

    QString id() const { return m_id; }
    QString name() const { return m_name; }

signals:
    void idChanged(QString id);
    void nameChanged(QString name);

private:
    QString m_id { "0" };
    QString m_name { "None" };
};

class DataModel: public QObject
{
    Q_OBJECT

    Q_PROPERTY(QJsonObject data READ data NOTIFY dataChanged)

public:
    explicit DataModel(const QJsonObject value);

    QJsonObject data() const { return m_obj; }

signals:
    void dataChanged(QJsonObject data);

private:
    QJsonObject m_obj;
};

class Information : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QQmlListProperty<StationInfo> stationsModel READ stationsModel NOTIFY stationsModelChanged)
    Q_PROPERTY(QQmlListProperty<DataModel> ticketsModel READ ticketsModel NOTIFY ticketsModelChanged)
    Q_PROPERTY(QQmlListProperty<DataModel> routeModel READ routeModel NOTIFY routeModelChanged)

public:
    explicit Information(QObject *parent = nullptr);

    Q_INVOKABLE void setSearchType(const bool value);
    Q_INVOKABLE void getStations(const QString &name);
    Q_INVOKABLE void clearStationsList() { m_stations.clear(); }

    Q_INVOKABLE void getTickets(const QString &link);

    Q_INVOKABLE QString getBuyUrl(const QString &url);
    Q_INVOKABLE void getRoute(const QString &link);

    QQmlListProperty<StationInfo> stationsModel() { return QQmlListProperty<StationInfo>(this, m_stations); }
    QQmlListProperty<DataModel> ticketsModel() { return QQmlListProperty<DataModel>(this, m_tickets); }
    QQmlListProperty<DataModel> routeModel() { return QQmlListProperty<DataModel>(this, m_routes); }

signals:
    void noTicketsFound();
    void noStationsFound();
    void stationsModelChanged(QList<StationInfo *> result);
    void ticketsModelChanged(QList<DataModel *> result);
    void routeModelChanged(QList<DataModel *> result);

private slots:
    void parseStationsList(const QJsonValue& arr);
    void parseTicketsList(const QByteArray &result);
    void parseSuburbanTickets(const QByteArray &result);

private:
    NetworkManger m_manager;
    QList<StationInfo *> m_stations;
    QList<DataModel *> m_tickets;
    QList<DataModel *> m_routes;

    bool m_roundTrip {false};
    bool m_suburbanSearch {false};
};

// INFORMATION_H
