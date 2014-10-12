#include <iostream>
#include <iomanip>
#include <fstream>
using namespace std;

void method(istream& in)
{
	int A, B, C, N;

	while(in >> N >> A >> B >> C)
	{
		if (N == 0) break;

		//double sum=0.0;
		//for (int i=0; i<N; ++i)
		//{
		//	if ((i-A)%N < 0) sum += 3*N + (i-A)%N;
		//	else sum += 2*N + (i-A)%N;

		//	if ((B-A)%N < 0) sum += 2*N + (B-A)%N;
		//	else sum += N + (B-A)%N;

		//	if ((B-C)%N < 0) sum += N + (B-C)%N;
		//	else sum += (B-C)%N;
		//}
		//
		//cout << fixed << setprecision(3) << sum / N << endl;

		double avg = (7.0*N-1)/2.0;
		if ((B-A)%N < 0) avg += (N+B-A)%N;
		else avg += (B-A)%N;

		if ((B-C)%N < 0) avg += (N+B-C)%N;
		else avg += (B-C)%N;

		cout << fixed << setprecision(3) << avg << endl;
	}
}

int main(int argc, char* argv[])
{
	if (argc == 1) method(cin);
	else method(ifstream(argv[1]));

	return EXIT_SUCCESS;
}