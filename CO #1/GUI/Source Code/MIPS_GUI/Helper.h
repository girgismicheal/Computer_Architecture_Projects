#ifndef HELPER_H
#define HELPER_H

#include "codeviewer.h"


#include<QString>
#include<QFile>
#include<QMessageBox>
#include<QWidget>
#include<QTextStream>
#include<QProcess>

void writeInFile(QString path , QString content , QWidget* Parent);
void ShowCode(QString Content,QString Title);
void RunModelSim(QWidget* Patent);
QString readFromFile(QString path , QWidget* Parent);



#endif // HELPER_H
