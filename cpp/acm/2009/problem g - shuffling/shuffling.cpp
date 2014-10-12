#include <stdlib.h>
#include <stdio.h>

int main()
{
	const int MAX_CARDS = 520;

	int N, i, shuffles;
	int order[MAX_CARDS];
	int input[MAX_CARDS];
	int output[MAX_CARDS];
	int tmp[MAX_CARDS];
	bool success = false;

	do
	{
		scanf_s("%d", &N);
		if (N == 0) break;

		for (i=0; i<N; i++)	// read suffling order
		{
			scanf_s("%d", &order[i]);
		} // for

		for (i=0; i<N; i++)	// read desired shuffling
		{
			scanf_s("%d", &input[i]);
			output[i] = i + 1;
		} // for

		success = false;
		shuffles = 0;
		while (!success)
		{
			for (i=0; i<N; i++)	tmp[i] = output[order[i] - 1];	// shuffle
			for (i=0; i<N; i++)	output[i] = tmp[i];					// restore
			shuffles++;

			success = true;
			for (i=0; i<N; i++)
			{
				if (output[i] != input[i])
				{
					success = false;
					break;
				} // if
			} // for
			if (success) break;

			success = true;
			for (i=0; i<N; i++)
			{
				if (output[i] != i + 1)
				{
					success = false;
					break;
				} // if
			} // for
			if (success) shuffles = -1;
		} // while

		printf_s("%d\n", shuffles);
	} while (N > 0);

	return EXIT_SUCCESS;
} // main
