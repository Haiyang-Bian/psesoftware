#pragma once
#include <QAbstractItemModel>
#include <QSharedPointer>
#include <qqml.h>

//自定义树节点
struct MyTreeItem
{
    //节点属性
    QString name;

    //节点位置
    int row;
    //父节点
    QSharedPointer<MyTreeItem> parentItem;
    //子节点列表
    QList<QSharedPointer<MyTreeItem>> subItems;
};

//treeview数据model
class MyTreeModel : public QAbstractItemModel
{
    Q_OBJECT
        QML_ELEMENT
private:
    enum RoleType
    {
        NameRole = Qt::UserRole
    };
public:
    explicit MyTreeModel(QObject* parent = nullptr);

    //需要重写的基类接口
    QModelIndex index(int row, int column,
        const QModelIndex& parent = QModelIndex()) const override;
    QModelIndex parent(const QModelIndex& index) const override;
    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    int columnCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    //初始化数据
    Q_INVOKABLE void resetItems();
    Q_INVOKABLE void createItem(QString name = "");
    Q_INVOKABLE void viewItem(int index, int type, QString name);
    Q_INVOKABLE int projectNumber();


private:
    MyTreeItem* getItem(const QModelIndex& idx) const;

private:
    //根节点
    QSharedPointer<MyTreeItem> rootItem;
};
