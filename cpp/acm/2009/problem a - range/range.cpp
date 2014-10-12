#include <stdlib.h>
#include <stdio.h>

int main()
{
	int iResult=0;
	double dDistT=0.0, dFuelT=0.0;
	double dDistP=0.0, dFuelP=0.0;
	double dDistR=0.0, dFuelR=0.0;

	do
	{
		scanf_s("%lf %lf", &dDistR, &dFuelR);

		if ((dDistR > 0.0) && (dFuelR > 0.0))
		{
//			printf_s("dp: %1.1lf\tfp: %1.1lf\n", dDistP, dFuelP);	//debug code
//			printf_s("dr: %1.1lf\tfr: %1.1lf\n", dDistR, dFuelR);	//debug code
			if (dFuelR < dFuelP)
			{
//				printf_s("dD: %1.1lf\t", dDistR-dDistP);				// debug code

				dDistT+=dDistR-dDistP;
				dDistP=dDistR;

//				printf_s("dF: %1.1lf\n", dFuelR-dFuelP);				// debug code

				dFuelT+=dFuelR-dFuelP;
				dFuelP=dFuelR;
			} // if
			else if (dFuelR > dFuelP)
			{
				dDistP=dDistR;
				dFuelP=dFuelR;
			} // else if
			else if ((dDistP == 0.0) && (dFuelP == 0.0))
			{
				dDistP=dDistR;
				dFuelP=dFuelR;
			} // else
		} // if
		else if ((dDistR == 0.0) && (dFuelR == 0.0))
		{
			dDistT=-dFuelP*(dDistT/dFuelT)+0.5;
			dDistT = (int)dDistT;
			printf_s("%1.0lf\n", dDistT);

			dDistT=0.0;
			dDistP=0.0;
			dDistR=0.0;
			dFuelT=0.0;
			dFuelP=0.0;
			dFuelR=0.0;
		} // if
	} 	while ((dDistR >= 0.0) && (dFuelR >= 0.0));

	return EXIT_SUCCESS;
} // main
