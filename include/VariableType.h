#pragma once
#include <QAbstractListModel>
#include <qnetworkaccessmanager.h>
#include <QJsonObject>
#include <QJsonArray>
#include <iostream>

using namespace::std;

class VariableType : public QAbstractListModel {
    Q_OBJECT
        
public:
    enum Type_Role { //定义数据的角色
        IdRole = Qt::UserRole + 1, //UserRole表示合法位置的起始位置
        NameRole,
        UnitRole,
        DefaultValueRole,
        MinRole,
        MaxRole
    };
     
    Q_ENUM(Type_Role)

    explicit VariableType(QObject* parent = nullptr) : QAbstractListModel(parent) {}
    ~VariableType(){}

    inline int rowCount(const QModelIndex& parent = QModelIndex()) const override {
        return varTypes.size();
    }
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;

    VariableType(const VariableType& tmd);

    inline VariableType& operator=(const VariableType& cao) {
        return const_cast<VariableType&>(cao);
    }

protected:
    QHash<int, QByteArray> roleNames() const override;

public slots:
    //对数据的基本操作
    //初始化数据
    Q_INVOKABLE void setVariable(const QJsonArray& vars); 
    //添加数据
    Q_INVOKABLE inline void appendType(QJsonObject vars) {
        beginInsertRows(QModelIndex(), varTypes.size(), varTypes.size());
        varTypes.append(vars);
        endInsertRows();
    }
    //移除数据
    Q_INVOKABLE void removeVariable(int index) {
        if (index < 0 || index > rowCount())return;
        beginRemoveRows(QModelIndex(), index, index);
        varTypes.removeAt(index);
        endRemoveRows();	
    }
    Q_INVOKABLE void saveTypes(QUrl path);
    Q_INVOKABLE void loadTypes(QUrl path);
    Q_INVOKABLE void loadTypesFromDataBase();
    Q_INVOKABLE inline void editType(QJsonObject Obj, int index) {
        varTypes[index] = Obj;
    }
    Q_INVOKABLE QString getType(int index, int role);
    Q_INVOKABLE int getIdByType(QString type);
    Q_INVOKABLE QJsonArray saveTypes();

private:
    QList<QJsonObject> varTypes;
    QList<int> m_idList;

    QNetworkAccessManager manager;

    static QList<QJsonObject> standarType;
};
