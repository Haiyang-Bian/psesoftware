#pragma once
#include <QAbstractListModel>
#include <QJsonObject>
#include <QJsonArray>
#include <QNetworkAccessManager>
#include "Variable.h"

class Port
{
public:
    Port(){}
    Port(QJsonObject& p) {
        des = p.value("Description").toString();
        for (auto v : p.value("Variables").toArray()) {
            QJsonObject var = v.toObject();
            vars.insert(var.value("Name").toString(), var);
        }
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
        IdRole = Qt::UserRole + 1,
        TypeRole,
        DescriptionRole
    };

    Q_ENUM(Role)

        explicit ConnectionType(QObject* parent = nullptr);
    ConnectionType(const ConnectionType& tmd);
    ConnectionType& operator=(const ConnectionType& cao);
    ~ConnectionType();

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
protected:
    QHash<int, QByteArray> roleNames() const override;

public slots:
    //对数据的基本操作
    Q_INVOKABLE void setConnectionType(); //初始化数据
    Q_INVOKABLE void appendType(const QJsonObject& obj); //添加数据
    Q_INVOKABLE void removeType(int index); //移除数据
    Q_INVOKABLE void editType(const QJsonObject Obj, int c_index, int index);
    Q_INVOKABLE QJsonArray getTypes();
    void loadTypes(const QJsonArray& ports) {
        for (auto p : ports) {
            QJsonObject port = p.toObject();
            this->appendType(port);
        }
    }
    // 此函数用于插入端口的变量(一条一条插入)
    Q_INVOKABLE void createConnectionVar(const QJsonObject& Var, int index);
    Q_INVOKABLE void removeConnectionVar(int c_index, int index);
    Q_INVOKABLE QString getVarType(int c_index, int index, int role);
    Q_INVOKABLE QList<QString> getTypeList();
    // 数据库交互函数
    Q_INVOKABLE void insertDB();
    Q_INVOKABLE void loadConnsFromDB();

signals:
    void updateList();
private:
    QNetworkAccessManager manager;
    //以下是数据源
    QList<int> idList;
    QList<QString> typeList;
    QList<Variable> variableList;
    QList<QString> descriptionList;
    //QMap<QString, Port> portList;

    static QJsonArray standardTypes;
};
