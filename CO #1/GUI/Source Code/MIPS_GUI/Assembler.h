#ifndef ASSEMBLER_H
#define ASSEMBLER_H

#include <stdio.h>
#include <string>
#include <iostream>
#include <vector>
#include <sstream>

using namespace std;

string clrspace(string input);
string CapToSmol(string input);
int getReg(string input);
string numToBinStr(int a, int length);
string write_inst(int op, int rs, int rt, int rd, int shamt, int fn);
string write_inst(int op, int rs, int rt, int immediate);
string write_inst(int op, int address);
string assemble(string code);
string CodeAssembler (string code);

#endif // ASSEMBLER_H
