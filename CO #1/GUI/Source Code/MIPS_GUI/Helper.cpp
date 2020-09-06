#include "Helper.h"
void writeInFile(QString path , QString content , QWidget* Parent){
    //the function writes the contint in the file in path
    QFile File(path); // access the file
    if(!(File.open(QFile::WriteOnly|QFile::Text))){
        QMessageBox::warning(Parent,"Writing in File problem","Can't read in the file in \n"+path);
        //if failed the function breaks and show this error message
        return;
    }
    QTextStream out(&File);
    out<<content;
}
void ShowCode(QString Content, QString Title){
   CodeViewer *codeviewer= new CodeViewer();
    codeviewer->setWindowTitle(Title);
    codeviewer->setCode(Content);
    codeviewer->show();
}


void RunModelSim(QWidget* Parent){
    QProcess *modelsim = new QProcess (Parent);
    modelsim->start("C:/Windows/system32/cmd.exe");
    modelsim->waitForStarted();
    modelsim->execute("vsim -c -do \"run -all\" C:/modeltech64_10.5/examples/work.MIPSProsssor");
    modelsim->close();
}


QString readFromFile(QString path, QWidget* Parent){
    QFile file (path);
    if(!(file.open(QFile::ReadOnly|QFile::Text))){
        QMessageBox::warning(Parent,"error occurred While Opening a file","Error occured while opening file in \n"+path+"\n devolopers are working to fix the error now");
    }
    QTextStream QTS(&file);
    return  QTS.readAll();
}

