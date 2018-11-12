// Michael Lukiman at the Courant Institute
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
typedef unsigned int uint;

// GENERATE - PARALLEL VERSION
__global__ void generate( uint N, uint* array ) // Populates an array from 2 to N, assuming an already allocated array space.
{
	uint ind = blockDim.x * blockIdx.x + threadIdx.x;
	uint stride = blockDim.x * gridDim.x;

	for ( uint nth = ind ; nth < N-1 ; nth += stride )
	{
		array[nth] = 2 + nth;
	}
}
//----------------------------------


// SHOOT-LOOP - PARALLEL VERSION
__global__ void shootLoop( uint N, uint* array, uint numBlocks, uint threadsPerBlock, uint limit ) // Increment through the numbers. If not shot, proceed to shoot using that number. Non-prime numbers will be shot long before they are reached, as can be mathematically induced.
{
	
	uint ind = blockDim.x * blockIdx.x + threadIdx.x;
	uint stride = blockDim.x * gridDim.x;
	
	for ( uint loop_index = ind ; loop_index < limit; loop_index+=stride )
	{
		uint current = array[loop_index];
		if ( current != 0 )
		{
			for ( uint nth = (current-2)+current; nth < N-1; nth+=current) 
			{
				array[nth] = 0;
			}
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
		uint numBlocks = (N + 256 - 2) / 256;
		uint threadsPerBlock = 256;
		uint *device_array;
		uint limit = (N+1) / 2;
		cudaMalloc((void **)&device_array, (N-1)*sizeof(uint));
		cudaMemset(device_array, 0, (N-1)*sizeof(uint));
		generate<<<numBlocks, threadsPerBlock>>>(N, device_array);
		cudaDeviceSynchronize();	
		shootLoop<<<numBlocks,threadsPerBlock>>>(N, device_array, numBlocks, threadsPerBlock, limit);
		cudaDeviceSynchronize();
		uint * host_array = new uint[N-1];	
		cudaMemcpy(host_array, device_array, sizeof(uint) * (N-1), cudaMemcpyDeviceToHost);
		char buffer[1024];
		FILE *outfile;
		snprintf(buffer, sizeof(buffer), "%u.txt", N);
		outfile = fopen(buffer, "a");
		for ( uint i = 0 ; i < N-1 ; i++ )
		{
			if ( host_array[i] != 0 )
			{
				fprintf(outfile, "%u ", host_array[i] );
			}
		//	else { printf( "%u\n", host_array[i] ); }
		}
		cudaFree(device_array);
		delete [] host_array;
	}
	return 1;
}
