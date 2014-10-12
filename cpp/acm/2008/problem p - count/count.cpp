#include <iostream>
#include <fstream>
#include <string>
using namespace std;

int main(int argc, char* argv[])
{
	string temp;
	size_t lines = 0;

	if (argc == 1)
		while (getline(cin, temp)) ++lines;
	else
	{
		ifstream in(argv[1]);
		while (getline(in, temp)) ++lines;
	}

	cout << lines;

	return EXIT_SUCCESS;
}