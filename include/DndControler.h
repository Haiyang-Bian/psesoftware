#pragma once
#define MARGINS 20
#define MINSTEP 20

#include <QObject>
#include <qjsonobject.h>
#include <qjsonarray.h>
#include <iostream>

using namespace::std;

struct Point
{
	int x = 0;
	int y = 0;

	QJsonObject pointToJson() const {
		return QJsonObject{
			{"X", x},
			{"Y", y}
		};
	}
};

inline bool operator<(const Point& p1, const Point& p2) {
	return p1.x < p2.x && p1.y < p2.y;
}
inline bool operator==(const Point& p1, const Point& p2) {
	return p1.x == p2.x && p1.y == p2.y;
}
inline Point operator+(const Point& p1, const Point& p2) {
	return Point{ p1.x + p2.x, p1.y + p2.y };
}
inline Point operator-(const Point& p1, const Point& p2) {
	return Point{ p1.x - p2.x, p1.y - p2.y };
}
inline Point operator*(const Point& p1, const Point& p2) {
	return Point{ p1.x * p2.x, p1.y * p2.y };
}
inline Point operator/(const Point& p1, int c) {
	return Point{ p1.x / c, p1.y / c };
}
inline bool isParallel(const Point& p1, const Point& p2) {
	return p1.x == p2.x || p1.y == p2.y;
}

struct Margins
{
	int Top;
	int Left;
	int Right;
	int Bottom;
	inline Point Core() {
		return Point{ (Left + Right) / 2, (Top + Bottom) / 2 };
	}
};

struct Handle
{
	int type = 1;
	int offset = 0;
	int width = 20;
	int height = 20;
	bool isConnected = false;
	Handle() {}
	Handle(const QJsonObject& h) {
		auto p = h.value("Position");
		if (p.isString())
			this->type = p.toString().toInt();
		else
			this->type = p.toInt();
		auto o = h.value("Offset");
		if (o.isString())
			this->offset = o.toString().toInt();
		else
			this->offset = o.toInt();
		if (h.contains(QLatin1String("IsConnected")))
			this->isConnected = h.value(QLatin1String("IsConnected")).toBool();
		if (h.contains(QLatin1String("Width")))
			this->width = h.value(QLatin1String("Width")).toInt();
		if (h.contains(QLatin1String("Height")))
			this->height = h.value(QLatin1String("Height")).toInt();
	}

	QJsonObject handleToJson() const {
		return QJsonObject{
			{"Position", type},
			{"Offset", offset},
			{"Width", width},
			{"Height", height},
			{"IsConnected", isConnected}
		};
	}
};

class DndNode
{
public:
	DndNode() {};
	inline DndNode(int x, int y, QString type) {
		this->x = x;
		this->y = y;
		this->type = type;
	}
	DndNode(const QJsonObject& node) {
		x = node.value("X").toInt();
		y = node.value("Y").toInt();
		width = node.value("Width").toInt();
		height = node.value("Height").toInt();
		type = node.value("Type").toString();
		data = node.value("Data").toObject();
		isCustom = node.value("isCustom").toBool();
		QJsonObject&& hs = node.value("Handles").toObject();
		for (QString h : hs.keys()) {
			handlers.insert(h, hs[h].toObject());
		}
	}
	~DndNode() {};

	inline Margins getNodeMargin() const {
		return Margins{
			y - MARGINS,
			x - MARGINS,
			x + MARGINS + width,
			y + MARGINS + height
		};
	}

	Point absolutePosition(QString h) const {
		const Handle& handle = handlers.value(h);
		switch (handle.type)
		{
		case 1:
			return Point{ this->x + handle.offset, this->y };
		case 2:
			return Point{ this->x + width, this->y + handle.offset };
		case 3:
			return Point{ this->x + handle.offset, y + height };
		case 4:
			return Point{ x, y + handle.offset };
		}
		return Point{};
	}

	Point relativePoint(QString h) const {
		const Handle& handle = handlers.value(h);
		const Point p = absolutePosition(h);
		switch (handle.type)
		{
		case 1:
			return p - Point{ 0, MARGINS };
		case 2:
			return p + Point{ MARGINS, 0 };
		case 3:
			return p + Point{ 0, MARGINS };
		case 4:
			return p - Point{ MARGINS, 0 };
		}
		return Point{};
	}

	QJsonObject nodeToJson() const {
		QJsonObject node{
			{"X",x},
			{"Y",y},
			{"Width",width},
			{"Height",height},
			{"Type",type},
			{"Data",data},
			{"isCustom",isCustom}
		};
		QJsonObject hs;
		QMap<QString, Handle>::const_iterator it;
		for (it = handlers.begin(); it != handlers.end(); ++it) {
			hs.insert(it.key(), it->handleToJson());
		}
		node.insert("Handles", hs);
		return node;
	}

public:
	int x = 0;
	int y = 0;
	int width = 80;
	int height = 80;
	bool isCustom = false;
	QString type;
	QJsonObject data;
	QMap<QString, Handle> handlers;
};

inline bool PointCover(const Point& p, const Margins& m) {
	if (p.x < m.Right - 5 && p.x > m.Left + 5 && p.y < m.Bottom - 5 && p.y > m.Top + 5)
		return true;
	else
		return false;
}

Point realSartOrEnd(QString n, QString h, const QMap<QString, DndNode>& nodes);

class PathNode
{
public:
	PathNode() {}
	~PathNode() {}

	PathNode(Point p) {
		this->p = p;
	}
	PathNode(Point p, int cost) {
		this->p = p;
		this->cost = cost;
	}

	Point p;
	int gCost = 0;
	int hCost = 0;
	int cost = 0;
	PathNode* parent = nullptr;
};

class AStar
{
public:
	AStar(Point rs, Point s, Point e) {
		this->realStart = rs;
		this->startPoint = new PathNode{ s };
		openList.append(this->startPoint);
		this->endPoint = e;
	};
	~AStar() {};

	Point realStart;
	QList<PathNode*> openList;
	QList<PathNode*> closeList;
	Point endPoint;
	PathNode* startPoint = nullptr;
	PathNode* node = nullptr;

public:
	PathNode* getBestNode();
	PathNode* getNode(Point p);
	QList<Point> getNextPoints(Point p);
	void findPath(const QMap<QString, DndNode>& nodes);
	inline bool isInList(Point p, QList<PathNode*> list);
	bool isInvalid(Point p, const QMap<QString, DndNode>& nodes);

	inline int gCost(PathNode* n) {
		return n->parent->gCost + 1;
	}
	inline int hCost(PathNode* n) {
		Point cost = n->p - endPoint;
		return abs(cost.x) + abs(cost.y);
	}
};

class DndEdge
{
public:
	DndEdge() {};
	~DndEdge() {};
	DndEdge(const QJsonObject& edge) {
		source = edge.value("Source").toString();
		sourceHandler = edge.value("SourceHandler").toString();
		target = edge.value("Target").toString();
		targetHandler = edge.value("TargetHandler").toString();
		for (auto&& p : edge.value("Path").toArray()) {
			path.append(Point{
				p.toObject().value("X").toInt(),
				p.toObject().value("Y").toInt()
				});
		}
	};

	QJsonArray getEdge();

	QJsonObject edgeToJson() const {
		QJsonObject edge{
			{"Source", source},
			{"SourceHandler", sourceHandler},
			{"Target", target},
			{"TargetHandler", targetHandler}
		};
		QJsonArray ps;
		for (const Point p : path) {
			ps.append(p.pointToJson());
		}
		edge.insert("Path", ps);
		return edge;
	}

public:
	QString source;
	QString target;
	QString sourceHandler;
	QString targetHandler;
	QList<Point> path;
};

class DndControler : public QObject
{
	Q_OBJECT

public:
	DndControler(QObject* parent = nullptr) : QObject(parent) {}
	DndControler(const QJsonObject& dnd, QObject* parent = nullptr) : QObject(parent) {
		QJsonObject&& nodes = dnd.value("ComponentList").toObject();
		for (QString node : nodes.keys()) {
			getNode.insert(node, nodes.value(node).toObject());
		}
		QJsonArray&& edges = dnd.value("ConnectionList").toArray();
		QJsonArray::const_iterator it;
		for (it = edges.begin(); it != edges.end(); ++it) {
			QJsonObject e = it->toObject();
			getEdge.insert(e.value("Name").toString(), e);
		}
	}

	DndControler(const DndControler& tmd) {
		this->getEdge = tmd.getEdge;
		this->getNode = tmd.getNode;
		this->sysInfo = tmd.sysInfo;
	}
	DndControler& operator =(const DndControler& cao) {
		return const_cast<DndControler&>(cao);
	}
	~DndControler() {}

	// 对组件的编辑
	Q_INVOKABLE void createNode(QJsonObject obj);
	Q_INVOKABLE void setNode(QString name, QJsonObject obj);
	Q_INVOKABLE void removeNode(QString name);
	Q_INVOKABLE QJsonArray moveNode(QString name, int x, int y);
	Q_INVOKABLE void moveNodeEnd(QString name, int x, int y);
	Q_INVOKABLE QVariantList getPosition(QString s, QString sh);
	Q_INVOKABLE void resizeNode(QString name, int x, int y, int width, int height);
	Q_INVOKABLE QJsonArray getNodes();

	// 对连接线的编辑
	Q_INVOKABLE void creatEdge(QJsonObject obj);
	Q_INVOKABLE QString getEdgeId(int x, int y) {
		QMap<QString, DndEdge>::const_iterator it;
		for (it = getEdge.begin(); it != getEdge.end(); ++it) {
			for (int i = 0; i + 1 < it->path.size(); ++i) {
				const Point& p1 = it->path.at(i), & p2 = it->path.at(i + 1);
				if (p1.x == p2.x) {
					if (min(p1.y, p2.y) < y && y < max(p1.y, p2.y) && abs(x - p1.x) < 3)
						return it.key();
				}
				else if (p1.y == p2.y)
				{
					if (min(p1.x, p2.x) < x && x < max(p1.x, p2.x) && abs(y - p1.y) < 3)
						return it.key();
				}
			}
		}
		return "";
	}

	Q_INVOKABLE void removeEdge(QString id) {
		getEdge.remove(id);
	}
	Q_INVOKABLE QJsonArray getEdges();
	// 解算路径
	QList<Point> generatePath(QString s, QString sh, QString t, QString th);
	// 返回系统信息
	bool hasNodes() {
		return !getNode.isEmpty();
	}

	QJsonObject systemData() const {
		QJsonObject nodes;
		QMap<QString, DndNode>::const_iterator node;
		for (node = getNode.begin(); node != getNode.end(); ++node) {
			nodes.insert(node.key(), node->nodeToJson());
		}
		QJsonArray edges;
		QMap<QString, DndEdge>::const_iterator edge;
		for (edge = getEdge.begin(); edge != getEdge.end(); ++edge) {
			QJsonObject e = edge->edgeToJson();
			e.insert("Name", edge.key());
			edges.append(e);
		}
		return QJsonObject{
			{"ComponentList", nodes},
			{"ConnectionList", edges}
		};
	}

signals:
	void moveEnd();
	void rmNode();

private:
	QMap<QString, DndNode> getNode;
	QMap<QString, DndEdge> getEdge;
public:
	QJsonObject sysInfo;
};
