#pragma once
#include <QAbstractItemModel>
#include <qnetworkaccessmanager.h>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <qurl.h>
#include <qurlquery.h>
#include <qqml.h>
#include <qjsonobject.h>
#include <qjsonarray.h>
#include <qjsondocument.h>
#include <QDomDocument>

//自定义树节点
struct LibModel
{
    //节点属性
    QString name;
    QJsonArray models;
    bool isFilter = true;
    //节点位置
    int row = 0;
    //父节点
    LibModel* parentItem = nullptr;
    //子节点列表
    QList<LibModel*> subItems;

    LibModel* isSon(QString name) {
        for (LibModel* m : subItems) {
            if (m->name == name)
                return m;
        }
        return nullptr;
    }
};

class LibTreeModel : public QAbstractItemModel
{
    Q_OBJECT
        QML_ELEMENT
private:
    enum RoleType
    {
        NameRole = Qt::UserRole,
        TypeRole,
        ModelsRole
    };
public:
    explicit LibTreeModel(QObject* parent = nullptr);
    ~LibTreeModel() {}
    LibTreeModel(const LibTreeModel& tmd) {
        this->rootItem = tmd.rootItem;
    }

    //需要重写的基类接口
    QModelIndex index(int row, int column,
        const QModelIndex& parent = QModelIndex()) const override;
    QModelIndex parent(const QModelIndex& index) const override;
    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    int columnCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;
    inline LibTreeModel& operator=(const LibTreeModel& cao) {
        return const_cast<LibTreeModel&>(cao);
    }

    Q_INVOKABLE void resetItems();

public:
    Q_INVOKABLE inline void rename(QModelIndex index, QString name) {
        LibModel* model = type(index);
        model->name = name;
    }

    Q_INVOKABLE inline  LibModel* type(QModelIndex idx) {
        if (idx.isValid()) {
            LibModel* item = static_cast<LibModel*>(idx.internalPointer());
            if (item) {
                return item;
            }
        }
        return nullptr;
    }

    void loadModels(const QJsonArray& models) {
        for (auto m : models) {
            QJsonObject model = m.toObject();
            QStringList name = model.value("Type").toString().split("_");
            name.pop_back();
            LibModel* mp = rootItem;
            while (!name.isEmpty())
            {
                QString typeName = name.takeFirst();
                LibModel* s = mp->isSon(typeName);
                if (s == nullptr) {
                    beginInsertRows(createIndex(mp->row, 0, mp), mp->subItems.size(), mp->subItems.size());
                    LibModel* n = new LibModel{};
                    n->name = typeName;
                    n->parentItem = mp;
                    n->row = mp->subItems.size();
                    mp->subItems.append(n);
                    endInsertRows();
                    if (name.isEmpty()) {
                        
                        break;
                    }
                    else
                    {
                        mp = n;
                    }
                }
                else
                {
                    mp = s;
                }
            }
            mp->models.append(model);
        }
    }

    void loadLibs(const QStringList& libs) {
        QUrl url("http://localhost:8080/models");
        for (QString lib : libs) {
            QUrlQuery query(url);
            query.addQueryItem("libName", lib);
            url.setQuery(query);
            QNetworkRequest request(url);
            QNetworkReply* reply = netWorker.get(request);
            connect(&netWorker, &QNetworkAccessManager::finished, this, [this, reply]() {
                if (reply->error()) {
                    qDebug() << "Error:" << reply->errorString();
                    return;
                }
                QJsonObject res = QJsonDocument::fromJson(reply->readAll()).object();
                QJsonArray arr = res.value("Models").toArray();
                this->loadModels(arr);
                reply->deleteLater();
                });
        }
    }

    void useLocalModels(const QJsonArray& models, QString name) {
        LibModel* local{ new LibModel };
        beginInsertRows(createIndex(0, 0, rootItem), rootItem->subItems.size(), rootItem->subItems.size());
        local->name = "LocalModels-" + name;
        local->parentItem = rootItem;
        local->row = rootItem->subItems.size();
        rootItem->subItems.append(local);
        endInsertRows();
        for (auto m : models) {
            QJsonObject model = m.toObject();
            QStringList name = model.value("Type").toString().split("_");
            name.pop_back();
            LibModel* mp = local;
            while (!name.isEmpty())
            {
                QString typeName = name.takeFirst();
                LibModel* s = mp->isSon(typeName);
                if (s == nullptr) {
                    beginInsertRows(createIndex(mp->row, 0, mp), mp->subItems.size(), mp->subItems.size());
                    LibModel* n = new LibModel{};
                    n->name = typeName;
                    n->parentItem = mp;
                    n->row = mp->subItems.size();
                    mp->subItems.append(n);
                    endInsertRows();
                    if (name.isEmpty()) {

                        break;
                    }
                    else
                    {
                        mp = n;
                    }
                }
                else
                {
                    mp = s;
                }
            }
            mp->models.append(model);
        }
    }

    void deleteNodes(LibModel* node) {
        for (LibModel* son : node->subItems) {
            son->parentItem = nullptr;
            deleteNodes(son);
        }
        delete node;
    }

    void deleteLibs(QString name) {
        int index = 0;
        for (int i = 0; i < rootItem->subItems.size(); ++i) {
            if (rootItem->subItems.at(i)->name == name) {
                index = i;
                break;
            }
        }
        deleteNodes(rootItem->subItems[index]);
        rootItem->subItems.removeAt(index);
    }

private:
    LibModel* getItem(const QModelIndex& idx) const;

private:
    //根节点
    LibModel* rootItem;

    QNetworkAccessManager netWorker;
};


