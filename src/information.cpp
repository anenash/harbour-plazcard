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
            parseStationsList(arr);
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
        else if (result.object().value("data").isString())
        {
            QString str = result.object().value("data").toString();
            QByteArray arr = str.toUtf8();
            if(m_suburbanSearch)
            {
                parseSuburbanTickets(arr);
            }
            else
            {
                parseTicketsList(arr);
            }
        }
    });

    connect(&m_manager, &NetworkManger::redirectUrl, [=](const QUrl &url)
    {
        qDebug() << "redirectUrl" << m_suburbanSearch;
        if(m_suburbanSearch)
        {
            qDebug() << "redirectUrl" << url;
            m_manager.performRequest(RequestType::Get, url);
        }
    });
}

void Information::setSearchType(const bool value)
{
    m_suburbanSearch = value;
}

void Information::getStations(const QString &name)
{
    //https://www.tutu.ru/suggest/railway_simple/?name=
    QUrl url;
    if(m_suburbanSearch)
    {
        url = "https://www.tutu.ru/station/suggest.php?name=" + QUrl::toPercentEncoding(name);
    }
    else
    {
        url = "https://www.tutu.ru/suggest/railway_simple/?name=" + name;
    }
    m_manager.performRequest(RequestType::Get, url);
}

void Information::getTickets(const QString &link)
{
    QUrl url = link;
    qDebug() << "URL" << url;
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

void Information::parseStationsList(const QJsonValue &arr)
{

//                qDebug().noquote() << "Arr" << arr;
    for (auto object : arr.toArray() )
    {
        QJsonObject obj = object.toObject();
        if (!m_suburbanSearch && obj.contains("id") && obj.contains("value"))
        {
            m_stations.append(new StationInfo(obj));
        }
        else if (m_suburbanSearch && obj.contains("value") && obj.contains("label"))
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

//    qDebug().noquote() << "Regexp\n" << arr;

    QJsonDocument allData = QJsonDocument::fromJson(arr);


    QJsonObject root = allData.object();

    QJsonArray searchResultList = root.value("componentData").toObject().value("searchResultList").toArray();
    if (searchResultList.isEmpty())
    {
        emit noTicketsFound();
        return;
    }
    QJsonObject references = root.value("references").toObject();

    auto station = [=](const QJsonObject& list, const QString& key, QString& city, QString& station) -> QString {
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
                city = cityName;
                station = stationName;
                return cityName + ", " + stationName;
            }
        }
    };
//    qDebug().noquote() << "references" << references;
//    qDebug().noquote() << "\n\n\ntickets" << tickets;
    for (auto searchItem : searchResultList)
    {
        QJsonArray tickets = searchItem.toObject().value("trains").toArray();
        m_roundTrip = !m_roundTrip;
        for(auto param : tickets)
        {
           if(param.toObject().value("type").toString() == "withSeats")
           {
               QJsonObject result;
               QJsonObject object = param.toObject();

               QJsonObject tripInfo = object.value("params").toObject().value("run").toObject();
               QJsonObject trip = object.value("params").toObject().value("trip").toObject();
               QJsonObject ticketsInfo = object.value("params").toObject().value("withSeats").toObject();

               result.insert("direction", m_roundTrip);
               result.insert("buyUrl", ticketsInfo.value("buyAbsUrl").toString());
               result.insert("trainNumber", tripInfo.value("number").toString());
               result.insert("trainName", tripInfo.value("name").toString());
               result.insert("isFirm", tripInfo.value("isFirm").toBool());
               result.insert("trainArrivalDateTime", trip.value("arrivalTimestamp").toInt());
               result.insert("trainDepartureDateTime", trip.value("departureTimestamp").toInt());
               result.insert("tripDuration", trip.value("travelTimeSeconds").toInt());
               result.insert("routeInfo", tripInfo.value("aboutTrainAjaxUrl").toString());

               QString arrStationName;
               QString arrCityName;
               QString arrStation = station(references, trip.value("arrivalStation").toString(), arrCityName, arrStationName);
               result.insert("arrStationName", arrStationName);
               result.insert("arrCityName", arrCityName);
               QString depStationName;
               QString depCityName;
               QString depStation = station(references, trip.value("departureStation").toString(), depCityName, depStationName);
               result.insert("depStationName", depStationName);
               result.insert("depCityName", depCityName);

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

void Information::parseSuburbanTickets(const QByteArray &result)
{
    QString s("window.params = ");
    QString s1("};");
    QString modelParams("window.modelParams = ");
    QString modelParams1("}}}]");
    QString ref("window.references = ");
    QString ref1("}]};");
//    QString ref1("window.");
//    int first = result.indexOf(s) + s.length();
//    int last = result.indexOf(s1, first) + s1.length() - 1;
    int first1 = result.indexOf(modelParams) + modelParams.length();
    int last1 = result.indexOf(modelParams1, first1) + modelParams1.length();
    int first2 = result.indexOf(ref) + ref.length();
    int last2 = result.indexOf(ref1, first2) + ref1.length() - 1;
//    QByteArray arr = result.mid(first, (last - first));
    QByteArray arr1 = result.mid(first1, (last1 - first1));
    QByteArray arr2 = result.mid(first2, (last2 - first2));

    qDebug().noquote() << "parseSuburbanTickets\n" << arr1 << "\n   references    \n" << arr2;
//    QJsonDocument allData = QJsonDocument::fromJson(arr);
    QJsonDocument modelParamsJson = QJsonDocument::fromJson(arr1);
    QJsonDocument references = QJsonDocument::fromJson(arr2);
    if (modelParamsJson.isEmpty() || references.isEmpty())
    {
        qDebug() << "modelParamsJson.isEmpty()" << modelParamsJson.isEmpty() << "references.isEmpty()" << references.isEmpty();
        emit noTicketsFound();
        return;
    }
//    qDebug().noquote() << "Params\n\n" << modelParamsJson << "\n\n" << references;

    auto getStationName = [&references](int key){
        QJsonArray stations = references.object().value("stations").toArray();
        for(auto station: stations)
        {
            if(station.toObject().value("code").toInt() == key)
            {
                return station.toObject().value("name").toString();
            }
        }
    };

    auto getWeekday = [&references](int key){
        QJsonArray weekSchedule = references.object().value("weekSchedule").toArray();
        for(auto item: weekSchedule)
        {
            if(item.toObject().value("code").toInt() == key)
            {
                return item.toObject().value("name").toString();
            }
        }
    };

    auto getTrainNum = [&references](const QString key){
        QJsonArray trains = references.object().value("trains").toArray();
        for(auto train: trains)
        {
            if(train.toObject().value("referenceCode").toString() == key)
            {
                return train.toObject().value("number").toString();
            }
        }
    };

    for(auto item: modelParamsJson.array())
    {
        QJsonObject result;
        QJsonObject trip = item.toObject().value("trip").toObject();

        result.insert("trainNum", getTrainNum(trip.value("trainCode").toString()));
        result.insert("days", getWeekday(trip.value("timeTable").toObject().value("weekTimeTable").toInt()));
        result.insert("departureStation", getStationName(trip.value("departureRouteStation").toObject().value("stationCode").toInt()));
        result.insert("departureTime", trip.value("departureRouteStation").toObject().value("departureDatetime").toString());
        result.insert("arrivalStation", getStationName(trip.value("arrivalRouteStation").toObject().value("stationCode").toInt()));
        result.insert("arrivalTime", trip.value("arrivalRouteStation").toObject().value("arrivalDatetime").toString());

        qDebug() << "Result\n" << result;

        m_tickets.append(new DataModel(result));
    }

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
    else if (value.contains("value") && value.contains("label"))
    {
        m_id = value.value("value").toString();
        m_name = value.value("label").toString();

        emit idChanged(m_id);
        emit nameChanged(m_name);
    }
}

DataModel::DataModel(const QJsonObject value)
{
    m_obj = value;

    emit dataChanged(m_obj);
}
