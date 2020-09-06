#include "mipsguiapp.h"

#include <QApplication>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    MIPSGUIAPP w;
    w.show();
    return a.exec();
}
