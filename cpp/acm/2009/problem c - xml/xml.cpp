#define DEBUG
#undef DEBUG

#include <stdlib.h>
#include <stdio.h>

int main()
{
	const int MAX_SIZE = 256;
	const int STACK_SIZE = 20;
	char buffer[MAX_SIZE];
	char stack[STACK_SIZE][MAX_SIZE];

	char* cptr;
	int i;
	bool valid;
	int count;
	int sp = 0, sptr = 0;

	do
	{
		valid = true;
		cptr = fgets(buffer, MAX_SIZE, stdin);
		if (cptr != NULL)
		{
			if (cptr[0] == 10 || cptr[1] == 0) break;

			for (i=0; i<MAX_SIZE; i++)
			{
				if (cptr[i] == '<')
				{
					i++;
					if (i>=MAX_SIZE)
					{
						valid = false;
						break;
					} // if
					if (cptr[i] == '/')	// end tag
					{
						sp--;
						sptr = 0;
						while (true)
						{
							i++;
							if (i>=MAX_SIZE)
							{
								valid = false;
								break;
							} // if
							if (cptr[i] == stack[sp][sptr])
							{
								if (cptr[i] == '>')
								{
									sptr = 0;
									stack[sp][sptr] = 0;
									break;
								} // if
								sptr++;
							} // if
							else
							{
								valid = false;
								break;
							} // else
						} // while
					} // if
					else if ((cptr[i] >= 'a' && cptr[i] <= 'z') || (cptr[i] >= '0' && cptr[i] <= '9'))	// open tag
					{
						if (sp >= STACK_SIZE)
						{
							valid = false;
							break;
						} // if
						while (cptr[i] != '>' && cptr[i] != '/')
						{
							if (sptr < MAX_SIZE)
							{
								stack[sp][sptr] = cptr[i];
								i++;
								sptr++;
							} // if
							else
							{
								valid = false;
								break;
							} // else
						} // while
						if (!valid) break;
						if (cptr[i] == '/')
						{
							i++;
							if (i>=MAX_SIZE)
							{
								valid = false;
								break;
							} // if
							if (cptr[i] == '>')
							{
								if (sptr < MAX_SIZE)
								{
									stack[sp][sptr] = cptr[i];
									sptr = 0;
								} // if
								else
								{
									valid = false;
									break;
								} // else
							} // if
							else
							{
								valid = false;
								break;
							} // else
						} // if
						else if (cptr[i] == '>')
						{
							stack[sp][sptr] = cptr[i];
							sptr = 0;
							sp++;
						} // else if
					} // else if
					else
					{
						valid = false;
						break;
					} // else
				} // if
				else if (cptr[i] == '>')
				{
					valid = false;
					break;
				} // else if
				else if (cptr[i] == '&')
				{
					i++;
					if (i>=MAX_SIZE)
					{
						valid = false;
						break;
					} // if
					if (cptr[i] == 'l' || cptr[i] == 'g')
					{
						i++;
						if (i>=MAX_SIZE)
						{
							valid = false;
							break;
						} // if
						if (cptr[i] == 't')
						{
							i++;
							if (i>=MAX_SIZE)
							{
								valid = false;
								break;
							} // if
							if (cptr[i] != ';')
							{
								valid = false;
								break;
							} // if
						} // if
						else
						{
							valid = false;
							break;
						} // else
					} // if
					else if (cptr[i] == 'a')
					{
						i++;
						if (i>=MAX_SIZE)
						{
							valid = false;
							break;
						} // if
						if (cptr[i] == 'm')
						{
							i++;
							if (i>=MAX_SIZE)
							{
								valid = false;
								break;
							} // if
							if (cptr[i] == 'p')
							{
								i++;
								if (i>=MAX_SIZE)
								{
									valid = false;
									break;
								} // if
								if (cptr[i] != ';')
								{
									valid = false;
									break;
								} // if
							} // if
							else
							{
								valid = false;
								break;
							} // else
						} // if
						else
						{
							valid = false;
							break;
						} // else
					} // else if
					else if (cptr[i] == 'x')
					{
						count=0;
						while (true)
						{
							i++;
							if (i>=MAX_SIZE)
							{
								valid = false;
								break;
							} // if
							if (cptr[i] >= '0' && cptr[i] <= '9')
							{
								count++;
							} // if
							else
							{
								break;
							} // else
						} // while
						if ((count == 0) || (count % 2 == 1))
						{
							valid = false;
							break;
						} // if
						else if (cptr[i] != ';')
						{
							valid = false;
							break;
						} // else if
					} // else if
					else
					{
						valid = false;
						break;
					} // else
				} // else if
				else if (cptr[i] < 32 && cptr[i] > 127)
				{
					valid = false;
					break;
				} // else if
				else if (cptr[i] == 0)
				{
					break;
				} // else if
				if (!valid) break;
			} // for
			if (stack[0][0] > 0) valid = false;

			if (valid)
				printf_s("valid\n");
			else
				printf_s("invalid\n");
		} // if
	} while (cptr != NULL);

	return EXIT_SUCCESS;
} // main

