#include "mipsguiapp.h"
#include "ui_mipsguiapp.h"
#include "Assembler.h"
#include "Helper.h"
#include<QProcess>



MIPSGUIAPP::MIPSGUIAPP(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MIPSGUIAPP)
{
    ui->setupUi(this);
    ui->plainTextEdit->setPlaceholderText("Write Assembly Code Here");
    setWindowTitle("MIPS GUI Assembler Application");

}

MIPSGUIAPP::~MIPSGUIAPP()
{
    delete ui;
}


void MIPSGUIAPP::on_pushButton_clicked()
{
    QString Code= ui->plainTextEdit->toPlainText();
    QString MachineCodeString = QString::fromStdString(CodeAssembler(Code.toStdString()));
    writeInFile("D:\\ReadAddress\\Machine_Code.txt",MachineCodeString , this);
    ShowCode(MachineCodeString,MachineCodeTitle);
}

void MIPSGUIAPP::on_pushButton_2_clicked()
{
    QString Code = readFromFile(QFileDialog::getOpenFileName(this,"Open the file"),this);
    QString MachineCodeString = QString::fromStdString(CodeAssembler(Code.toStdString()));
    writeInFile("D:\\ReadAddress\\Machine_Code.txt",MachineCodeString , this);
    ShowCode(MachineCodeString,MachineCodeTitle);
    ShowCode(Code,AssemblyCodeTitle);
}

void MIPSGUIAPP::on_Simulator_clicked()
{
    RunModelSim(this);
    ShowCode("PC finally is : " +  readFromFile("D:\\ReadAddress\\PC.txt",this) +" in hexadecimal","PC");
    ShowCode(readFromFile("D:\\ReadAddress\\DMemory.txt",this),"Data Memory Content");
    ShowCode(readFromFile("D:\\ReadAddress\\Reg_Files.txt",this),"Register File Content");
}

void MIPSGUIAPP::on_AutomatedTestButton_clicked()
{
    QString Test[10];
    QString TestDMemResult[10];
    QString TestReqFileResult[10];

    Test[0]="D:\\ReadAddress\\TestProg1.txt";
    Test[1]="D:\\ReadAddress\\TestProg2.txt";
    Test[2]="D:\\ReadAddress\\TestProg3.txt";
    Test[3]="D:\\ReadAddress\\TestProg4.txt";
    Test[4]="D:\\ReadAddress\\TestProg5.txt";
    Test[5]="D:\\ReadAddress\\TestProg6.txt";
    Test[6]="D:\\ReadAddress\\TestProg7.txt";
    Test[7]="D:\\ReadAddress\\TestProg8.txt";
    Test[8]="D:\\ReadAddress\\TestProg9.txt";
    Test[9]="D:\\ReadAddress\\TestProgA.txt";

    TestDMemResult[0]="D:\\ReadAddress\\TestAnswers\\Test1\\DMemory.txt";
    TestDMemResult[1]="D:\\ReadAddress\\TestAnswers\\Test2\\DMemory.txt";
    TestDMemResult[2]="D:\\ReadAddress\\TestAnswers\\Test3\\DMemory.txt";
    TestDMemResult[3]="D:\\ReadAddress\\TestAnswers\\Test4\\DMemory.txt";
    TestDMemResult[4]="D:\\ReadAddress\\TestAnswers\\Test5\\DMemory.txt";
    TestDMemResult[5]="D:\\ReadAddress\\TestAnswers\\Test6\\DMemory.txt";
    TestDMemResult[6]="D:\\ReadAddress\\TestAnswers\\Test7\\DMemory.txt";
    TestDMemResult[7]="D:\\ReadAddress\\TestAnswers\\Test8\\DMemory.txt";
    TestDMemResult[8]="D:\\ReadAddress\\TestAnswers\\Test9\\DMemory.txt";
    TestDMemResult[9]="D:\\ReadAddress\\TestAnswers\\TestA\\DMemory.txt";

    TestReqFileResult[0]="D:\\ReadAddress\\TestAnswers\\Test1\\Reg_Files.txt";
    TestReqFileResult[1]="D:\\ReadAddress\\TestAnswers\\Test2\\Reg_Files.txt";
    TestReqFileResult[2]="D:\\ReadAddress\\TestAnswers\\Test3\\Reg_Files.txt";
    TestReqFileResult[3]="D:\\ReadAddress\\TestAnswers\\Test4\\Reg_Files.txt";
    TestReqFileResult[4]="D:\\ReadAddress\\TestAnswers\\Test5\\Reg_Files.txt";
    TestReqFileResult[5]="D:\\ReadAddress\\TestAnswers\\Test6\\Reg_Files.txt";
    TestReqFileResult[6]="D:\\ReadAddress\\TestAnswers\\Test7\\Reg_Files.txt";
    TestReqFileResult[7]="D:\\ReadAddress\\TestAnswers\\Test8\\Reg_Files.txt";
    TestReqFileResult[8]="D:\\ReadAddress\\TestAnswers\\Test9\\Reg_Files.txt";
    TestReqFileResult[9]="D:\\ReadAddress\\TestAnswers\\TestA\\Reg_Files.txt";

    QMessageBox::information(this,"Automode","running \n please don't interact with the GUI \n you are allowed to interact with messages");

    for (int i = 0 ; i <10 ; i++){
        QString Correct_Register_File_Content = readFromFile(TestReqFileResult[i],this);
        QString Correct_Data_Memory_Content = readFromFile(TestDMemResult[i],this);
        QString TestAssemblyCode = readFromFile(Test[i],this);
        writeInFile("D:\\ReadAddress\\Machine_Code.txt",QString::fromStdString(CodeAssembler(TestAssemblyCode.toStdString())), this);
        RunModelSim(this);
        QString Result_Data_Memory = readFromFile("D:\\ReadAddress\\DMemory.txt",this);
        QString Result_Register_File =readFromFile("D:\\ReadAddress\\Reg_Files.txt",this);


        string t1,t2,t3,t4;
        t1=Correct_Data_Memory_Content.toStdString();
        t2=Result_Data_Memory.toStdString();
        t3=Correct_Register_File_Content.toStdString();
        t4=Result_Register_File.toStdString();

        if(t1 == t2)
            QMessageBox::information(this,"Automode","Test "+QString::number(i+1)+"\n succeeded in data memory");
        else
            QMessageBox::information(this,"Automode","Test "+QString::number(i+1)+"\n failed in data memory");

        if(t3==t4)
            QMessageBox::information(this,"Automode","Test "+QString::number(i+1)+"\n succeeded in register file");
        else
            QMessageBox::information(this,"Automode","Test "+QString::number(i+1)+"\n failed in register file");
    }

}

