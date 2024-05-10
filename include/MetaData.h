#pragma once
#include <QJsonObject>
#include <QJsonArray>
#include <iostream>

using namespace::std;

class MetaData
{
public:
	QString name;
	QString type;
	QString unit;
	double value;
	tuple<QString, QString> bound;
	int number;
	QString connect;
	QString description;
	QString guiMetaData = "";

	MetaData(QString vname, QString vtype,
		QString vunit = QString(""),
		double vvalue = 0.0,
		tuple<QString, QString> vbound = tuple<QString, QString> (QString ("-Inf"), QString ("Inf")),
		QString vconnect = QString("Equal"),
		QString vdescription = QString("")
	);
	MetaData() {
		name = QString("");
		type = QString("");
		unit = QString("");
		value = 0.0;
		number = 1;
		bound = tuple<QString, QString>(QString(""), QString(""));
		connect = QString("");
		description = QString("");
	}
	MetaData(QJsonObject obj);
};

