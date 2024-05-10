#pragma once
#include <QAbstractListModel>
#include <QJsonObject>
#include <QJsonArray>
#include "Variable.h"

class ConnectionType : public QAbstractListModel
{
    Q_OBJECT
public:
    enum Role { //定义数据的角色
        IdRole = Qt::UserRole + 1, //UserRole表示合法位置的起始位置
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
    Q_INVOKABLE void insertDB(QVariant dataBase, QString name);
    Q_INVOKABLE void loadConnsFromDB(QVariant dataBase, QVariantList libs);

signals:
    void updateList();
private:
    //以下是数据源
    QList<int> idList;
    QList<QString> typeList;
    QList<Variable> variableList;
    QList<QString> descriptionList;
};
