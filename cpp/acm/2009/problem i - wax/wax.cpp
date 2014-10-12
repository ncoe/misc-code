#include <stdlib.h>
#include <stdio.h>

int main()
{
	int width, height, door, workers;
	double x, y;
	double area, warea;

	do
	{
		scanf_s("%d %d %d %d", &width, &height, &door, &workers);
		if (width == 0 && height == 0 && door == 0 && workers == 0) break;

		area = width * height;
		warea = area / workers;

		x = width;
		y = 0;

		for (int i = 1; i<workers; i++)
		{
			if (y == 0)
			{
				if (warea < (width - door) * height / 2)
				{
					y = 2 * warea / (width - door);
				} // if
				else
				{
					x = 2 * width - door - 2 * warea / height;
					y = height;
				} // else
			} // if
			else if (y == height)
			{
				if (warea < x * height / 2)
				{
					x = x - 2 * warea / height;
				} // if
				else
				{
					y = height - (2 * warea - x * height) / door;
					x = 0;
				} // else
			} // else if
			else if (x == 0)
			{
				y = y - 2 * warea / door;
			} // else if
			else if (x == width)
			{
				if (warea < (width - door) * (height - y) / 2)
				{
					y = 2 * warea / (width - door) + y;
				} // if
				else
				{
					x = width - (2 * warea - (width - door) * (height - y)) / height;
					y = height;
				} // else
			} // else if

			printf_s("%1.3lf %1.3f ", x, y);
		} // for
		printf_s("\n");

	} while (true);

	return EXIT_SUCCESS;
} // main

