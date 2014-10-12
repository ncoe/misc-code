#include <iostream>
#include <fstream>
#include <string>
#include <bitset>
#include <vector>
using namespace std;

struct Rule {
	size_t A,B,C;

	enum {
		_S,_A,_B,_C,_D,_E,_F,_G,_H,_I,_J,_a,_b,_e
	};

	Rule(size_t rA, size_t tB, size_t tC) {
		A=rA;
		B=tB;
		C=tC;
	}
};

int Index(int i, int j) {
	if (i > j) throw runtime_error("Index out of bounds exception");
	return i + j*(j+1)/2;
}

bool CYK(vector<Rule>& rules, string& str) {
	bool member=false;
	size_t n = str.size();
	size_t E = n*(n+1)/2;
	unique_ptr<bitset<14>[]> P(new bitset<14>[E]);

	// initialize the diagonal of P
	for (int i=0; i<n; ++i) {
		for (int k=0; k<rules.size(); ++k) {
			if (str[i] == 'A' && rules[k].B==Rule::_a)
				P[Index(i,i)][rules[k].A] = true;
			else if (str[i] == 'B' && rules[k].B==Rule::_b)
				P[Index(i,i)][rules[k].A] = true;
			//else return false;
		}
	}

	// check all substrings to see if they can be produced
	for (int j=0; j<n; ++j) {
		for (int i=j-1; i>=0; --i) {
			for (int k=0; k<j-i; ++k) {
				for (int r=0; r<rules.size(); ++r) {
					if (P[Index(i,i+k)][rules[r].B] && P[Index(i+k+1,j)][rules[r].C])
						P[Index(i,j)][rules[r].A] = true;
				}
			}
		}
	}

	// check if the entire string can be produced from the substring
	if (P[Index(0, n-1)][Rule::_S]) member = true;

	return member;
}

bool isSolvable(string& str) {
	vector<Rule> rules;

	// initialize the grammer
	rules.push_back(Rule(Rule::_S, Rule::_A, Rule::_B));	// S -> A B
	rules.push_back(Rule(Rule::_S, Rule::_B, Rule::_C));	// S -> B C
	rules.push_back(Rule(Rule::_S, Rule::_B, Rule::_D));	// S -> B D
	rules.push_back(Rule(Rule::_S, Rule::_E, Rule::_F));	// S -> E F
	rules.push_back(Rule(Rule::_S, Rule::_F, Rule::_G));	// S -> F G
	rules.push_back(Rule(Rule::_S, Rule::_F, Rule::_H));	// S -> F H
	rules.push_back(Rule(Rule::_S, Rule::_S, Rule::_S));	// S -> S S
	rules.push_back(Rule(Rule::_B, Rule::_a, Rule::_e));	// B -> a e
	rules.push_back(Rule(Rule::_B, Rule::_A, Rule::_B));	// B -> A B
	rules.push_back(Rule(Rule::_F, Rule::_b, Rule::_e));	// F -> b e
	rules.push_back(Rule(Rule::_F, Rule::_E, Rule::_F));	// F -> E F
	rules.push_back(Rule(Rule::_C, Rule::_S, Rule::_B));	// C -> S B
	rules.push_back(Rule(Rule::_G, Rule::_S, Rule::_F));	// G -> S F
	rules.push_back(Rule(Rule::_A, Rule::_a, Rule::_e));	// A -> a e
	rules.push_back(Rule(Rule::_E, Rule::_b, Rule::_e));	// E -> b e
	rules.push_back(Rule(Rule::_D, Rule::_S, Rule::_I));	// D -> S I
	rules.push_back(Rule(Rule::_H, Rule::_S, Rule::_J));	// H -> S J
	rules.push_back(Rule(Rule::_I, Rule::_B, Rule::_C));	// I -> B C
	rules.push_back(Rule(Rule::_J, Rule::_F, Rule::_G));	// J -> F G

	if (str.empty()) return true;
	if (str.size() == 1) return false;
	return CYK(rules, str);

	return true;
}

void method(istream& in) {
	string puzzle;

	while (getline(in, puzzle)) {
		if (isSolvable(puzzle)) cout << "solvable" << endl;
		else cout << "unsolvable" << endl;
	}
}

int main(int argc, char* argv[]) {
	if (argc==1) method(cin);
	else method(ifstream(argv[1]));

	return EXIT_SUCCESS;
}