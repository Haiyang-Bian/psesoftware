#pragma once
#include <QAbstractListModel>
#include <QJsonObject>
#include <QJsonArray>
#include "MetaData.h"


class Variable : public QAbstractListModel
{
    Q_OBJECT
public:
    enum Variable_Role { //定义数据的角色
        IdRole = Qt::UserRole + 1, //UserRole表示合法位置的起始位置
        NameRole,
        TypeRole,
        UnitRole,
        ValueRole,
        ConnectRole,
        NumberRole,
        MinRole,
        MaxRole,
        DescriptionRole
    };

    Q_ENUM(Variable_Role)

        explicit Variable(QObject* parent = nullptr);
        Variable(const Variable& tmd);
    ~Variable(){}

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QJsonObject getVars() const;

    inline Variable& operator=(const Variable& cao) {
        return const_cast<Variable&>(cao);
    }

protected:
    QHash<int, QByteArray> roleNames() const override;

public slots:
    //对数据的基本操作
    //初始化数据
    Q_INVOKABLE void setVariable(QJsonArray vars); 
    Q_INVOKABLE void insertVariable(QJsonObject vars, int index); //添加数据
    //移除数据
    Q_INVOKABLE void removeVariable(int index); 
    Q_INVOKABLE void editVariable(QJsonObject Obj, int index) const;
    Q_INVOKABLE void appendVar(QJsonObject Obj);
    Q_INVOKABLE QString getVariable(int index, int role);

public:
    //以下是数据源
    bool isParameter;
    QList<int> idList;
    mutable QList<MetaData> metaDataList;
};
