#include "information.h"
#include <limits>
#include <QUrl>
#include <QJsonValue>

Information::Information(QObject *parent) : QObject(parent)
{
    connect(&m_manager, &NetworkManger::sendResponse, [=](const QJsonDocument &result){
        if (result.object().value("data").isArray())
        {
            m_stations.clear();
            QJsonValue arr { result.object().value("data") };

//            qDebug().noquote() << "Arr" << arr;
            for (auto object : arr.toArray() )
            {
                QJsonObject obj = object.toObject();
                if (obj.contains("id") && obj.contains("value"))
                {
                    m_stations.append(new StationInfo(obj));
                }
            }
            if (m_stations.count() > 0)
            {
                emit stationsModelChanged(m_stations);
            }
            else
            {
                m_stations.clear();
                emit stationsModelChanged(m_stations);
                emit noStationsFound();
            }
        }
        else if (result.object().value("data").isObject())
        {
            QJsonObject object = result.object().value("data").toObject();
            if (object.contains("routeStationList"))
            {
                QJsonArray stationsList = object.value("routeStationList").toObject().value("stationList").toArray();
                m_routes.clear();
                for (auto station : stationsList)
                {
                    m_routes.append(new DataModel(station.toObject()));
                }
                emit routeModelChanged(m_routes);
            }
        }
    });

    connect(&m_manager, &NetworkManger::sendResponse, [=](const QJsonDocument &result){
        if (result.object().value("data").isString())
        {
            QString str = result.object().value("data").toString();
            QByteArray arr = str.toUtf8();
            parseTicketsList(arr);
        }
    });
}

void Information::getStations(const QString &name)
{
    //https://www.tutu.ru/suggest/railway_simple/?name=
    QUrl url = "https://www.tutu.ru/suggest/railway_simple/?name=" + name;

    m_manager.performRequest(RequestType::Get, url);
}

void Information::getTickets(const QString &link)
{
    QUrl url = link;

    m_manager.performRequest(RequestType::Get, url);
}

QString Information::getBuyUrl(const QString &url)
{
    QString str = "https://c45.travelpayouts.com/click?shmarker=81618&promo_id=1770&source_type=customlink&type=click&custom_url=" + QUrl::toPercentEncoding(url);
    return str;
}

void Information::getRoute(const QString &link)
{
    QUrl url = "https://www.tutu.ru/" + link;
    m_manager.performRequest(RequestType::Get, url);
}

void Information::parseStationsList(const QJsonDocument result)
{
    if (result.object().value("data").isArray())
    {
        m_stations.clear();
        QJsonValue arr { result.object().value("data") };

        for(auto object : arr.toArray() )
        {
            QJsonObject obj = object.toObject();
            if (obj.contains("id") && obj.contains("value"))
            {
                m_stations.append(new StationInfo(obj));
            }
        }
        if(m_stations.count() > 0)
        {
            emit stationsModelChanged(m_stations);
        }
    }
}

void Information::parseTicketsList(const QByteArray &result)
{
//    qDebug().noquote() << result;
    QString s("window.params = ");
    QString s1("}}}}}}");
    int first = result.indexOf(s) + s.length();
    int last = result.lastIndexOf(s1) + s1.length();
    QByteArray arr = result.mid(first, (last - first));
    //window.params = {
    //}}}}}};

//    qDebug().noquote() << arr;

    QJsonDocument allData = QJsonDocument::fromJson(arr);


    QJsonObject root = allData.object();

    QJsonArray searchResultList = root.value("componentData").toObject().value("searchResultList").toArray();
    if (searchResultList.isEmpty())
    {
        emit noTicketsFound();
        return;
    }
    QJsonObject references = root.value("references").toObject();

    auto station = [=](const QJsonObject& list, const QString key) -> QString {
        for (auto item : list.value("stations").toArray())
        {
            if (item.toObject().value("code").toString() == key)
            {
                QString cityCode = item.toObject().value("cityCode").toString();
                QString cityName;
                QString stationName = item.toObject().value("humanName").toString();
                for (auto city : list.value("cities").toArray())
                {
                    if (city.toObject().value("code").toString() == cityCode)
                    {
                        cityName = city.toObject().value("name").toString();
                        break;
                    }
                }
                return cityName + ", " + stationName;
            }
        }
    };
//    qDebug().noquote() << "references" << references;
//    qDebug().noquote() << "\n\n\ntickets" << tickets;
    for (auto searchItem : searchResultList)
    {
        QJsonArray tickets = searchItem.toObject().value("trains").toArray();
        qDebug() << "m_roundTrip before" << m_roundTrip;
        m_roundTrip = !m_roundTrip;
        qDebug() << "m_roundTrip after" << m_roundTrip;
        for(auto param : tickets)
        {
           if(param.toObject().value("type").toString() == "withSeats")
           {
               QJsonObject result;
               QJsonObject object = param.toObject();

               QJsonObject tripInfo = object.value("params").toObject().value("run").toObject();
               QJsonObject trip = object.value("params").toObject().value("trip").toObject();
               QJsonObject ticketsInfo = object.value("params").toObject().value("withSeats").toObject();

               qDebug() << "m_roundTrip set" << m_roundTrip;
               result.insert("direction", m_roundTrip);
               result.insert("buyUrl", ticketsInfo.value("buyAbsUrl").toString());
               result.insert("trainNumber", tripInfo.value("number").toString());
               result.insert("trainName", tripInfo.value("name").toString());
               result.insert("isFirm", tripInfo.value("isFirm").toBool());
               result.insert("trainArrivalDateTime", tripInfo.value("trainArrivalDateTime").toInt());
               result.insert("trainDepartureDateTime", tripInfo.value("trainDepartureDateTime").toInt());
               result.insert("tripDuration", trip.value("travelTimeSeconds").toInt());
               result.insert("routeInfo", tripInfo.value("aboutTrainAjaxUrl").toString());

               QString arrStation = station(references, trip.value("arrivalStation").toString());
               QString depStation = station(references, trip.value("departureStation").toString());
              result.insert("arrivalStation", arrStation);
              result.insert("departureStation", depStation);

               QJsonArray prices = ticketsInfo.value("categories").toArray();
               QJsonArray ticketsPrice;
               int minPrice = std::numeric_limits<int>::max();
               int seatsCount = 0;
               QString currency;
               for(auto price : prices)
               {
                   QJsonObject item = price.toObject();
                   if (item.value("type").toString() == "prices")
                   {
                       QJsonObject price;
                       QJsonObject _param = item.value("params").toObject();
                       price.insert("seatsCount", _param.value("seatsCount").toInt());
                       seatsCount += _param.value("seatsCount").toInt();
                       price.insert("type", _param.value("type").toString());
                       QJsonObject _price = _param.value("price").toObject();
                       QString key = _price.keys().at(0);
                       currency = key;
                       price.insert("currency", key);
                       if(minPrice > _price.value(key).toInt())
                       {
                           minPrice = _price.value(key).toInt();
                       }
                       price.insert("price", _price.value(key).toInt());
                       price.insert("bottomSeatsCount", _param.value("bottomSeatsCount").toInt());
                       price.insert("bottomSeatsPrice", _param.value("bottomSeatsPrice").toInt());
                       price.insert("topSeatsCount", _param.value("topSeatsCount").toInt());
                       price.insert("topSeatsPrice", _param.value("topSeatsPrice").toInt());

                       QJsonValue priceValue(price);
                       ticketsPrice.push_back(priceValue);
                   }
               }
               result.insert("seatsCount", seatsCount);
               result.insert("minPrice", minPrice);
               result.insert("currency", currency);
               result.insert("prices", ticketsPrice);

               m_tickets.append(new DataModel(result));
           }
        }
    }
//    for(auto i : m_tickets)
//    {qDebug().noquote() << "Result" << i->data();}
    emit ticketsModelChanged(m_tickets);
}

StationInfo::StationInfo(const QJsonObject value)
{
    if (value.contains("id") && value.contains("value"))
    {
        m_id = value.value("id").toString();
        m_name = value.value("value").toString();

        emit idChanged(m_id);
        emit nameChanged(m_name);
    }
}

DataModel::DataModel(const QJsonObject value)
{
    m_obj = value;

    emit dataChanged(m_obj);
}
