#pragma once
#include <QAbstractListModel>
#include <QJsonObject>
#include <QJsonArray>
#include <QNetworkAccessManager>

class Port
{
public:
    Port(){}
    Port(QJsonObject& p) {
        des = p.value("Description").toString();
        QJsonObject vars = p.value("Variables").toObject();
        for (QString v : vars.keys()) {
            QJsonObject var = vars.value(v).toObject();
            this->vars.insert(v, var);
        }
    }

    
    QJsonObject getPort() {
        QJsonObject vars;
        QMap<QString, QJsonObject>::iterator it;
        for (it = this->vars.begin(); it != this->vars.end(); ++it) {
            vars.insert(it.key(), it.value());
        }
        return QJsonObject{
            {"Variables", vars},
            {"Description", des}
        };
    }

public:
    QMap<QString, QJsonObject> vars;
    QString des;
};

class ConnectionType : public QAbstractListModel
{
    Q_OBJECT
public:
    enum Role {
        TypeRole = Qt::UserRole + 1,
        DescriptionRole
    };

    Q_ENUM(Role)

        explicit ConnectionType(QObject* parent = nullptr);
    ConnectionType(const ConnectionType& tmd);
    ConnectionType& operator=(const ConnectionType& cao);
    ~ConnectionType();

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;

    QModelIndex index(int row, int column = 0, const QModelIndex& parent = QModelIndex()) const override {
        return createIndex(row, column);
    }
protected:
    QHash<int, QByteArray> roleNames() const override;

public slots:

    Q_INVOKABLE void rename(int index, QString newName) {
        QString name = typeList.value(index);
        Port old = portList.value(name);
        portList.remove(name);
        portList.insert(newName, old);
        typeList[index] = newName;
        emit dataChanged(this->index(index), this->index(index));
    }
    
    Q_INVOKABLE inline void removeType(QString name) {
        typeList.removeAt(typeList.indexOf(name));
        portList.remove(name);
    }
    Q_INVOKABLE void editType(QJsonObject obj) {
        QString name = obj.value("Type").toString();
        if (portList.contains(name))
        {
            if (obj.keys().size() == 1) {
                int n = typeList.indexOf(name);
                beginRemoveRows(QModelIndex(), n, n);
                portList.remove(name);
                typeList.removeAt(typeList.indexOf(name));
                endRemoveRows();
            }
        }
        else
        {
            beginInsertRows(QModelIndex(), typeList.size(), typeList.size());
            typeList.append(name);
            portList.insert(name, obj);
            endInsertRows();
        }
    }
    Q_INVOKABLE QJsonArray getTypes();
    Q_INVOKABLE inline void rename(QString name, QString newName) {
        portList.insert(newName, portList.value(name));
        portList.remove(name);
        int i = typeList.indexOf(name);
        typeList[i] = newName;
    }
    Q_INVOKABLE inline void renameVar(QString conn, QString name, QString newName) {
        Port& p = portList[conn];
        p.vars.insert(newName, p.vars.value(name));
        p.vars.remove(name);
    }
    void loadTypes(const QJsonArray& ports) {
        for (auto p : ports) {
            QJsonObject port = p.toObject();
            QString type = port.value("Type").toString();
            typeList.append(type);
            portList.insert(type, port);
        }
    }
    Q_INVOKABLE void editPortVar(QString conn, QJsonObject data) {
        QString name = data.value("Name").toString();
        Port& p = portList[conn];
        if (p.vars.contains(name)) {
            if (data.keys().size() == 1) {
                p.vars.remove(name);
            }
            else
            {
                if (data.contains("Type")) {
                    p.vars[name].insert("Type", data["Type"]);
                }
                else if(data.contains("ConnectType"))
                {
                    p.vars[name].insert("ConnectType", data["ConnectType"]);
                }
            }
        }
        else
        {
            p.vars.insert(name, data);
        }
    }
    Q_INVOKABLE inline QString getVarType(QString conn, QString name) {
        return portList.value(conn).vars.value(name).value("Type").toString();
    }
    Q_INVOKABLE inline QJsonArray getVarTypes(QString conn) {
        qDebug() << conn;
        QJsonArray arr;
        const Port& port = portList.value(conn);
        QMap<QString, QJsonObject>::const_iterator it;
        for (it = port.vars.begin(); it != port.vars.end(); ++it) {
            arr.append(*it);
        }
        return arr;
    }
    Q_INVOKABLE inline QList<QString> getTypeList() {
        return typeList;
    }
    // 数据库交互函数
    Q_INVOKABLE void insertDB();
    Q_INVOKABLE void loadConnsFromDB();

signals:
    void updateList();
private:
    QNetworkAccessManager manager;

    QStringList typeList;
    QMap<QString, Port> portList;

    static QJsonArray standardTypes;
};
