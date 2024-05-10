#pragma once
#include <QAbstractItemModel>
#include <qqml.h>
#include <QDomDocument>
#include "DndControler.h"

//自定义树节点
struct  Model
{
    //节点属性
    QString name;
    QJsonObject data;
    DndControler dnd;
    bool isFilter = true;
    //节点位置
    int row = 0;
    //父节点
    Model* parentItem = nullptr;
    //子节点列表
    QList<Model*> subItems;

    Model* isSon(QString name) {
        for (Model* m : subItems) {
            if (m->name == name)
                return m;
        }
        return nullptr;
    }
};

class ModelList : public QAbstractItemModel
{
    Q_OBJECT
        QML_ELEMENT
private:
    enum RoleType
    {
        NameRole = Qt::UserRole,
        TypeRole
    };
public:
    explicit ModelList(QObject* parent = nullptr);
    ~ModelList() {}
    ModelList(const ModelList& tmd) {
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
    inline ModelList& operator=(const ModelList& cao) {
        return const_cast<ModelList&>(cao);
    }

    //初始化数据
    Q_INVOKABLE void resetItems();
    Q_INVOKABLE void createItem(QModelIndex order, bool isFilter, QString name = "");
    Q_INVOKABLE void removeItem(QModelIndex order);
    Q_INVOKABLE void moveItem(QModelIndex order, QModelIndex target);
    Q_INVOKABLE void createLib(QString name);
    Q_INVOKABLE void changeName(QModelIndex obj, QString name);

public:
    Q_INVOKABLE inline void rename(QModelIndex index, QString name) {
        Model* model = type(index);
        model->name = name;
    }

    Q_INVOKABLE inline  Model* type(QModelIndex idx) {
        if (idx.isValid()) {
            Model* item = static_cast<Model*>(idx.internalPointer());
            if (item) {
                return item;
            }
        }
        return nullptr;
    }

    Q_INVOKABLE inline QString getName(QModelIndex idx) {
        Model* model = type(idx);
        return model->name;
    }

    Q_INVOKABLE inline QString getIcon(QModelIndex idx) {
        Model* model = type(idx);
        QString icon = model->data["Icon"].toString();
        if (icon == "")
            return "";
        return QString("data:image/png;base64,%1").arg(icon);
    }
    Q_INVOKABLE QJsonArray getData(QModelIndex idx, QString t);
    Q_INVOKABLE inline QString getEqsOrDes(QModelIndex idx, QString t) {
        return type(idx)->data.value(t).toString();
    }

    Q_INVOKABLE void editIcon(QModelIndex idx, QUrl path);

    Q_INVOKABLE void editPort(QModelIndex idx, QJsonObject data);

    Q_INVOKABLE void editData(QModelIndex idx, QJsonObject data, QString t);
    Q_INVOKABLE void editDatas(QModelIndex idx, QJsonArray data, QString t);

    Q_INVOKABLE void editPorts(QModelIndex idx, QJsonArray data);

    Q_INVOKABLE inline DndControler* editSubSystem(QModelIndex idx) {
        return &(type(idx)->dnd);
    }

    Q_INVOKABLE inline void editDescription(QModelIndex idx, QString des) {
        Model* model = type(idx);
        model->data["Description"] = des;
    }

    Q_INVOKABLE inline void editMedia(QModelIndex idx, const QJsonObject& data) {
        Model* model = type(idx);
        QString name = data.value("Name").toString();
        model->data["Medias"].toObject().insert(name, data[name]);
    }

    Q_INVOKABLE inline void editMedias(QModelIndex idx, const QJsonArray& data) {
        Model* model = type(idx);
        for (auto m : data) {
            editMedia(idx, m.toObject());
        }
    }

    Q_INVOKABLE inline void editEquations(QModelIndex idx, QString eqs) {
        Model* model = type(idx);
        model->data["Equations"] = eqs;
    }

    void getModelsJson(Model* model, QJsonArray& data) {
        if (model->subItems.isEmpty()) {
            Model* m = model;
            QStringList name;
            while (m != rootItem)
            {
                name.push_front(m->name);
                m = m->parentItem;
            }
            QString typeName = name.join("_");
            QJsonObject modelData = model->data;
            modelData.insert("Type", typeName);
            modelData.insert("SubSystems", model->dnd.systemData());
            data.append(modelData);
        }
        else
        {
            for (Model* m : model->subItems) {
                getModelsJson(m, data);
            }
        }
    }

    void getModelsXml(Model* model, QDomDocument& models) {
        if (model->subItems.isEmpty()) {
            Model* m = model;
            QStringList name;
            while (m != rootItem)
            {
                name.append(m->name);
                m = m->parentItem;
            }
            QString typeName = name.join("_");
            QJsonObject modelData = model->data;
            modelData.insert("Type", typeName);
            //data.append(modelData);
        }
        else
        {
            for (Model* m : model->subItems) {
                //getModelsJson(m, data);
            }
        }
    }

    inline QJsonArray saveModels() {
        QJsonArray data;
        getModelsJson(rootItem, data);
        return data;
    }

    void loadModels(const QJsonArray& models) {
        for (auto m : models) {
            QJsonObject model = m.toObject();
            QStringList name = model.value("Type").toString().split("_");
            Model* mp = rootItem;
            while (!name.isEmpty())
            {
                QString typeName = name.takeFirst();
                Model* s = mp->isSon(typeName);
                if (s == nullptr) {
                    Model* n = new Model{};
                    n->name = typeName;
                    n->parentItem = mp;
                    mp->subItems.append(n);
                    if (name.isEmpty()) {
                        n->data = model;
                        n->dnd = model.value("SubSystems").toObject();
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
        }
    }

    // 数据库交互函数
    Q_INVOKABLE void insertDB(QVariant dataBase);

private:
     Model* getItem(const QModelIndex& idx) const;

private:
    //根节点
     Model* rootItem;
};

