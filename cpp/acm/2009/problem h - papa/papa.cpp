#include <iostream>
#include <fstream>
#include <string>
#include <sstream>
#include <vector>
#include <set>
#include <algorithm>
#include "test.h"
using namespace std;

// X is Y's relation
struct relationship
{
	string X, Y;
	int relation;
	enum {wife, husband, daughter, son, mother, father};

	relationship(const string& Xname, const string& Yname, int relative)
		: X(Xname), Y(Yname)
	{	relation = relative;	}

	bool operator==(const relationship& rhs)
	{
		if (X != rhs.X) return false;
		if (Y != rhs.Y) return false;
		if (relation != rhs.relation) return false;

		return true;
	}

	bool operator<(const relationship& rhs)
	{
		if (this->X == rhs.X) return this->Y < rhs.Y;
		else return this->X < rhs.X;
	}
};

enum TERNARY { TRUE=1, UNKNOWN=0, FALSE=-1 };

void print(TERNARY var)
{
	if (var == TRUE) cout << "yes\n";
	else if (var == UNKNOWN) cout << "unknown\n";
	else if (var == FALSE) cout << "no\n";
}

vector<relationship> people;
set<string> names;

void addRelation(const relationship& r)
{
	people.push_back(r);
	names.insert(r.X);
	names.insert(r.Y);
}

// is X female?
TERNARY isFemale(const string& X)
{
	for (auto Z=people.begin(); Z!=people.end(); ++Z)
	{
		if (Z->X == X)
		{
			if (Z->relation == relationship::father) return FALSE;
			if (Z->relation == relationship::mother) return TRUE;
			if (Z->relation == relationship::son) return FALSE;
			if (Z->relation == relationship::daughter) return TRUE;
			if (Z->relation == relationship::husband) return FALSE;
			if (Z->relation == relationship::wife) return TRUE;
		}
	}

	return UNKNOWN;
}
// is X male?
TERNARY isMale(const string& X)
{
	for (auto Z=people.begin(); Z!=people.end(); ++Z)
	{
		if (Z->X == X)
		{
			if (Z->relation == relationship::father) return TRUE;
			if (Z->relation == relationship::mother) return FALSE;
			if (Z->relation == relationship::son) return TRUE;
			if (Z->relation == relationship::daughter) return FALSE;
			if (Z->relation == relationship::husband) return TRUE;
			if (Z->relation == relationship::wife) return FALSE;
		}
	}

	return UNKNOWN;
}

void addImplied()
{
	bool changed;

	do
	{
		changed = false;

		for (int i=0; i<people.size(); ++i)
		{
#pragma region husband
			if (people[i].relation == relationship::husband &&
				find(people.begin(),people.end(),relationship(people[i].Y,people[i].X,relationship::wife)) == people.end())
			{
				// X is Y's husband.		Y is found to be X's wife.
				people.push_back(relationship(people[i].Y,people[i].X,relationship::wife));
				changed = true;
			}
#pragma endregion
#pragma region wife
			else if (people[i].relation == relationship::wife &&
				find(people.begin(),people.end(),relationship(people[i].Y,people[i].X,relationship::husband)) == people.end())
			{
				// X is Y's wife.		Y is found to be X's husband.
				people.push_back(relationship(people[i].Y,people[i].X,relationship::husband));
				changed = true;
			}
#pragma endregion
#pragma region father
			else if (people[i].relation == relationship::father)
			{
				if (isMale(people[i].Y) == TRUE && 
					find(people.begin(),people.end(),relationship(people[i].Y,people[i].X,relationship::son))==people.end())
				{
					// X is Y's father.		Y is found to be X's son.
					people.push_back(relationship(people[i].Y,people[i].X,relationship::son));
					changed = true;
				}
				else if (isFemale(people[i].Y) == TRUE && 
					find(people.begin(),people.end(),relationship(people[i].Y,people[i].X,relationship::daughter))==people.end())
				{
					// X is Y's father.		Y is found to be X's daughter.
					people.push_back(relationship(people[i].Y,people[i].X,relationship::daughter));
					changed = true;
				}
				else
				{
					for (auto Z=names.begin(); Z!=names.end(); ++Z)
					{
						if (*Z == people[i].X || *Z == people[i].Y) continue;

						if (find(people.begin(),people.end(),relationship(*Z,people[i].Y,relationship::mother))!=people.end())
						{
							if (find(people.begin(),people.end(),relationship(*Z,people[i].X,relationship::wife))==people.end())
							{
								// X is Y's father.		Z is Y's mother.		Z is found to be X's wife.
								people.push_back(relationship(*Z,people[i].X,relationship::wife));
								changed = true;
							}
							else if (find(people.begin(),people.end(),relationship(people[i].X,*Z,relationship::husband))==people.end())
							{
								// X is Y's father.		Z is Y's mother.		X is found to be Y's husband.
								people.push_back(relationship(people[i].X,*Z,relationship::husband));
								changed = true;
							}
						}
						else if (find(people.begin(),people.end(),relationship(people[i].Y,*Z,relationship::son))!=people.end() &&
							find(people.begin(),people.end(),relationship(*Z,people[i].Y,relationship::mother))==people.end())
						{
							// X is Y's father.		Y is Z's son.		Z is found to be Y's mother.
							people.push_back(relationship(*Z,people[i].Y,relationship::mother));
							changed = true;
						}
						else if (find(people.begin(),people.end(),relationship(people[i].Y,*Z,relationship::daughter))!=people.end() &&
							find(people.begin(),people.end(),relationship(*Z,people[i].Y,relationship::mother))==people.end())
						{
							// X is Y's father.		Y is Z's daughter.		Z is found to be Y's mother.
							people.push_back(relationship(*Z,people[i].Y,relationship::mother));
							changed = true;
						}
						else if (find(people.begin(),people.end(),relationship(people[i].X,*Z,relationship::husband))!=people.end())
						{
							if (find(people.begin(),people.end(),relationship(*Z,people[i].Y,relationship::mother))==people.end())
							{
								// X is Y's father.		X is Z's husband.		Z is found to be Y's mother.
								people.push_back(relationship(*Z,people[i].Y,relationship::mother));
								changed = true;
							}
						}
					}
				}
			}
#pragma endregion
#pragma region mother
			else if (people[i].relation == relationship::mother)
			{
				if (isMale(people[i].Y) == TRUE && find(people.begin(),people.end(),relationship(people[i].Y,people[i].X,relationship::son))==people.end())
				{
					// X is Y's mother.		Y is found to be X's son.
					people.push_back(relationship(people[i].Y,people[i].X,relationship::son));
					changed = true;
				}
				else if (isFemale(people[i].Y) == TRUE && find(people.begin(),people.end(),relationship(people[i].Y,people[i].X,relationship::daughter))==people.end())
				{
					// X is Y's mother.		Y is found to be X's daughter.
					people.push_back(relationship(people[i].Y,people[i].X,relationship::daughter));
					changed = true;
				}
				else
				{
					for (auto Z=names.begin(); Z!=names.end(); ++Z)
					{
						if (*Z == people[i].X || *Z == people[i].Y) continue;

						if (find(people.begin(),people.end(),relationship(*Z,people[i].Y,relationship::father))!=people.end())
						{
							if (find(people.begin(),people.end(),relationship(*Z,people[i].X,relationship::husband))==people.end())
							{
								// X is Y's mother.		Z is Y's father.		Z is found to be X's husband.
								people.push_back(relationship(*Z,people[i].X,relationship::husband));
								changed = true;
							}
							else if (find(people.begin(),people.end(),relationship(people[i].X,*Z,relationship::wife))==people.end())
							{
								// X is Y's mother.		Z is Y's father.		X is found to be Y's wife.
								people.push_back(relationship(people[i].X,*Z,relationship::wife));
								changed = true;
							}
						}
						else if (find(people.begin(),people.end(),relationship(people[i].Y,*Z,relationship::son))!=people.end() &&
							find(people.begin(),people.end(),relationship(*Z,people[i].Y,relationship::father))==people.end())
						{
							// X is Y's mother.		Y is Z's son.		Z is found to be Y's father.
							people.push_back(relationship(*Z,people[i].Y,relationship::father));
							changed = true;
						}
						else if (find(people.begin(),people.end(),relationship(people[i].Y,*Z,relationship::daughter))!=people.end() &&
							find(people.begin(),people.end(),relationship(*Z,people[i].Y,relationship::father))==people.end())
						{
							// X is Y's mother.		Y is Z's daughter.		Z is found to be Y's father.
							people.push_back(relationship(*Z,people[i].Y,relationship::father));
							changed = true;
						}
						else if (find(people.begin(),people.end(),relationship(people[i].X,*Z,relationship::wife))!=people.end())
						{
							if (find(people.begin(),people.end(),relationship(*Z,people[i].Y,relationship::father))==people.end())
							{
								// X is Y's mother.		X is Z's wife.		Z is found to be Y's father.
								people.push_back(relationship(*Z,people[i].Y,relationship::father));
								changed = true;
							}
						}
					}
				}
			}
#pragma endregion
#pragma region son
			else if (people[i].relation == relationship::son)
			{
				if (isMale(people[i].Y) == TRUE && find(people.begin(),people.end(),relationship(people[i].Y,people[i].X,relationship::father))==people.end())
				{
					// X is Y's son.		Y is found to be X's father.
					people.push_back(relationship(people[i].Y,people[i].X,relationship::father));
					changed=true;
				}
				else if (isFemale(people[i].Y) == TRUE && find(people.begin(),people.end(),relationship(people[i].Y,people[i].X,relationship::mother))==people.end())
				{
					// X is Y's son.		Y is found to be X's mother.
					people.push_back(relationship(people[i].Y,people[i].X,relationship::mother));
					changed=true;
				}
				else
				{
					for (auto Z=names.begin(); Z!=names.end(); ++Z)
					{
						if (*Z == people[i].X || *Z == people[i].Y) continue;

						if (find(people.begin(),people.end(),relationship(*Z,people[i].Y,relationship::son))!=people.end())
						{
							for (auto W=names.begin(); W!=names.end(); ++W)
							{
								if (*W == people[i].X || *W == people[i].Y || *W == *Z) continue;

								if (find(people.begin(),people.end(),relationship(*Z,*W,relationship::son))!=people.end() &&
									find(people.begin(),people.end(),relationship(people[i].X,*W,relationship::son))==people.end())
								{
									// X is Y's son.			Z is Y's son.				Z is W's son.				X is found to be W's son.
									people.push_back(relationship(people[i].X,*W,relationship::son));
									changed=true;
								}
							}
						}
						else if (find(people.begin(),people.end(),relationship(*Z,people[i].Y,relationship::daughter))!=people.end())
						{
							for (auto W=names.begin(); W!=names.end(); ++W)
							{
								if (*W == people[i].X || *W == people[i].Y || *W == *Z) continue;

								if (find(people.begin(),people.end(),relationship(*Z,*W,relationship::daughter))!=people.end() &&
									find(people.begin(),people.end(),relationship(people[i].X,*W,relationship::son))==people.end())
								{
									// X is Y's son.			Z is Y's daughter.		Z is W's daughter.		X is found to be W's son.
									people.push_back(relationship(people[i].X,*W,relationship::son));
									changed=true;
								}
							}
						}
					}
				}
			}
#pragma endregion
#pragma region daughter
			else if (people[i].relation == relationship::daughter)
			{
				if (isMale(people[i].Y) == TRUE &&
					find(people.begin(),people.end(),relationship(people[i].Y,people[i].X,relationship::father))==people.end())
				{
					// X is Y's daughter.		Y is found to be X's father.
					people.push_back(relationship(people[i].Y,people[i].X,relationship::father));
					changed=true;
				}
				else if (isFemale(people[i].Y) == TRUE &&
					find(people.begin(),people.end(),relationship(people[i].Y,people[i].X,relationship::mother))==people.end())
				{
					// X is Y's daughter.		Y is found to be X's mother.
					people.push_back(relationship(people[i].Y,people[i].X,relationship::mother));
					changed=true;
				}
				else
				{
					for (auto Z=names.begin(); Z!=names.end(); ++Z)
					{
						if (*Z == people[i].X || *Z == people[i].Y) continue;

						if (find(people.begin(),people.end(),relationship(*Z,people[i].Y,relationship::son))!=people.end())
						{
							for (auto W=names.begin(); W!=names.end(); ++W)
							{
								if (*W == people[i].X || *W == people[i].Y || *W == *Z) continue;

								if (find(people.begin(),people.end(),relationship(*Z,*W,relationship::son))!=people.end() &&
									find(people.begin(),people.end(),relationship(people[i].X,*W,relationship::daughter))==people.end())
								{
									// X is Y's daughter.		Z is Y's son.				Z is W's son.				X is found to be W's daughter.
									people.push_back(relationship(people[i].X,*W,relationship::daughter));
									changed=true;
								}
							}
						}
						else if (find(people.begin(),people.end(),relationship(*Z,people[i].Y,relationship::daughter))!=people.end())
						{
							for (auto W=names.begin(); W!=names.end(); ++W)
							{
								if (*W == people[i].X || *W == people[i].Y || *W == *Z) continue;

								if (find(people.begin(),people.end(),relationship(*Z,*W,relationship::daughter))!=people.end() &&
									find(people.begin(),people.end(),relationship(people[i].X,*W,relationship::daughter))==people.end())
								{
									// X is Y's daughter.		Z is Y's daughter.		Z is W's daughter.		X is found to be W's daughter.
									people.push_back(relationship(people[i].X,*W,relationship::daughter));
									changed=true;
								}
							}
						}
					}
				}
			}
#pragma endregion
		}
	} while (changed);
}

void printall()
{
	sort(people.begin(), people.end());

	for (auto Z=people.begin(); Z!=people.end(); ++Z)
	{
		if (Z->relation == relationship::father) cout << Z->X << " is " << Z->Y << "'s father.\n";
		else if (Z->relation == relationship::mother) cout << Z->X << " is " << Z->Y << "'s mother.\n";
		else if (Z->relation == relationship::husband) cout << Z->X << " is " << Z->Y << "'s husband.\n";
		else if (Z->relation == relationship::wife) cout << Z->X << " is " << Z->Y << "'s wife.\n";
		else if (Z->relation == relationship::son) cout << Z->X << " is " << Z->Y << "'s son.\n";
		else if (Z->relation == relationship::daughter) cout << Z->X << " is " << Z->Y << "'s daughter.\n";
	}
	cout << '\n';

	for (auto Z=names.begin(); Z!=names.end(); ++Z)
	{
		if (isMale(*Z) == TRUE) cout << *Z << " is male.\n";
		else if (isFemale(*Z) == TRUE) cout << *Z << " is female.\n";
		else cout << *Z << " is either male or female.\n";
	}
	cout << '\n';
}

// is X Y's wife?
TERNARY isWife(const string& X, const string& Y)
{
	if (find(people.begin(),people.end(),relationship(X,Y,relationship::wife))!=people.end()) return TRUE;

	for (auto Z=names.begin(); Z!=names.end(); ++Z)
	{
		if (*Z == X || *Z == Y) continue;

		if (find(people.begin(),people.end(),relationship(*Z,X,relationship::son))!=people.end() &&
			find(people.begin(),people.end(),relationship(*Z,Y,relationship::son))!=people.end())
		{
			// Z is X's son.		Z is Y's son.
			return UNKNOWN;
		}
	}

	return FALSE;
}
// is X Y's husband?
TERNARY isHusband(const string& X, const string& Y)
{
	if (find(people.begin(),people.end(),relationship(X,Y,relationship::husband))!=people.end()) return TRUE;

	for (auto Z=names.begin(); Z!=names.end(); ++Z)
	{
		if (*Z == X || *Z == Y) continue;

		if (find(people.begin(),people.end(),relationship(*Z,X,relationship::son))!=people.end() &&
			find(people.begin(),people.end(),relationship(*Z,Y,relationship::son))!=people.end())
		{
			// Z is X's son.		Z is Y's son.
			return UNKNOWN;
		}
	}

	return FALSE;
}

// is X Y's daughter?
TERNARY isDaughter(const string& X, const string& Y)
{
	if (find(people.begin(),people.end(),relationship(X,Y,relationship::daughter))!=people.end()) return TRUE;

	if (find(people.begin(),people.end(),relationship(Y,X,relationship::mother))!=people.end() ||
		find(people.begin(),people.end(),relationship(Y,X,relationship::father))!=people.end()) return isFemale(X);

	return FALSE;
}
// is X Y's son?
TERNARY isSon(const string& X, const string& Y)
{
	if (find(people.begin(),people.end(),relationship(X,Y,relationship::son))!=people.end()) return TRUE;

	if (find(people.begin(),people.end(),relationship(Y,X,relationship::mother))!=people.end() ||
		find(people.begin(),people.end(),relationship(Y,X,relationship::father))!=people.end()) return isMale(X);

	return FALSE;
}

// is X Y's mother?
TERNARY isMother(const string& X, const string& Y)
{
	if (find(people.begin(),people.end(),relationship(X,Y,relationship::mother))!=people.end()) return TRUE;

	if (find(people.begin(),people.end(),relationship(Y,X,relationship::son))!=people.end() ||
		find(people.begin(),people.end(),relationship(Y,X,relationship::daughter))!=people.end()) return isFemale(X);

	return FALSE;
}
// is X Y's father?
TERNARY isFather(const string& X, const string& Y)
{
	if (find(people.begin(),people.end(),relationship(X,Y,relationship::father))!=people.end()) return TRUE;

	if (find(people.begin(),people.end(),relationship(Y,X,relationship::son))!=people.end() ||
		find(people.begin(),people.end(),relationship(Y,X,relationship::daughter))!=people.end()) return isMale(X);

	return FALSE;
}

// is X Y's niece?
TERNARY isNiece(const string& X, const string& Y)
{
	for (auto W=names.begin(); W!=names.end(); ++W)
	{
		if (*W == X || *W == Y) continue;

		for (auto Z=names.begin(); Z!=names.end(); ++Z)
		{
			if (*W == X || *W == Y || *W == *Z) continue;

			if (find(people.begin(),people.end(),relationship(X,*W,relationship::daughter))!=people.end())
			{
				if (find(people.begin(),people.end(),relationship(*W,*Z,relationship::son))!=people.end() ||
					find(people.begin(),people.end(),relationship(*W,*Z,relationship::daughter))!=people.end())
				{
					if (find(people.begin(),people.end(),relationship(*Z,Y,relationship::father))!=people.end() ||
						find(people.begin(),people.end(),relationship(*Z,Y,relationship::mother))!=people.end())
					{
						// X is W's daughter.	W is Z's son/daughter.	Z is Y's father/mother.
						return TRUE;
					}
					else if (find(people.begin(),people.end(),relationship(Y,*Z,relationship::son))!=people.end() ||
						find(people.begin(),people.end(),relationship(Y,*Z,relationship::daughter))!=people.end())
					{
						// X is W's daughter.	W is Z's son/daughter.	Y is Z's son/daughter.
						return TRUE;
					}
				}
				else if (find(people.begin(),people.end(),relationship(*Z,*W,relationship::mother))!=people.end() ||
					find(people.begin(),people.end(),relationship(*Z,*W,relationship::father))!=people.end())
				{
					if (find(people.begin(),people.end(),relationship(*Z,Y,relationship::father))!=people.end() ||
						find(people.begin(),people.end(),relationship(*Z,Y,relationship::mother))!=people.end())
					{
						// X is W's daughter.	Z is W's mother/father.	Z is Y's father/mother.
						return TRUE;
					}
					else if (find(people.begin(),people.end(),relationship(Y,*Z,relationship::son))!=people.end() ||
						find(people.begin(),people.end(),relationship(Y,*Z,relationship::daughter))!=people.end())
					{
						// X is W's daughter.	Z is W's mother/father.	Y is Z's son/daughter.
						return TRUE;
					}
				}
			}
			else if (find(people.begin(),people.end(),relationship(*W,X,relationship::mother))!=people.end() ||
					find(people.begin(),people.end(),relationship(*W,X,relationship::father))!=people.end())
			{
				if (find(people.begin(),people.end(),relationship(*W,*Z,relationship::son))!=people.end() ||
					find(people.begin(),people.end(),relationship(*W,*Z,relationship::daughter))!=people.end())
				{
					if (find(people.begin(),people.end(),relationship(*Z,Y,relationship::father))!=people.end() ||
						find(people.begin(),people.end(),relationship(*Z,Y,relationship::mother))!=people.end())
					{
						// W is X's mother/father.		W is Z's son/daughter.	Z is Y's father/mother.
						return isFemale(X);
					}
					else if (find(people.begin(),people.end(),relationship(Y,*Z,relationship::son))!=people.end() ||
						find(people.begin(),people.end(),relationship(Y,*Z,relationship::daughter))!=people.end())
					{
						// W is X's mother/father.		W is Z's son/daughter.	Y is Z's son/daughter.
						return isFemale(X);
					}
				}
				else if (find(people.begin(),people.end(),relationship(*Z,*W,relationship::mother))!=people.end() ||
					find(people.begin(),people.end(),relationship(*Z,*W,relationship::father))!=people.end())
				{
					if (find(people.begin(),people.end(),relationship(*Z,Y,relationship::father))!=people.end() ||
						find(people.begin(),people.end(),relationship(*Z,Y,relationship::mother))!=people.end())
					{
						// W is X's mother/father.		Z is W's mother/father.	Z is Y's father/mother.
						return isFemale(X);
					}
					else if (find(people.begin(),people.end(),relationship(Y,*Z,relationship::son))!=people.end() ||
						find(people.begin(),people.end(),relationship(Y,*Z,relationship::daughter))!=people.end())
					{
						// W is X's mother/father.		Z is W's mother/father.	Y is Z's son/daughter.
						return isFemale(X);
					}
				}
			}
		}
	}

	return FALSE;
}
// is X Y's nephew?
TERNARY isNephew(const string& X, const string& Y)
{
	for (auto W=names.begin(); W!=names.end(); ++W)
	{
		if (*W == X || *W == Y) continue;

		for (auto Z=names.begin(); Z!=names.end(); ++Z)
		{
			if (*W == X || *W == Y || *W == *Z) continue;

			if (find(people.begin(),people.end(),relationship(X,*W,relationship::son))!=people.end())
			{
				if (find(people.begin(),people.end(),relationship(*W,*Z,relationship::son))!=people.end() ||
					find(people.begin(),people.end(),relationship(*W,*Z,relationship::daughter))!=people.end())
				{
					if (find(people.begin(),people.end(),relationship(*Z,Y,relationship::father))!=people.end() ||
						find(people.begin(),people.end(),relationship(*Z,Y,relationship::mother))!=people.end())
					{
						// X is W's son.		W is Z's son/daughter.	Z is Y's father/mother.
						return TRUE;
					}
					else if (find(people.begin(),people.end(),relationship(Y,*Z,relationship::son))!=people.end() ||
						find(people.begin(),people.end(),relationship(Y,*Z,relationship::daughter))!=people.end())
					{
						// X is W's son.		W is Z's son/daughter.	Y is Z's son/daughter.
						return TRUE;
					}
				}
				else if (find(people.begin(),people.end(),relationship(*Z,*W,relationship::mother))!=people.end() ||
					find(people.begin(),people.end(),relationship(*Z,*W,relationship::father))!=people.end())
				{
					if (find(people.begin(),people.end(),relationship(*Z,Y,relationship::father))!=people.end() ||
						find(people.begin(),people.end(),relationship(*Z,Y,relationship::mother))!=people.end())
					{
						// X is W's son.		Z is W's mother/father.	Z is Y's father/mother.
						return TRUE;
					}
					else if (find(people.begin(),people.end(),relationship(Y,*Z,relationship::son))!=people.end() ||
						find(people.begin(),people.end(),relationship(Y,*Z,relationship::daughter))!=people.end())
					{
						// X is W's son.		Z is W's mother/father.	Y is Z's son/daughter.
						return TRUE;
					}
				}
			}
			else if (find(people.begin(),people.end(),relationship(*W,X,relationship::mother))!=people.end() ||
					find(people.begin(),people.end(),relationship(*W,X,relationship::father))!=people.end())
			{
				if (find(people.begin(),people.end(),relationship(*W,*Z,relationship::son))!=people.end() ||
					find(people.begin(),people.end(),relationship(*W,*Z,relationship::daughter))!=people.end())
				{
					if (find(people.begin(),people.end(),relationship(*Z,Y,relationship::father))!=people.end() ||
						find(people.begin(),people.end(),relationship(*Z,Y,relationship::mother))!=people.end())
					{
						// W is X's mother/father.		W is Z's son/daughter.	Z is Y's father/mother.
						return isMale(X);
					}
					else if (find(people.begin(),people.end(),relationship(Y,*Z,relationship::son))!=people.end() ||
						find(people.begin(),people.end(),relationship(Y,*Z,relationship::daughter))!=people.end())
					{
						// W is X's mother/father.		W is Z's son/daughter.	Y is Z's son/daughter.
						return isMale(X);
					}
				}
				else if (find(people.begin(),people.end(),relationship(*Z,*W,relationship::mother))!=people.end() ||
					find(people.begin(),people.end(),relationship(*Z,*W,relationship::father))!=people.end())
				{
					if (find(people.begin(),people.end(),relationship(*Z,Y,relationship::father))!=people.end() ||
						find(people.begin(),people.end(),relationship(*Z,Y,relationship::mother))!=people.end())
					{
						// W is X's mother/father.		Z is W's mother/father.	Z is Y's father/mother.
						return isMale(X);
					}
					else if (find(people.begin(),people.end(),relationship(Y,*Z,relationship::son))!=people.end() ||
						find(people.begin(),people.end(),relationship(Y,*Z,relationship::daughter))!=people.end())
					{
						// W is X's mother/father.		Z is W's mother/father.	Y is Z's son/daughter.
						return isMale(X);
					}
				}
			}
		}
	}

	return FALSE;
}

// is X Y's grandfather?
TERNARY isGrandfather(const string& X, const string& Y)
{
	for (auto Z=names.begin(); Z!=names.end(); ++Z)
	{
		if (X == *Z || Y == *Z) continue;

		if (find(people.begin(),people.end(),relationship(X,*Z,relationship::father))!=people.end())
		{
			if (find(people.begin(),people.end(),relationship(*Z,Y,relationship::mother))!=people.end() ||
				find(people.begin(),people.end(),relationship(*Z,Y,relationship::father))!=people.end())
			{
				// X is Z's father.		Z is Y's mother/father.
				return TRUE;
			}
			else if (find(people.begin(),people.end(),relationship(Y,*Z,relationship::son))!=people.end() ||
				find(people.begin(),people.end(),relationship(Y,*Z,relationship::daughter))!=people.end())
			{
				// X is Z's father.		Y is Z's son/daughter.
				return TRUE;
			}
		}
		else if (find(people.begin(),people.end(),relationship(*Z,X,relationship::son))!=people.end() ||
			find(people.begin(),people.end(),relationship(*Z,X,relationship::daughter))!=people.end())
		{
			if (find(people.begin(),people.end(),relationship(*Z,Y,relationship::mother))!=people.end() ||
				find(people.begin(),people.end(),relationship(*Z,Y,relationship::father))!=people.end())
			{
				// Z is X's son/daughter.		Z is Y's mother/father.
				return isMale(X);
			}
			else if (find(people.begin(),people.end(),relationship(Y,*Z,relationship::son))!=people.end() ||
				find(people.begin(),people.end(),relationship(Y,*Z,relationship::daughter))!=people.end())
			{
				// Z is X's son/daughter.		Y is Z's son/daughter.
				return isMale(X);
			}
		}
	}

	return FALSE;
}
// is X Y's grandmother?
TERNARY isGrandmother(const string& X, const string& Y)
{
	for (auto Z=names.begin(); Z!=names.end(); ++Z)
	{
		if (X == *Z || Y == *Z) continue;

		if (find(people.begin(),people.end(),relationship(X,*Z,relationship::mother))!=people.end())
		{
			if (find(people.begin(),people.end(),relationship(*Z,Y,relationship::mother))!=people.end() ||
				find(people.begin(),people.end(),relationship(*Z,Y,relationship::father))!=people.end())
			{
				// X is Z's mother.		Z is Y's mother/father.
				return TRUE;
			}
			else if (find(people.begin(),people.end(),relationship(Y,*Z,relationship::son))!=people.end() ||
				find(people.begin(),people.end(),relationship(Y,*Z,relationship::daughter))!=people.end())
			{
				// X is Z's mother.		Y is Z's son/daughter.
				return TRUE;
			}
		}
		else if (find(people.begin(),people.end(),relationship(*Z,X,relationship::son))!=people.end() ||
			find(people.begin(),people.end(),relationship(*Z,X,relationship::daughter))!=people.end())
		{
			if (find(people.begin(),people.end(),relationship(*Z,Y,relationship::mother))!=people.end() ||
				find(people.begin(),people.end(),relationship(*Z,Y,relationship::father))!=people.end())
			{
				// Z is X's son/daughter.		Z is Y's mother/father.
				return isFemale(X);
			}
			else if (find(people.begin(),people.end(),relationship(Y,*Z,relationship::son))!=people.end() ||
				find(people.begin(),people.end(),relationship(Y,*Z,relationship::daughter))!=people.end())
			{
				// Z is X's son/daughter.		Y is Z's son/daughter.
				return isFemale(X);
			}
		}
	}

	return FALSE;
}

// is X Y's grandson?
TERNARY isGrandson(const string& X, const string& Y)
{
	for (auto Z=names.begin(); Z!=names.end(); ++Z)
	{
		if (find(people.begin(),people.end(),relationship(X,*Z,relationship::son))!=people.end())
		{
			if (find(people.begin(),people.end(),relationship(*Z,Y,relationship::son))!=people.end() ||
				find(people.begin(),people.end(),relationship(*Z,Y,relationship::daughter))!=people.end())
			{
				// X is Z's son.	Z is Y's son/daughter
				return TRUE;
			}
			else if (find(people.begin(),people.end(),relationship(Y,*Z,relationship::mother))!=people.end() ||
				find(people.begin(),people.end(),relationship(Y,*Z,relationship::father))!=people.end())
			{
				// X is Z's son.	Y is Z's mother/father
				return TRUE;
			}
		}
		else if (find(people.begin(),people.end(),relationship(*Z,X,relationship::mother))!=people.end() ||
			find(people.begin(),people.end(),relationship(*Z,X,relationship::father))!=people.end())
		{
			// Z is X's mother/father
			if (find(people.begin(),people.end(),relationship(*Z,Y,relationship::son))!=people.end() ||
				find(people.begin(),people.end(),relationship(*Z,Y,relationship::daughter))!=people.end())
			{
				// Z is X's mother/father.	Z is Y's son/daughter
				return isMale(X);
			}
			else if (find(people.begin(),people.end(),relationship(Y,*Z,relationship::mother))!=people.end() ||
				find(people.begin(),people.end(),relationship(Y,*Z,relationship::father))!=people.end())
			{
				// Z is X's mother/father.	Y is Z's mother/father
				return isMale(X);
			}
		}
	}

	return FALSE;
}
// is X Y's granddaughter?
TERNARY isGranddaughter(const string& X, const string& Y)
{
	for (auto Z=names.begin(); Z!=names.end(); ++Z)
	{
		if (find(people.begin(),people.end(),relationship(X,*Z,relationship::daughter))!=people.end())
		{
			if (find(people.begin(),people.end(),relationship(*Z,Y,relationship::son))!=people.end() ||
				find(people.begin(),people.end(),relationship(*Z,Y,relationship::daughter))!=people.end())
			{
				// X is Z's daughter.	Z is Y's son/daughter
				return TRUE;
			}
			else if (find(people.begin(),people.end(),relationship(Y,*Z,relationship::mother))!=people.end() ||
				find(people.begin(),people.end(),relationship(Y,*Z,relationship::father))!=people.end())
			{
				// X is Z's daughter.	Y is Z's mother/father
				return TRUE;
			}
		}
		else if (find(people.begin(),people.end(),relationship(*Z,X,relationship::mother))!=people.end() ||
			find(people.begin(),people.end(),relationship(*Z,X,relationship::father))!=people.end())
		{
			// Z is X's mother/father
			if (find(people.begin(),people.end(),relationship(*Z,Y,relationship::son))!=people.end() ||
				find(people.begin(),people.end(),relationship(*Z,Y,relationship::daughter))!=people.end())
			{
				// Z is X's mother/father.	Z is Y's son/daughter
				return isFemale(X);
			}
			else if (find(people.begin(),people.end(),relationship(Y,*Z,relationship::mother))!=people.end() ||
				find(people.begin(),people.end(),relationship(Y,*Z,relationship::father))!=people.end())
			{
				// Z is X's mother/father.	Y is Z's mother/father
				return isFemale(X);
			}
		}
	}

	return FALSE;
}

void method(istream& is)
{
	string temp, name1, name2, relation;
	stringstream ss;
	TERNARY truth;

	// get all of the facts that have been provided
	while (getline(is, temp))
	{
		if (temp.empty()) break;
		ss << temp;

		while (ss >> name1)
		{
			ss >> temp >> ws;
			getline(ss, name2, '\'');
			ss >> temp >> ws;
			getline(ss, relation, '.');

			if (relation == "wife")				addRelation(relationship(name1, name2, relationship::wife));
			else if (relation == "husband")	addRelation(relationship(name1, name2, relationship::husband));
			else if (relation == "daughter")	addRelation(relationship(name1, name2, relationship::daughter));
			else if (relation == "son")		addRelation(relationship(name1, name2, relationship::son));
			else if (relation == "mother")	addRelation(relationship(name1, name2, relationship::mother));
			else if (relation == "father")	addRelation(relationship(name1, name2, relationship::father));
		}

		ss.clear();
	}

	addImplied();

	// get each question, and provide an answer
	while (getline(is, temp))
	{
		if (temp.empty()) break;
		ss << temp;

		while (ss >> temp)
		{
			ss >> name1 >> ws;
			getline(ss, name2, '\'');
			ss >> temp >> ws;
			getline(ss, relation, '?');

			if (relation == "wife")						print(isWife(name1, name2));
			else if (relation == "husband")			print(isHusband(name1, name2));
			else if (relation == "daughter")			print(isDaughter(name1, name2));
			else if (relation == "son")				print(isSon(name1, name2));
			else if (relation == "mother")			print(isMother(name1, name2));
			else if (relation == "father")			print(isFather(name1, name2));
			else if (relation == "niece")				print(isNiece(name1, name2));
			else if (relation == "nephew")			print(isNephew(name1, name2));
			else if (relation == "grandfather")		print(isGrandfather(name1, name2));
			else if (relation == "grandmother")		print(isGrandmother(name1, name2));
			else if (relation == "grandson")			print(isGrandson(name1, name2));
			else if (relation == "granddaughter")	print(isGranddaughter(name1, name2));
		}

		ss.clear();
	}
}

void testmethod(istream& is)
{
	string temp, name1, name2, relation;
	stringstream ss;
	TERNARY truth;

	// get all of the facts that have been provided
	while (getline(is, temp))
	{
		if (temp.empty()) break;
		ss << temp;

		while (ss >> name1)
		{
			ss >> temp >> ws;
			getline(ss, name2, '\'');
			ss >> temp >> ws;
			getline(ss, relation, '.');

			if (relation == "wife")				addRelation(relationship(name1, name2, relationship::wife));
			else if (relation == "husband")	addRelation(relationship(name1, name2, relationship::husband));
			else if (relation == "daughter")	addRelation(relationship(name1, name2, relationship::daughter));
			else if (relation == "son")		addRelation(relationship(name1, name2, relationship::son));
			else if (relation == "mother")	addRelation(relationship(name1, name2, relationship::mother));
			else if (relation == "father")	addRelation(relationship(name1, name2, relationship::father));
		}

		ss.clear();
	}

	addImplied();
	//printall();

	// get each question, and provide an answer
	while (getline(is, temp))
	{
		if (temp.empty()) break;
		ss << temp;

		while (ss >> temp)
		{
			ss >> name1 >> ws;
			getline(ss, name2, '\'');
			ss >> temp >> ws;
			getline(ss, relation, '?');

			if (relation == "wife")
			{
				//print(isWife(name1, name2));
				getline(is, temp);
				if (temp=="yes") test_(isWife(name1, name2)==TRUE);
				else if (temp=="no") test_(isWife(name1, name2)==FALSE);
				else if (temp=="unknown") test_(isWife(name1, name2)==UNKNOWN);
			}
			else if (relation == "husband")
			{
				//print(isHusband(name1, name2));
				getline(is, temp);
				if (temp=="yes") test_(isHusband(name1, name2)==TRUE);
				else if (temp=="no") test_(isHusband(name1, name2)==FALSE);
				else if (temp=="unknown") test_(isHusband(name1, name2)==UNKNOWN);
			}
			else if (relation == "daughter")
			{
				//print(isDaughter(name1, name2));
				getline(is, temp);
				if (temp=="yes") test_(isDaughter(name1, name2)==TRUE);
				else if (temp=="no") test_(isDaughter(name1, name2)==FALSE);
				else if (temp=="unknown") test_(isDaughter(name1, name2)==UNKNOWN);
			}
			else if (relation == "son")
			{
				//print(isSon(name1, name2));
				getline(is, temp);
				if (temp=="yes") test_(isSon(name1, name2)==TRUE);
				else if (temp=="no") test_(isSon(name1, name2)==FALSE);
				else if (temp=="unknown") test_(isSon(name1, name2)==UNKNOWN);
			}
			else if (relation == "mother")
			{
				//print(isMother(name1, name2));
				getline(is, temp);
				if (temp=="yes") test_(isMother(name1, name2)==TRUE);
				else if (temp=="no") test_(isMother(name1, name2)==FALSE);
				else if (temp=="unknown") test_(isMother(name1, name2)==UNKNOWN);
			}
			else if (relation == "father")
			{
				//print(isFather(name1, name2));
				getline(is, temp);
				if (temp=="yes") test_(isFather(name1, name2)==TRUE);
				else if (temp=="no") test_(isFather(name1, name2)==FALSE);
				else if (temp=="unknown") test_(isFather(name1, name2)==UNKNOWN);
			}
			else if (relation == "niece")
			{
				//print(isNiece(name1, name2));
				getline(is, temp);
				if (temp=="yes") test_(isNiece(name1, name2)==TRUE);
				else if (temp=="no") test_(isNiece(name1, name2)==FALSE);
				else if (temp=="unknown") test_(isNiece(name1, name2)==UNKNOWN);
			}
			else if (relation == "nephew")
			{
				//print(isNephew(name1, name2));
				getline(is, temp);
				if (temp=="yes") test_(isNephew(name1, name2)==TRUE);
				else if (temp=="no") test_(isNephew(name1, name2)==FALSE);
				else if (temp=="unknown") test_(isNephew(name1, name2)==UNKNOWN);
			}
			else if (relation == "grandfather")
			{
				//print(isGrandfather(name1, name2));
				getline(is, temp);
				if (temp=="yes") test_(isGrandfather(name1, name2)==TRUE);
				else if (temp=="no") test_(isGrandfather(name1, name2)==FALSE);
				else if (temp=="unknown") test_(isGrandfather(name1, name2)==UNKNOWN);
			}
			else if (relation == "grandmother")
			{
				//print(isGrandmother(name1, name2));
				getline(is, temp);
				if (temp=="yes") test_(isGrandmother(name1, name2)==TRUE);
				else if (temp=="no") test_(isGrandmother(name1, name2)==FALSE);
				else if (temp=="unknown") test_(isGrandmother(name1, name2)==UNKNOWN);
			}
			else if (relation == "grandson")
			{
				//print(isGrandson(name1, name2));
				getline(is, temp);
				if (temp=="yes") test_(isGrandson(name1, name2)==TRUE);
				else if (temp=="no") test_(isGrandson(name1, name2)==FALSE);
				else if (temp=="unknown") test_(isGrandson(name1, name2)==UNKNOWN);
			}
			else if (relation == "granddaughter")
			{
				//print(isGranddaughter(name1, name2));
				getline(is, temp);
				if (temp=="yes") test_(isGranddaughter(name1, name2)==TRUE);
				else if (temp=="no") test_(isGranddaughter(name1, name2)==FALSE);
				else if (temp=="unknown") test_(isGranddaughter(name1, name2)==UNKNOWN);
			}
		}

		ss.clear();
	}
}

void test()
{
	stringstream facts, questions;

	// add relationships and questions
	// husband and wife tests
	facts << "van is jean's husband.\n";
	questions << "is jean van's wife?\n" << "yes\n";							// 001
	questions << "is van jean's husband?\n" << "yes\n";						// 002
	facts << "rei is bob's wife.\n";
	questions << "is bob rei's husband?\n" << "yes\n";							// 003
	questions << "is rei bob's wife?\n" << "yes\n";								// 004
	questions << "is jean bob's wife?\n" << "no\n";								// 005
	facts << "gale is ida's father.\n";
	facts << "ida is matilde's daughter.\n";
	questions << "is gale matilde's husband?\n" << "yes\n";					// 006
	questions << "is matilde gale's wife?\n" << "yes\n";						// 007
	facts << "jared is langley's father.\n";
	facts << "dolly is langley's mother.\n";
	questions << "is jared dolly's husband?\n" << "yes\n";					// 008
	questions << "is dolly jared's wife?\n" << "yes\n";						// 009
	facts << "irving is aura's son.\n";
	facts << "irving is abe's son.\n";
	questions << "is abe aura's husband?\n" << "unknown\n";					// 010
	questions << "is aura abe's wife?\n" << "unknown\n";						// 011
	// son and daughter tests
	facts << "elie is melissa's daughter.\n";
	questions << "is elie melissa's daughter?\n" << "yes\n";					// 012
	facts << "laban is miriam's father.\n";
	questions << "is miriam laban's daughter?\n" << "unknown\n";			// 013
	facts << "amon is tilda's father.\n";
	facts << "tilda is steven's mother.\n";
	questions << "is tilda amon's daughter?\n" << "yes\n";					// 014
	facts << "earl is karli's husband.\n";
	facts << "karli is olaf's mother.\n";
	questions << "is olaf earl's son?\n" << "unknown\n";						// 015
	facts << "lacey is isaiah's wife.\n";
	facts << "kaori is isaiah's daughter.\n";
	questions << "is kaori isaiah's daughter?\n" << "yes\n";					// 016
	facts << "marlin is naomi's son.\n";
	facts << "naomi is hilda's mother.\n";
	facts << "hilda is carter's daughter.\n";
	questions << "is marlin carter's son?\n" << "yes\n";						// 017
	facts << "brit is sheba's mother.\n";
	facts << "brit is ben's mother.\n";
	facts << "sancho is sheba's father.\n";
	questions << "is ben sancho's son?\n" << "unknown\n";						// 018
	// mother and father tests
	questions << "is melissa elie's mother?\n" << "unknown\n";				// 019
	questions << "is laban miriam's father?\n" << "yes\n";					// 020
	questions << "is earl olaf's father?\n" << "yes\n";						// 021
	questions << "is carter marlin's father?\n" << "yes\n";					// 022	
	facts << "jake is shelly's son.\n";
	facts << "meg is shelly's son.\n";
	facts << "meg is echo's son.\n";
	questions << "is echo jake's father?\n" << "unknown\n";					// 023
	// niece and nephew tests
	facts << "ilaria is odysseus's daughter.\n";
	facts << "odysseus is jackson's son.\n";
	facts << "jackson is trinity's's father.\n";
	questions << "is ilaria trinity's niece?\n" << "yes\n";					// 024
	facts << "eddie is rebecca's father.\n";
	facts << "ebony is eddie's mother.\n";
	facts << "ebony is garry's's mother.\n";
	questions << "is rebecca garry's niece?\n" << "unknown\n";				// 025
	facts << "kai is teresa's son.\n";
	facts << "teresa is nehor's daughter.\n";
	facts << "nehor is nemu's husband.\n";
	facts << "dale is nemu's son.\n";
	questions << "is kai dale's niece?\n" << "no\n";							// 026
	facts << "iola is oliver's daughter.\n";
	facts << "oliver is trudy's son.\n";
	facts << "calvin is trudy's son.\n";
	facts << "calvin is gale's son.\n";
	facts << "nora is gale's daughter.\n";
	questions << "is iola nora's niece?\n" << "yes\n";							// 027
	// grandfather and grandmother tests
	facts << "polly is mike's mother.\n";
	facts << "debra is mike's daughter.\n";
	questions << "is polly debra's grandmother?\n" << "yes\n";				// 028
	facts << "tiara is osmund's daughter.\n";
	facts << "tiara is paul's mother.\n";
	questions << "is osmund paul's grandfather?\n" << "unknown\n";			// 029
	facts << "becky is hardy's daughter.\n";
	facts << "tabitha is hardy's mother.\n";
	facts << "waldo is tabitha's husband.\n";
	questions << "is waldo becky's grandfather?\n" << "yes\n";				// 030
	facts << "jessica is ulrick's daughter.\n";
	facts << "ulrick is lana's son.\n";
	facts << "nadia is lana's daughter.\n";
	facts << "nadia is vance's daughter.\n";
	questions << "is vance jessica's grandfather?\n" << "unknown\n";		// 031
	facts << "orlando is scarlet's son.\n";
	facts << "samuel is scarlet's son.\n";
	facts << "samuel is burt's son.\n";
	facts << "burt is veronica's son.\n";
	facts << "rachel is veronica's daughter.\n";
	facts << "phil is rachel's father.\n";
	questions << "is phil orlando's grandfather?\n" << "yes\n";				// 032

	// grandson and granddaughter tests
	questions << "is orlando phil's grandson?\n" << "yes\n";					// 033

	facts << "jason is shawna's father.\n";
	facts << "daisy is jason's daughter.\n";
	facts << "daisy is pauline's daughter.\n";
	facts << "elliot is pauline's father.\n";
	facts << "elliot is victor's father.\n";
	facts << "melody is victor's mother.\n";
	questions << "is shawna melody's granddaughter?\n" << "unknown\n";	// 034

	// prepare to run the program
	facts << '\n' << questions.str();

	// answer questions
	testmethod(facts);

	// print the results
	do_report();

	system("pause");
}

int main(int argc, char* argv[])
{
	if (argc == 1) method(cin);
	else method(ifstream(argv[1]));
	//test();

	return EXIT_SUCCESS;
}