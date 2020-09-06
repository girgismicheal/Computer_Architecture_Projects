#ifndef MIPSGUIAPP_H
#define MIPSGUIAPP_H

#include <QMainWindow>
#include <QFile>
#include<QFileDialog>
#include <QMessageBox>
#include <QString>
#include <QTextStream>
#include <string>
using namespace std;

QT_BEGIN_NAMESPACE
namespace Ui { class MIPSGUIAPP; }
QT_END_NAMESPACE

class MIPSGUIAPP : public QMainWindow
{
    Q_OBJECT

public:
    MIPSGUIAPP(QWidget *parent = nullptr);
    ~MIPSGUIAPP();

private slots:
    void on_pushButton_clicked();

    void on_pushButton_2_clicked();

    void on_Simulator_clicked();

    void on_AutomatedTestButton_clicked();

private:
    Ui::MIPSGUIAPP *ui;
    const QString MachineCodeTitle = "Machine Code";
    const QString AssemblyCodeTitle = "Assembly Code";


    QString currunt_file="";
};
#endif // MIPSGUIAPP_H
