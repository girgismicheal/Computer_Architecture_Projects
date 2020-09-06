#ifndef CODEVIEWER_H
#define CODEVIEWER_H

#include <QDialog>


namespace Ui {
class CodeViewer;
}

class CodeViewer : public QDialog
{
    Q_OBJECT

public:
    explicit CodeViewer(QWidget *parent = nullptr);
    void setCode(QString code);
    void update(bool x);
    ~CodeViewer();

private:

    Ui::CodeViewer *ui;
    QString Code="";
    int counter=1;
};

#endif // CODEVIEWER_H
