#include "codeviewer.h"
#include "ui_codeviewer.h"


CodeViewer::CodeViewer(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::CodeViewer)
{
    ui->setupUi(this);
    ui->progressBar->setVisible(false);
    ui->label->setText("");

}

CodeViewer::~CodeViewer()
{
    delete ui;
}
void CodeViewer:: setCode(QString Code){
    ui->label->setText(Code);
}
void CodeViewer:: update(bool x){
    ui->progressBar->setVisible(true);
    if(x){
        Code+="Test"+QString::number(counter)+" Success \n";
    }
    else{
        Code+="Test"+QString::number(counter)+" fail \n";
    }
    ui->progressBar->setValue(counter*10);
    counter++;
}

