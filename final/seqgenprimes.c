#include <math.h>
#include <stdio.h>
#include <stdlib.h>

typedef unsigned int uint;

// GENERATE
int generate( uint N, uint* array ) // Populates an array from 2 to N, assuming an already allocated array space.
{
	for ( uint nth = 0 ; nth < N-2 ; nth++ )
	{
		array[nth] = 2 + nth;
	}
}
//----------------------------------

// SHOOT
int shoot( uint N, uint multipleOf, uint* array ) // Turns every multipleOf value (except for the number itself) into value 0. Again, index[0] is actually the int 2 and increments from there.
{
	for ( uint nth = (multipleOf - 2) + multipleOf ; nth < N-1 ; nth += multipleOf )
	{
		array[nth] = 0;
	}
}
//----------------------------------

// SHOOT-LOOP
int shootLoop( uint N, uint* array ) // Increment through the numbers. If not shot, proceed to shoot using that number. Non-prime numbers will be shot long before they are reached, as can be mathematically induced.
{
	for ( uint loop_index = 0 ; loop_index < floor( ( N + 1 ) / 2 ) ; loop_index++ )
	{
		if ( array[loop_index] != 0 )
		{
			shoot(N, array[loop_index], array);
		}
	}
}
//----------------------------------

// MAIN
int main( int argc, char** argv )
{
	uint N = atol(argv[1]);

	if ( argc != 2 || N <= 2 )
	{
		printf("%s", "Please supply one argument, N, for prime numbers up to N. Naturally, N must be greater than 2 for the output to be significant. Thanks! Here's an example: ./genprimes 20\n");
	}

	else
	{
		uint *array;
		array  = malloc ( sizeof(uint)* (N-1) );
		generate(N, array);
		shootLoop(N, array);
		uint linecount = 0;
		char buffer[1024];
		FILE *outfile;
		snprintf(buffer, sizeof(buffer), "%u.txt", N );
		outfile = fopen(buffer, "a");
		for ( uint i = 0 ; i < N-1 ; i++ )
		{
			if ( array[i] != 0 )
			{
				//linecount++;
				if ( linecount == 10 ) { printf("%s", "\n"); linecount = 0;  }
				fprintf(outfile, "%u ", array[i] );
			}
//			else { printf( "%u\n", array[i] ); }
		}
		printf("%s","\n");
		free(array);
	}

}
