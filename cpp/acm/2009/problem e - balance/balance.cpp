#include <stdlib.h>
#include <stdio.h>

int main()
{
	int NINSTR, NTERMS, NREBAL;
	double instr[10];
	double ffee[10];
	double pfee[10];
	double principal[10];

	int i, j;
	double t, d;

	scanf_s("%d %d %d", &NINSTR, &NTERMS, &NREBAL);

	for (i=0; i<NINSTR; i++)	scanf_s("%lf", &ffee[i]);
	for (i=0; i<NINSTR; i++)	scanf_s("%lf", &pfee[i]);
	for (i=0; i<NINSTR; i++)	scanf_s("%lf", &instr[i]);

	t = 0.0;
	for (i=0; i<NINSTR; i++)	t += instr[i];
	for (i=0; i<NINSTR; i++)	principal[i] = instr[i] / t;

	for (i=0; i<NTERMS; i++)
	{
		for (j=0; j<NINSTR; j++)
		{
			scanf_s("%lf", &t);
			d = (t - pfee[j]) * instr[j] - ffee[j];
			instr[j] += d;
			if (instr[j] < 0.0) instr[j] = 0.0;
		} // for

		if ((i > 0) && (i < NTERMS - 1) && (i % NREBAL == NREBAL - 1))
		{
			t = 0.0;
			for (j=0; j<NINSTR; j++)	t += instr[j];
			for (j=0; j<NINSTR; j++)	instr[j] = t * principal[j];
		} // if
	} // for

	for (i=0; i<NINSTR; i++)	printf("%1.2lf ", instr[i]);

	return EXIT_SUCCESS;
} // main
