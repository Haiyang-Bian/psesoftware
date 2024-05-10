#include "../include/MetaData.h"


MetaData::MetaData(QString vname, QString vtype,
	QString vunit,
	double vvalue,
	tuple<QString, QString> vbound,
	QString vconnect,
	QString vdescription
) {
	name = vname;
	type = vtype;
	unit = vunit;
	value = vvalue;
	bound = vbound;
	connect = vconnect;
	number = 1;
	description = vdescription;
}

MetaData::MetaData(QJsonObject obj) {
	this->name = obj.value(QLatin1String("Name")).toString();
	this->type = obj.value(QLatin1String("Type")).toString();
	this->unit = obj.value(QLatin1String("Unit")).toString();
	QJsonValue val = obj.value(QLatin1String("Value"));
	// 如果jsonvalue是string那么就会得到0
	if (val.isString())
		this->value = val.toString().toDouble();
	else
	{
		this->value = val.toDouble();
	}
	QString min = obj.value(QLatin1String("Min")).toString();
	QString max = obj.value(QLatin1String("Max")).toString();
	this->bound = tuple<QString, QString>(min, max);
	this->connect = obj.value(QLatin1String("Connect")).toString();
	this->description = obj.value(QLatin1String("Description")).toString();
	this->number = 1;
	QString gui = obj.value(QLatin1String("Gui")).toString();
	if (gui != "")
		guiMetaData = gui;
}