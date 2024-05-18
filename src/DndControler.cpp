#include <qjsonarray.h>
#include <algorithm>
#include <iostream>
#include "../include/DndControler.h"

using namespace std;

bool AStar::isInList(Point p, QList<PathNode*> list) {
	for (PathNode* pn : list) {
		if (pn->p == p)
			return true;
	}
	return false;
}

PathNode* AStar::getNode(Point p) {
	for (PathNode* n : openList) {
		if (n->p == p)
			return n;
	}
	return nullptr;
}

PathNode* AStar::getBestNode() {
	QList<PathNode*>::iterator it = openList.begin();
	PathNode* minP = *it;
	for (it += 1; it != openList.end(); ++it) {
		if (minP->cost > (*it)->cost)
			minP = *it;
	}
	QList<PathNode*> nodes;
	for (PathNode* p : openList) {
		if (p->cost == minP->cost)
			nodes.append(p);
	}
	for (PathNode* pn : nodes) {
		if (pn == startPoint)
			break;
		else if (pn->parent == startPoint)
		{
			if (isParallel(pn->p, pn->parent->p) && isParallel(pn->p, realStart))
				return pn;
		}
		else
		{
			if (isParallel(pn->p, pn->parent->p) && isParallel(pn->p, pn->parent->parent->p))
				return pn;
		}
	}
	return minP;
}

QList<Point> AStar::getNextPoints(Point p) {
	return QList<Point> {
		p - Point{ 0, MINSTEP },
			p + Point{ MINSTEP,0 },
			p + Point{ 0, MINSTEP },
			p - Point{ MINSTEP,0 }
	};
}

bool AStar::isInvalid(Point p, const QMap<QString, DndNode>& nodes) {
	QMap<QString, DndNode>::const_iterator it;
	for (it = nodes.begin(); it != nodes.end(); ++it) {
		if (PointCover(p, it->getNodeMargin()))
			return true;
	}
	return false;
}

void AStar::findPath(const QMap<QString, DndNode>& nodes) {
	while (!openList.isEmpty()) {
		PathNode* node = getBestNode();
		if (node->p == endPoint) {
			this->node = node;
			break;
		}
		else
		{
			int index = openList.indexOf(node);
			openList.removeAt(index);
			closeList.append(node);
			QList<Point> nexts = getNextPoints(node->p);
			for (Point p : nexts) {
				if (isInList(p, closeList)) {
					continue;
				}
				if (isInvalid(p, nodes)) {
					continue;
				}
				if (p.x < 0 || p.x > 800 || p.y < 0 || p.y > 750)
					continue;
				if (!isInList(p, openList)) {
					PathNode* next = new PathNode{ p };
					next->parent = node;
					next->gCost = gCost(next);
					next->hCost = hCost(next);
					next->cost = next->gCost + next->hCost;
					openList.append(next);
				}
				else
				{
					PathNode* pn = getNode(p);
					if (pn->gCost > node->gCost + 1)
					{
						pn->parent = node;
						pn->cost = gCost(pn) + hCost(pn);
					}
				}
			}
		}
	}
}

void DndControler::createNode(QJsonObject obj) {
	QString name = obj.value(QLatin1String("Name")).toString();
	DndNode node(obj.value(QLatin1String("X")).toInt(),
		obj.value(QLatin1String("Y")).toInt(),
		obj.value(QLatin1String("Type")).toString()
	);
	node.width = obj.value(QLatin1String("Width")).toInt();
	node.height = obj.value(QLatin1String("Height")).toInt();
	QJsonObject hs = obj.value(QLatin1String("Handlers")).toObject();
	QJsonObject::iterator it;
	for (it = hs.begin(); it != hs.end(); ++it) {
		QJsonObject h = it->toObject();
		node.handlers.insert(h.value(QLatin1String("Name")).toString(), h);
	}
	getNode.insert(name, node);
}

void DndControler::setNode(QString name, QJsonObject obj) {
	getNode[name].data = obj;
}

void DndControler::removeNode(QString name) {
	getNode.remove(name);
	QMap<QString, DndEdge>::iterator it;
	QList<QString> delEdges;
	for (it = getEdge.begin(); it != getEdge.end(); it++) {
		if (it->source == name) {
			delEdges << it.key();
			getNode[it->target].handlers[it->targetHandler].isConnected = false;
		}
		else if (it->target == name) {
			delEdges << it.key();
			getNode[it->source].handlers[it->sourceHandler].isConnected = false;
		}
	}
	for (QString i : delEdges) {
		getEdge.remove(i);
	}
	emit rmNode();
}

QJsonArray DndControler::moveNode(QString name, int x, int y) {
	const DndNode& node = getNode.value(name);
	QMap<QString, Handle>::const_iterator it;
	QJsonArray mc;
	for (it = node.handlers.begin(); it != node.handlers.end(); ++it) {
		if (it->isConnected) {
			Point start = node.absolutePosition(it.key());
			Point end = start + Point{ x - node.x,y - node.y };
			mc.append(QJsonObject{
				{"Start", QJsonArray{start.x, start.y}},
				{"End", QJsonArray{end.x, end.y}}
				});
		}
	}
	return mc;
}

void DndControler::moveNodeEnd(QString name, int x, int y) {
	DndNode& node = getNode[name];
	node.x = x;
	node.y = y;
	QMap<QString, DndEdge>::iterator it;
	for (it = getEdge.begin(); it != getEdge.end(); ++it) {
		if (it->source == name || it->target == name) {
			it->path = generatePath(it->source, it->sourceHandler, it->target, it->targetHandler);
		}
	}
	emit moveEnd();
}

void DndControler::creatEdge(QJsonObject obj) {
	QString id = obj.value("Id").toString();
	DndEdge edge;
	edge.source = obj.value("Source").toString();
	edge.sourceHandler = obj.value("SourceHandler").toString();
	edge.target = obj.value("Target").toString();
	edge.targetHandler = obj.value("TargetHandler").toString();
	edge.path = generatePath(edge.source, edge.sourceHandler, edge.target, edge.targetHandler);
	getEdge.insert(id, edge);
}

QVariantList DndControler::getPosition(QString s, QString sh) {
	QVariantList position;
	Point p = getNode.value(s).absolutePosition(sh);
	position << p.x << p.y;
	return position;
}

QJsonArray DndEdge::getEdge() {
	QJsonArray path;
	for (Point p : this->path)
		path.append(QJsonObject{ {"X",p.x},{"Y",p.y} });
	return path;
}

QJsonArray DndControler::getEdges() {
	QJsonArray paths;
	QMap<QString, DndEdge>::iterator it;
	for (it = getEdge.begin(); it != getEdge.end(); it++)
		paths.append(it->getEdge());
	return paths;
}

QList<Point> DndControler::generatePath(QString s, QString sh, QString t, QString th) {
	Point rs = realSartOrEnd(s, sh, getNode), rt = realSartOrEnd(t, th, getNode);
	AStar a(getNode.value(s).absolutePosition(sh), rs, rt);
	a.findPath(getNode);
	QList<Point> path;
	PathNode* node = a.node;
	while (node)
	{
		path.append(node->p);
		node = node->parent;
	}
	path.prepend(getNode.value(t).absolutePosition(th));
	path.append(a.realStart);
	int p = 1;
	while (p + 1 < path.size()) {
		if (isParallel(path.at(p-1), path.at(p + 1))) {
			path.removeAt(p);
		}
		else {
			p += 1;
		}
	}
	getNode[s].handlers[sh].isConnected = true;
	getNode[t].handlers[th].isConnected = true;
	return path;
}

Point realSartOrEnd(QString n, QString h, const QMap<QString, DndNode>& nodes) {
	const DndNode& p = nodes[n];
	return p.relativePoint(h);
}

void DndControler::resizeNode(QString name, int x, int y, int width, int height) {
	DndNode& node = getNode[name];
	node.x = x;
	node.y = y;
	node.width = width;
	node.height = height;
	QMap<QString, DndEdge>::iterator it;
	for (it = getEdge.begin(); it != getEdge.end(); ++it) {
		if (it->source == name || it->target == name) {
			it->path = generatePath(it->source, it->sourceHandler, it->target, it->targetHandler);
		}
	}
	emit moveEnd();
}

QJsonArray DndControler::getNodes()
{
	QJsonArray nodes;
	QMap<QString, DndNode>::const_iterator it;
	for (it = getNode.begin(); it != getNode.end(); ++it) {
		QJsonArray hs;
		QMap<QString, Handle>::const_iterator h;
		for (h = it->handlers.begin(); h != it->handlers.end(); ++h) {
			QJsonObject hh = h->handleToJson();
			hh.insert("Name", h.key());
			hs << hh;
		}
		QJsonObject node{
			{ "Name", it.key()},
			{ "X", it->x },
			{ "Y", it->y },
			{ "Width", it->width },
			{ "Height", it->height },
			{ "Type", it->type },
			{ "Handlers", hs }
		};
		nodes.append(node);
	}
	return nodes;
}
