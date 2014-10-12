#include <stdlib.h>
#include <stdio.h>
#include <math.h>

struct tower
{
	int x;
	int y;
	int r;
}; // tower

int main()
{
	const double step = 0.1;

	int iN, i;
	tower T[100];
	int C0X, C0Y, C1X, C1Y;
	double dCover, dlength;
	double x, y, dx, dy, dl;

	do
	{
		dCover=0.0;
		dlength=0.0;
		scanf_s("%i", &iN);

		if (iN > 0)
		{
			scanf_s("%i %i %i %i", &C0X, &C0Y, &C1X, &C1Y);

			for (i=0; i<iN; i++)
			{
				scanf_s("%i %i %i", &T[i].x, &T[i].y, &T[i].r);
			} // for

			x = C0X;
			y = C0Y;
			dx = (0.0 + C1X - C0X) / 20000;
			dy = (0.0 + C1Y - C0Y) / 20000;
			dl = sqrt((dx*dx) + (dy*dy));
			dlength = sqrt((0.0 + C1X - C0X) * (C1X - C0X) + (C1Y - C0Y) * (C1Y - C0Y));

			while (((x-C1X)*(x-C1X)+(y-C1Y)*(y-C1Y)) > 0.1)
			{
				for (i=0; i<iN; i++)
				{
					if (((x-T[i].x)*(x-T[i].x)+(y-T[i].y)*(y-T[i].y)) < (T[i].r*T[i].r))
					{
						dCover = dCover + dl;
						break;
					} // if
				} // for

				x = x + dx;
				y = y + dy;
			} // while
			dCover = dCover / dlength * 100;
			printf_s("%1.2lf\n", dCover);
		} // if
	} while (iN > 0);

	return EXIT_SUCCESS;
} // main

