#include <iostream>
#include <fstream>
#include <stack>
using namespace std;

struct fraction
{
	int numerator;
	int denominator;
};

int gcd(int a, int b)
{
	int t;

	while (b != 0)
	{
		t = b;
		b = a % b;
		a = t;
	}

	return a;
}

void method(istream& in)
{
	int num, den, tmp;
	char delim;
	fraction fract1, fract2;
	stack<fraction> vals;
	stack<char> ops;

	while (in >> delim)
	{
		if (delim == '(')
		{
			ops.push(delim);
			while (ops.size() > 0)
			{
				in >> delim;

				if (delim == '(') ops.push(delim);
				else if (delim == '&') ops.push(delim);
				else if (delim == '|') ops.push(delim);
				else if (delim == ')')
				{
					while (ops.top() != '(')
					{
						delim = ops.top();
						ops.pop();

						if (delim == '&')
						{
							// serial circuit
							fract1 = vals.top();
							vals.pop();
							fract2 = vals.top();
							vals.pop();

							fract1.numerator = fract1.numerator * fract2.denominator + fract2.numerator * fract1.denominator;
							fract1.denominator = fract1.denominator * fract2.denominator;
							tmp = gcd(fract1.numerator, fract1.denominator);
							fract1.numerator /= tmp;
							fract1.denominator /= tmp;

							vals.push(fract1);
						}
						else if (delim == '|')
						{
							// parallel circuit
							fract1 = vals.top();
							vals.pop();
							fract2 = vals.top();
							vals.pop();

							swap(fract1.numerator, fract1.denominator);
							swap(fract2.numerator, fract2.denominator);

							fract1.numerator = fract1.numerator * fract2.denominator + fract2.numerator * fract1.denominator;
							fract1.denominator = fract1.denominator * fract2.denominator;
							tmp = gcd(fract1.numerator, fract1.denominator);
							fract1.numerator /= tmp;
							fract1.denominator /= tmp;

							swap(fract1.numerator, fract1.denominator);
							swap(fract2.numerator, fract2.denominator);

							vals.push(fract1);
						}
					}
					ops.pop();
				}
				else
				{
					in.unget();
					in >> num >> delim >> den;
					tmp = gcd(num, den);
					fract1.numerator = num / tmp;
					fract1.denominator = den / tmp;
					vals.push(fract1);
				}
			}

			fract1 = vals.top();
			vals.pop();

			cout << fract1.numerator << '/' << fract1.denominator << endl;
		}
		else
		{
			in.unget();
			in >> num >> delim >> den;
			tmp = gcd(num, den);
			cout << num/tmp << '/' << den/tmp << endl;
		}
	}
}

int main(int argc, char* argv[])
{
	if (argc == 1) method(cin);
	else method(ifstream(argv[1]));

	return EXIT_SUCCESS;
}
