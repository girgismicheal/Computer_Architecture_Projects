#include "Assembler.h"


string clrspace(string input)
{
    string output;
    for (size_t i = 0; i < input.length(); i++)
    {
        if (input[i] != ' ' && input[i] != '\t')
            output = output + input[i];
    }
    return output;
}
string CapToSmol(string input) // write later
{
    string output;
    for (size_t i = 0; i < input.length(); i++)
    {
        if (input[i] >= 'A' && input [i] <= 'Z' )
        {
            char c = input[i] + 32;
            output = output + c;
        }
        else
            output = output + input[i];
    }
    return output;
}

int getReg(string input)
{

    if (input.substr(0,5) == "$zero" || input.substr(0, 2) == "$0")
    {
        return 0;
    }
    else if (input.substr(0, 3) == "$at")
    {
        return 1;
    }
    else if (input.substr(0, 3) == "$v0")
    {
        return 2;
    }
    else if (input.substr(0, 3) == "$v1")
    {
        return 3;
    }
    else if (input.substr(0, 3) == "$a0")
    {
        return 4;
    }
    else if (input.substr(0, 3) == "$a1")
    {
        return 5;
    }
    else if (input.substr(0, 3) == "$a2")
    {
        return 6;
    }
    else if (input.substr(0, 3) == "$a3")
    {
        return 7;
    }
    else if (input.substr(0, 3) == "$t0")
    {
        return 8;
    }
    else if (input.substr(0, 3) == "$t1")
    {
        return 9;
    }
    else if (input.substr(0, 3) == "$t2")
    {
        return 10;
    }
    else if (input.substr(0, 3) == "$t3")
    {
        return 11;
    }
    else if (input.substr(0, 3) == "$t4")
    {
        return 12;
    }
    else if (input.substr(0, 3) == "$t5")
    {
        return 13;
    }
    else if (input.substr(0, 3) == "$t6")
    {
        return 14;
    }
    else if (input.substr(0, 3) == "$t7")
    {
        return 15;
    }
    else if (input.substr(0, 3) == "$s0")
    {
        return 16;
    }
    else if (input.substr(0, 3) == "$s1")
    {
        return 17;
    }
    else if (input.substr(0, 3) == "$s2")
    {
        return 18;
    }
    else if (input.substr(0, 3) == "$s3")
    {
        return 19;
    }
    else if (input.substr(0, 3) == "$s4")
    {
        return 20;
    }
    else if (input.substr(0, 3) == "$s5")
    {
        return 21;
    }
    else if (input.substr(0, 3) == "$s6")
    {
        return 22;
    }
    else if (input.substr(0, 3) == "$s7")
    {
        return 23;
    }
    else if (input.substr(0, 3) == "$t8")
    {
        return 24;
    }
    else if (input.substr(0, 3) == "$t9")
    {
        return 25;
    }
    else if (input.substr(0, 3) == "$k0")
    {
        return 26;
    }
    else if (input.substr(0, 3) == "$k1")
    {
        return 27;
    }
    else if (input.substr(0, 3) == "$gp")
    {
        return 28;
    }
    else if (input.substr(0, 3) == "$sp")
    {
        return 29;
    }
    else if (input.substr(0, 3) == "$fp")
    {
        return 30;
    }
    else if (input.substr(0, 3) == "$ra")
    {
        return 31;
    }
    else
        return 0;

}

string numToBinStr(int a, int length)
{
    string binary = "";
    int mask = 1;
    for (int i = 0; i < length; i++)
    {
        if ((mask&a) >= 1)
            binary = "1" + binary;
        else
            binary = "0" + binary;
        mask <<= 1;
    }
    return binary;
}

string write_inst(int op, int rs, int rt, int rd, int shamt, int fn)
{
    string inst = numToBinStr(op, 6) + numToBinStr(rs, 5) + numToBinStr(rt, 5) + numToBinStr(rd, 5) + numToBinStr(shamt, 5) + numToBinStr(fn, 6);
    string new_inst;
    for (int i = 0; i < 32; i++)
    {
        new_inst = new_inst + inst[i];
        if (i % 4 == 3 && i < 30)
            new_inst = new_inst + '_';
    }

    return new_inst;
}
string write_inst(int op, int rs, int rt, int immediate)
{
    string inst = numToBinStr(op, 6) + numToBinStr(rs, 5) + numToBinStr(rt, 5) + numToBinStr(immediate, 16);
    string new_inst;
    for (int i = 0; i < 32; i++)
    {
        new_inst = new_inst + inst[i];
        if (i % 4 == 3 && i < 30)
            new_inst = new_inst + '_';
    }

    return new_inst;
}
string write_inst(int op, int address)
{
    string inst = numToBinStr(op, 6) + numToBinStr(address, 26);
    string new_inst;
    for (int i = 0; i < 32; i++)
    {
        new_inst = new_inst + inst[i];
        if (i % 4 == 3 && i < 30)
            new_inst = new_inst + '_';
    }

    return new_inst;
}

string getCodeInst(string code)
{
    string inst;
    if (code[0] == 'j') // j, jal or jr
    {
        if (code[1] == 'a')
            inst = "jal";
        else if (code[1] == 'r')
            inst = "jr";
        else inst = "j";
    }
    else
        for (size_t i = 0; i < code.length(); i++)
        {
            if (code[i] == '$')
                break;
            inst = inst + code[i];
        }
    return inst;
}


string assemble(string code)
{
    string inst;
    string MachineCode;
    int op, rs, rt, rd, shamt, fn, immideate16, address26;


    //extract code instruction
    inst = getCodeInst(code);

    //extract parameters

    //R-Format
    if (inst == "add")
    {
        op = 0;
        shamt = 0;
        fn = 32;
        int j =0;

        for (size_t i=0;i < code.length(); i++)
        {
            if (code[i] == '$')
            {
                j++;
                if (j == 1)
                    rd = getReg(code.substr(i,code.length() - 1));
                else if (j == 2)
                    rs = getReg(code.substr(i,code.length() - 1));
                else if (j == 3)
                    rt = getReg(code.substr(i,code.length() - 1));
            }
        }

        return write_inst(op,rs,rt,rd,shamt,fn);

    }
    else if (inst == "sub")
    {
        op = 0;
        shamt = 0;
        fn = 34;
        int j = 0;

        for (size_t i = 0; i < code.length(); i++)
        {
            if (code[i] == '$')
            {
                j++;
                if (j == 1)
                    rd = getReg(code.substr(i,code.length() - 1));
                else if (j == 2)
                    rs = getReg(code.substr(i,code.length() - 1));
                else if (j == 3)
                    rt = getReg(code.substr(i,code.length() - 1));
            }
        }

        return write_inst(op, rs, rt, rd, shamt, fn);
    }
    else if (inst == "and")
    {
        op = 0;
        shamt = 0;
        fn = 36;
        int j = 0;

        for (size_t i = 0; i < code.length(); i++)
        {
            if (code[i] == '$')
            {
                j++;
                if (j == 1)
                    rd = getReg(code.substr(i,code.length() - 1));
                else if (j == 2)
                    rs = getReg(code.substr(i,code.length() - 1));
                else if (j == 3)
                    rt = getReg(code.substr(i,code.length() - 1));
            }
        }

        return write_inst(op, rs, rt, rd, shamt, fn);
    }
    else if (inst == "or")
    {
        op = 0;
        shamt = 0;
        fn = 37;
        int j = 0;

        for (size_t i = 0; i < code.length(); i++)
        {
            if (code[i] == '$')
            {
                j++;
                if (j == 1)
                    rd = getReg(code.substr(i,code.length() - 1));
                else if (j == 2)
                    rs = getReg(code.substr(i,code.length() - 1));
                else if (j == 3)
                    rt = getReg(code.substr(i,code.length() - 1));
            }
        }

        return write_inst(op, rs, rt, rd, shamt, fn);
    }
    else if (inst == "xor")
    {
        op = 0;
        shamt = 0;
        fn = 38;
        int j = 0;

        for (size_t i = 0; i < code.length(); i++)
        {
            if (code[i] == '$')
            {
                j++;
                if (j == 1)
                    rd = getReg(code.substr(i,code.length() - 1));
                else if (j == 2)
                    rs = getReg(code.substr(i,code.length() - 1));
                else if (j == 3)
                    rt = getReg(code.substr(i,code.length() - 1));
            }
        }

        return write_inst(op, rs, rt, rd, shamt, fn);
    }
    else if(inst == "nor")
    {
        op = 0;
        shamt = 0;
        fn = 39;
        int j = 0;

        for (size_t i = 0; i < code.length(); i++)
        {
            if (code[i] == '$')
            {
                j++;
                if (j == 1)
                    rd = getReg(code.substr(i,code.length() - 1));
                else if (j == 2)
                    rs = getReg(code.substr(i,code.length() - 1));
                else if (j == 3)
                    rt = getReg(code.substr(i,code.length() - 1));
            }
        }

        return write_inst(op, rs, rt, rd, shamt, fn);
    }
    else if (inst == "slt")
    {
        op = 0;
        shamt = 0;
        fn = 42;
        int j = 0;

        for (size_t i = 0; i < code.length(); i++)
        {
            if (code[i] == '$')
            {
                j++;
                if (j == 1)
                    rd = getReg(code.substr(i,code.length() - 1));
                else if (j == 2)
                    rs = getReg(code.substr(i,code.length() - 1));
                else if (j == 3)
                    rt = getReg(code.substr(i,code.length() - 1));
            }
        }

        return write_inst(op, rs, rt, rd, shamt, fn);
    }
    else if (inst == "sll")
    {
        op = 0;
        rs = 0;
        fn = 0;
        int j = 0;
        size_t i;

        for (i = 0; i < code.length(); i++)
        {
            if (code[i] == '$')
            {
                j++;
                if (j == 1)
                    rd = getReg(code.substr(i,code.length() - 1));
                else if (j == 2)
                {
                    rt = getReg(code.substr(i,code.length() - 1));
                    break;
                }


            }
        }
        for (i; i < code.length(); i++)
        {
            if (code[i] == ',')
                break;
        }
        shamt = stoi(code.substr(i+1,code.length() - 1));

        return write_inst(op, rs, rt, rd, shamt, fn);
    }
    else if (inst == "srl")
    {
        op = 0;
        rs = 0;
        fn = 2;
        int j = 0;
        size_t i;

        for (i = 0; i < code.length(); i++)
        {
            if (code[i] == '$')
            {
                j++;
                if (j == 1)
                    rd = getReg(code.substr(i, code.length() - 1));
                else if (j == 2)
                {
                    rt = getReg(code.substr(i, code.length() - 1));
                    break;
                }


            }
        }
        for (i; i < code.length(); i++)
        {
            if (code[i] == ',')
                break;
        }
        shamt = stoi(code.substr(i+1, code.length() - 1));

        return write_inst(op, rs, rt, rd, shamt, fn);
    }
    else if (inst == "sra")
    {
        op = 0;
        rs = 0;
        fn = 3;
        int j = 0;
        size_t i;

        for (i = 0; i < code.length(); i++)
        {
            if (code[i] == '$')
            {
                j++;
                if (j == 1)
                    rd = getReg(code.substr(i, code.length() - 1));
                else if (j == 2)
                {
                    rt = getReg(code.substr(i, code.length() - 1));
                    break;
                }


            }
        }
        for (i; i < code.length(); i++)
        {
            if (code[i] == ',')
                break;
        }
        shamt = stoi(code.substr(i+1, code.length() - 1));

        return write_inst(op, rs, rt, rd, shamt, fn);
    }
    else if (inst == "jr")
    {
        op = 0;
        rs = 0;
        shamt = 0;
        rd = 0;
        fn = 8;

        for (size_t i = 0; i < code.length(); i++)
            if (code[i] == '$')
            {
                rt = getReg(code.substr(i, code.length() - 1));
                break;
            }

        return write_inst(op, rs, rt, rd, shamt, fn);
    }
    //I-Format
    else if (inst == "addi")
    {
        op = 8;
        int j = 0;
        size_t i;

        for (i = 0; i < code.length(); i++)
        {
            if (code[i] == '$')
            {
                j++;
                if (j == 1)
                    rt = getReg(code.substr(i, code.length() - 1));
                else if (j == 2)
                {
                    rs = getReg(code.substr(i, code.length() - 1));
                    break;
                }


            }
        }
        for (i; i < code.length(); i++)
        {
            if (code[i] == ',')
                break;
        }
        immideate16 = stoi(code.substr(i+1, code.length() - 1));

        return write_inst(op, rs, rt, immideate16);
    }
    else if (inst == "andi")
    {
        op = 12;
        int j = 0;
        size_t i;

        for (i = 0; i < code.length(); i++)
        {
            if (code[i] == '$')
            {
                j++;
                if (j == 1)
                    rt = getReg(code.substr(i, code.length() - 1));
                else if (j == 2)
                {
                    rs = getReg(code.substr(i, code.length() - 1));
                    break;
                }


            }
        }
        for (i; i < code.length(); i++)
        {
            if (code[i] == ',')
                break;
        }
        immideate16 = stoi(code.substr(i+1, code.length() - 1));

        return write_inst(op, rs, rt, immideate16);
    }
    else if (inst == "ori")
    {
        op = 13;
        int j = 0;
        size_t i;

        for (i = 0; i < code.length(); i++)
        {
            if (code[i] == '$')
            {
                j++;
                if (j == 1)
                    rt = getReg(code.substr(i, code.length() - 1));
                else if (j == 2)
                {
                    rs = getReg(code.substr(i, code.length() - 1));
                    break;
                }


            }
        }
        for (i; i < code.length(); i++)
        {
            if (code[i] == ',')
                break;
        }
        immideate16 = stoi(code.substr(i+1, code.length() - 1));

        return write_inst(op, rs, rt, immideate16);
    }
    else if (inst == "xori")
    {
        op = 14;
        int j = 0;
        size_t i;

        for (i = 0; i < code.length(); i++)
        {
            if (code[i] == '$')
            {
                j++;
                if (j == 1)
                    rt = getReg(code.substr(i, code.length() - 1));
                else if (j == 2)
                {
                    rs = getReg(code.substr(i, code.length() - 1));
                    break;
                }


            }
        }
        for (i; i < code.length(); i++)
        {
            if (code[i] == ',')
                break;
        }
        immideate16 = stoi(code.substr(i+1, code.length() - 1));

        return write_inst(op, rs, rt, immideate16);
    }
    else if (inst == "slti")
    {
        op = 10;
        int j = 0;
        size_t i;

        for (i = 0; i < code.length(); i++)
        {
            if (code[i] == '$')
            {
                j++;
                if (j == 1)
                    rt = getReg(code.substr(i, code.length() - 1));
                else if (j == 2)
                {
                    rs = getReg(code.substr(i, code.length() - 1));
                    break;
                }


            }
        }
        for (i; i < code.length(); i++)
        {
            if (code[i] == ',')
                break;
        }
        immideate16 = stoi(code.substr(i+1, code.length() - 1));

        return write_inst(op, rs, rt, immideate16);
    }
    else if (inst == "lui")
    {
        op = 15;
        rs = 0;
        size_t i;

        for (i = 0; i < code.length(); i++)
        {
            if (code[i] == '$')
                rt = getReg(code.substr(i, code.length() - 1));


            if (code[i] == ',')
                break;
        }
        immideate16 = stoi(code.substr(i+1, code.length() - 1));

        return write_inst(op, rs, rt, immideate16);
    }
    else if (inst == "lw")
    {
        op = 35;
        size_t i;
        int j = 0;
        int constStart,constEnd;

        for (i = 0; i < code.length(); i++)
        {
            if (code[i] == '$')
            {
                j++;
                if (j == 1)
                    rt = getReg(code.substr(i, code.length() - 1));
                else if (j == 2)
                {
                    rs = getReg(code.substr(i, code.length() - 1));
                    break;
                }
            }

            if (code[i] == ',')
                constStart = i + 1;
            if (code[i] == '(')
                constEnd = i - 1;
        }
        immideate16 = stoi(code.substr(constStart,constEnd));

        return write_inst(op, rs, rt, immideate16);
    }
    else if (inst == "lh")
    {
        op = 33;
        size_t i;
        int j = 0;
        int constStart, constEnd;

        for (i = 0; i < code.length(); i++)
        {
            if (code[i] == '$')
            {
                j++;
                if (j == 1)
                    rt = getReg(code.substr(i, code.length() - 1));
                else if (j == 2)
                {
                    rs = getReg(code.substr(i, code.length() - 1));
                    break;
                }
            }

            if (code[i] == ',')
                constStart = i + 1;
            if (code[i] == '(')
                constEnd = i - 1;
        }
        immideate16 = stoi(code.substr(constStart, constEnd));

        return write_inst(op, rs, rt, immideate16);
    }
    else if (inst == "lb")
    {
        op = 32;
        size_t i;
        int j = 0;
        int constStart, constEnd;

        for (i = 0; i < code.length(); i++)
        {
            if (code[i] == '$')
            {
                j++;
                if (j == 1)
                    rt = getReg(code.substr(i, code.length() - 1));
                else if (j == 2)
                {
                    rs = getReg(code.substr(i, code.length() - 1));
                    break;
                }
            }

            if (code[i] == ',')
                constStart = i + 1;
            if (code[i] == '(')
                constEnd = i - 1;
        }
        immideate16 = stoi(code.substr(constStart, constEnd));

        return write_inst(op, rs, rt, immideate16);
    }
    else if (inst == "sw")
    {
        op = 43;
        size_t i;
        int j = 0;
        int constStart, constEnd;

        for (i = 0; i < code.length(); i++)
        {
            if (code[i] == '$')
            {
                j++;
                if (j == 1)
                    rt = getReg(code.substr(i, code.length() - 1));
                else if (j == 2)
                {
                    rs = getReg(code.substr(i, code.length() - 1));
                    break;
                }
            }

            if (code[i] == ',')
                constStart = i + 1;
            if (code[i] == '(')
                constEnd = i - 1;
        }
        immideate16 = stoi(code.substr(constStart, constEnd));

        return write_inst(op, rs, rt, immideate16);
    }
    else if (inst == "sh")
    {
        op = 41;
        size_t i;
        int j = 0;
        int constStart, constEnd;

        for (i = 0; i < code.length(); i++)
        {
            if (code[i] == '$')
            {
                j++;
                if (j == 1)
                    rt = getReg(code.substr(i, code.length() - 1));
                else if (j == 2)
                {
                    rs = getReg(code.substr(i, code.length() - 1));
                    break;
                }
            }

            if (code[i] == ',')
                constStart = i + 1;
            if (code[i] == '(')
                constEnd = i - 1;
        }
        immideate16 = stoi(code.substr(constStart, constEnd));

        return write_inst(op, rs, rt, immideate16);
    }
    else if(inst == "sb")
    {
        op = 40;
        size_t i;
        int j = 0;
        int constStart, constEnd;

        for (i = 0; i < code.length(); i++)
        {
            if (code[i] == '$')
            {
                j++;
                if (j == 1)
                    rt = getReg(code.substr(i, code.length() - 1));
                else if (j == 2)
                {
                    rs = getReg(code.substr(i, code.length() - 1));
                    break;
                }
            }

            if (code[i] == ',')
                constStart = i + 1;
            if (code[i] == '(')
                constEnd = i - 1;
        }
        immideate16 = stoi(code.substr(constStart, constEnd));

        return write_inst(op, rs, rt, immideate16);
    }
    else if(inst == "beq")
    {
        op = 4;
        int j = 0;
        size_t i;

        for (i = 0; i < code.length(); i++)
        {
            if (code[i] == '$')
            {
                j++;
                if (j == 1)
                    rs = getReg(code.substr(i, code.length() - 1));
                else if (j == 2)
                {
                    rt = getReg(code.substr(i, code.length() - 1));
                    break;
                }


            }
        }
        for (i; i < code.length(); i++)
        {
            if (code[i] == ',')
                break;
        }
        immideate16 = stoi(code.substr(i+1, code.length() - 1));

        return write_inst(op, rs, rt, immideate16);
    }
    else if (inst == "bne")
    {
        op = 5;
        int j = 0;
        size_t i;

        for (i = 0; i < code.length(); i++)
        {
            if (code[i] == '$')
            {
                j++;
                if (j == 1)
                    rs = getReg(code.substr(i, code.length() - 1));
                else if (j == 2)
                {
                    rt = getReg(code.substr(i, code.length() - 1));
                    break;
                }


            }
        }
        for (i; i < code.length(); i++)
        {
            if (code[i] == ',')
                break;
        }
        immideate16 = stoi(code.substr(i+1, code.length() - 1));

        return write_inst(op, rs, rt, immideate16);
    }
    // J-Format
    else if (inst == "j")
    {
        op = 2;
        address26 = stoi(code.substr(1, code.length() - 1));

        return write_inst(op, address26);
    }
    else if(inst == "jal")
    {
        op = 3;
        address26 = stoi(code.substr(3, code.length() - 1));

        return write_inst(op, address26);
    }

    else return write_inst(0,0); //NOP
}

void editLabels(vector<string> &Fin)
{
    vector<string> LabelNames;
    vector<int> LabelPos;
    size_t found;

    for (size_t line = 0; line < Fin.size(); line++)	//finds all Labels
        for (size_t c = 0; c < Fin[line].length(); c++)
        {
            if (Fin[line][c] == ':')				//found label
            {
                LabelNames.push_back(clrspace(Fin[line].substr(0, c)));
                LabelPos.push_back(line);
                Fin[line].replace(0, c + 1, "");
            }

            if (c < Fin[line].length())
                if (Fin[line][c] == '#' || Fin[line][c] == '&' || (c > 0 && Fin[line].substr(c - 1, 2) == "//"))	// found comment
                {
                    Fin[line].replace(c, Fin[line].size() - 1, "");
                    continue;
                }
        }


    for (int line = 0; line < (unsigned int) Fin.size(); line++)	//replace labels w/ numbers
        for(size_t labelID =0; labelID<LabelNames.size(); labelID++)
        {
            found = Fin[line].find(LabelNames[labelID]);
            if (found != string::npos)				//found label
                if(clrspace(Fin[line].substr(found)) == LabelNames[labelID])
                {
                    string inst = CapToSmol(getCodeInst(clrspace(Fin[line])));
                    if (inst == "j" || inst == "jal")
                    {
                        Fin[line].replace(found, LabelNames[labelID].length(), to_string( LabelPos[labelID]));
                    }
                    else if (inst == "beq" || inst == "bne")
                    {
                        Fin[line].replace(found, LabelNames[labelID].length(), to_string( LabelPos[labelID] - line -1 ));
                    }

                }
        }

}

string CodeAssembler (string code){
    vector<string> Code;
    stringstream ss;
    ss<<code;
    string line;
    while(getline(ss,line)){
        if(line.size()>0){
            if(clrspace(line)[0] == '#' || clrspace(line)[0] == '&' || clrspace(line).substr(0,2) == "//")
                continue;
            Code.push_back(line);
        }
    }

    editLabels(Code);
    string machine_code ="";
    for (size_t i = 0; i < Code.size(); i++){
            //cout<<i<<'\t'<<":"+Code[i]<<endl;
            machine_code += assemble(clrspace( CapToSmol(Code[i])))+"\n";

    }

    return machine_code;
}
