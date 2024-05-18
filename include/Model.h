#pragma once
#include <QAbstractItemModel>
#include <qqml.h>
#include <QDomDocument>
#include <qqmlengine.h>
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
    bool setData(const QModelIndex& index, const QVariant& value, int role = Qt::EditRole) override {
        Model* item = getItem(index);
        if (!item)
            return false;
        item->name = value.toString();
        QList<int> roles{ NameRole };
        emit dataChanged(index, index, roles);
        return true;
    }
    
    Q_INVOKABLE void resetItems();
    Q_INVOKABLE void createItem(QModelIndex order, bool isFilter, QString name = "");
    Q_INVOKABLE void removeItem(QModelIndex order);
    Q_INVOKABLE void moveItem(QModelIndex order, QModelIndex target);
    Q_INVOKABLE void createLib(QString name);

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

    Q_INVOKABLE void rnameData(QModelIndex idx, QString name, QString newName, QString t);

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
            if (model->dnd.hasNodes())
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

    void getDndModel(Model* model, QJsonArray& data) {
        if (model->subItems.isEmpty()) {
            Model* m = model;
            QStringList name;
            while (m != rootItem)
            {
                name.push_front(m->name);
                m = m->parentItem;
            }
            QString typeName = name.join("_");
            QJsonObject modelData;
            modelData.insert("Type", typeName);
            QJsonObject ports = model->data.value("Ports").toObject();
            QJsonObject::iterator it;
            QJsonArray handlers;
            for (it = ports.begin(); it != ports.end(); ++it) {
                handlers.append(QJsonObject{
                    {"Name",it.key()},
                    {"Position",it->toObject().value("Position")},
                    {"Offset",it->toObject().value("Offset")},
                    });
            }
            modelData.insert("Handlers", handlers);
            modelData.insert("Icon", QString("data:image/png;base64,%1").arg(
                model->data.value("Icon").toString()
            ));
            modelData.insert("Description", model->data.value("Description").toString());
            QJsonArray paras, sparas;
            QJsonObject p = model->data.value("Parameters").toObject();
            for (it = p.begin(); it != p.end(); ++it) {
                QJsonObject pp = it->toObject();
                if (!pp.value("Value").isString()) {
                    paras.append(QJsonObject{
                        {"Name", it.key()},
                        {"Gui", pp.value("Gui").toString()}
                        });
                }
            }
            QJsonObject sp = model->data.value("StructuralParameters").toObject();
            for (it = sp.begin(); it != sp.end(); ++it) {
                QJsonObject pp = it->toObject();
                if (!pp.value("Value").isString()) {
                    sparas.append(QJsonObject{
                        {"Name", it.key()},
                        {"Gui", pp.value("Gui").toString()}
                        });
                }
            }
            if (!paras.isEmpty())
                modelData.insert("Paras", paras);
            if (!sparas.isEmpty())
                modelData.insert("SParas", sparas);
            data.append(modelData);
        }
        else
        {
            for (Model* m : model->subItems) {
                getDndModel(m, data);
            }
        }
    }

    QJsonArray getDndModels(QString name) {
        QJsonArray data;
        for (Model* lib : rootItem->subItems) {
            if (name == lib->name) {
                getDndModel(lib, data);
                break;
            }
        }
        return data;
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
                    n->row = mp->subItems.size();
                    mp->subItems.append(n);
                    if (name.isEmpty()) {
                        n->data = model;
                        n->isFilter = false;
                        if (model.contains("SubSystems"))
                            n->dnd = model.value("SubSystems").toObject();
                        QQmlEngine::setObjectOwnership(&(n->dnd), QQmlEngine::CppOwnership);
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

    QStringList getLibs() {
        QStringList libs;
        qDebug() << rootItem->subItems.size();
        for (Model* lib : rootItem->subItems) {
            libs.append(lib->name);
        }
        return libs;
    }

    // 数据库交互函数
    Q_INVOKABLE void insertDB(QVariant dataBase);

private:
     Model* getItem(const QModelIndex& idx) const;

private:
    //根节点
     Model* rootItem;
};
