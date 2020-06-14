#include "string"
#include "vector"
#include "ctime"

using namespace std;

string to_string(bool a)
{
	if (a)
		return "true";
	else
		return "false";
}


//------------------------------------ Classes ------------------------------//

class Item
{
public:
	string name;
	int price;

	Item()
	{
		name = "";
		price = 0;
	}
	Item (string a, int b)
	{
		name = a;
		price = b;
	}		
}I1("Burger", 20), I2("Cola", 5), I3("Salad", 3);

class Employee
{
public:
	string name;
	float wage;
	bool EotM = false;
	unsigned int charges = 0;
	int worktime = 0;
	time_t startTime;

	Employee(string a, float b, bool c, int d, int e)
	{
		name = a;
		wage = b;
		EotM = c;
		charges = d;
		worktime = e;
	}

	void checkIn()
	{
		time(&startTime);
	}
	void checkOut()
	{
		time_t endTime;
		time(&endTime);

		worktime += difftime(endTime,startTime) / 60;
	}
}E1("Ahmed", 5.5, true, 0, 0), E2("Mostafa", 6.5, false, 0, 0), E3("Tamer", 4.5, false, 0, 0);

class OrderEntry
{
public:
	Item thing;
	unsigned int amount;


	OrderEntry(Item a, int b)
	{
		thing = a;
		amount = b;
	}

	string getname()
	{
		return thing.name;
	}
	int getprice()
	{
		return thing.price;
	}
};



//------------------------------------ Menu ------------------------------//
vector<Item> Menu = { I1,I2,I3 };

void addMenuItem(string a, int b)
{
	Item In(a, b);
	Menu.push_back(In);
}

void editMenuItem(string oldname, string a, int b)
{
	size_t i;
	for (i = 0; i < Menu.size(); i++)
		if (Menu[i].name == oldname)
			break;
	
	Menu[i].name = a;
	Menu[i].price = b;
}

void removeMenuItem(string oldname,string a, int b)
{
	size_t i;
	for (i = 0; i < Menu.size(); i++)
		if (Menu[i].name == oldname)
			break;

	Menu.erase(Menu.begin()+i);
}

string PrintMenu()
{
	string s = "\n\n--------Menu--------\n\n";
	s += "Name: \tPrice:\n\n";

	for (size_t i = 0; i < Menu.size(); i++)
		s += Menu[i].name + "\t" + to_string(Menu[i].price) + "\n";

	return s;
}



//------------------------------------ Team ------------------------------//
vector<Employee> Team = { E1,E2,E3 };

void hireTeamMember(string a, float b)
{
	Employee En(a, b, false, 0,0);
	Team.push_back(En);
}

void editTeamMember(string oldname, string a, float b)
{
	size_t i;
	for (i = 0; i < Team.size(); i++)
		if (Team[i].name == oldname)
			break;

	Team[i].name = a;
	Team[i].wage = b;
}

void fireTeamMember(string oldname, string a, int b)
{
	size_t i;
	for (i = 0; i < Team.size(); i++)
		if (Team[i].name == oldname)
			break;

	Team.erase(Team.begin() + i);
}

void chooseEotM(string a)
{

	size_t i;
	for (i = 0; i < Team.size(); i++)
		if (Team[i].name == a)
			Team[i].EotM = true;
		else
			Team[i].EotM = false;
}

void chargeEmployee(string a)
{

	size_t i;
	for (i = 0; i < Team.size(); i++)
		if (Team[i].name == a)
			break;

	Team[i].charges++;
}

string PrintSalaries()
{
	string s = "\n\n--------Salaries--------\n\n";
	s += "Name:\tHourly Wage:\tWorkingHours:\tSubTotal:\tCharges: Employee of the Month:\tTotal: \n\n" ;
	float total=0;
	float EmpSal;

	for (size_t i = 0; i < Team.size(); i++)
	{
		EmpSal = Team[i].worktime*Team[i].wage - Team[i].charges*Team[i].wage;
		if (Team[i].EotM)
			EmpSal += 6 * Team[i].wage;
		total += EmpSal;

		s += Team[i].name + "\t" + to_string(Team[i].wage) + "\t" + to_string(Team[i].worktime) + "\t\t" 
			+ to_string(Team[i].worktime*Team[i].wage) + "\t" + to_string(Team[i].charges) + "\t " 
			+ to_string(Team[i].EotM) + "\t\t\t" + to_string(EmpSal) + "\n";
	}

	s += "___________________________________________________________________________________________________\n\n\t\t\t\t\t\t\t\t\t\tTotal:\t" 
		+ to_string(total) + "\n\n";

	return s;
}



//------------------------------------ Complaints ------------------------------//
string Complaints ="\n\n--------Complaints--------\n\n";

void addComplaint(string s)
{
	Complaints += s + "\n\n\n";
}

string PrintComplaints()
{
	string s = Complaints;
	Complaints = "\n\n--------Complaints--------\n\n";
	return s;
}



//------------------------------------ Order ------------------------------//
vector<OrderEntry> Order;

void clearOrder()
{
	Order.clear();
}

void addOrderItem(Item a, int amount)
{
	Order.push_back(OrderEntry(a, amount));
}

void dropOrderItem()
{
	Order.pop_back();
}

string PrintOrder()
{
	string s = "\n\n--------Order--------\n\n";
	s += "Name:\tPrice:\tAmount:\tTotal:\n\n";

	for (size_t i = 0; i < Order.size(); i++)
	{
		s += Order[i].getname() + "\t" + to_string(Order[i].getprice()) + "\t" + to_string(Order[i].amount) 
			+ "\t" + to_string(Order[i].getprice()*Order[i].amount) + "\n";
	}

	return s;
}
string PrintReceipt(string CustName = "Customer", string CustAdd = "Here!!", string PaymentMethod = "Cash")
{

	string s = "Order By: " + CustName + "\t Order Address: " + CustAdd + "\t Payment Method: " 
		+ PaymentMethod + "\n\n";
	s += "Name:\tPrice:\tAmount:\tTotal:\n\n";

	float subtotal = 0;

	for (size_t i = 0; i < Order.size(); i++)
	{
		s += Order[i].getname() + "\t" + to_string(Order[i].getprice()) + "\t" + to_string(Order[i].amount)
			+ "\t" + to_string(Order[i].getprice()*Order[i].amount) + "\n";
		subtotal += Order[i].getprice() * Order[i].amount;
	}

	s += "_________________________________\n\n\tSubTotal:\t" + to_string(subtotal) 
		+ "\n\tTax & Service:\t" + to_string(subtotal * 0.14) 
		+ "\n_________________________________\n\n\tTotal:\t\t" + to_string(subtotal * 1.14) + "\n\n";

	return s;

}

