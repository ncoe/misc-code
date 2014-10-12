#include <iostream>
#include <fstream>
#include <iomanip>
using namespace std;

void method(istream& in)
{
	float M, A, C;
	size_t F, V;

	while (in >> M)
	{
		in >> A >> F >> V;

		C = M + (V - static_cast<size_t>(static_cast<float>(V) / ++F)) * A;
		C /= V;
		cout << fixed << setprecision(2) << C << endl;
	}
}

int main(int argc, char* argv[])
{
	if (argc == 1) method(cin);
	else method(ifstream(argv[1]));

	return EXIT_SUCCESS;
}