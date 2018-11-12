// Michael Lukiman at the Courant Institute
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
typedef unsigned int uint;

// GENERATE - PARALLEL VERSION
__global__ void generate( uint N, uint* array ) // Populates an array from 2 to N, assuming an already allocated array space.
{
	int ind = blockDim.x * blockIdx.x + threadIdx.x;
	int stride = blockDim.x * gridDim.x;

	for ( int nth = ind ; nth < N-1 ; nth += stride )
	{
		array[nth] = 2 + nth;
	}
}
//----------------------------------

// SHOOT - PARALLEL VERSION
__global__ void shoot( uint N, uint multipleOf, uint* array, int limit ) // Turns every multipleOf value (except for the number itself) into value 0. Again, index[0] is actually the int 2 and increments from there.
{
	int ind = blockDim.x * blockIdx.x + threadIdx.x;
	int stride = blockDim.x * gridDim.x;

	while (multipleOf < limit) {
		for ( int nth = (multipleOf-2) + (multipleOf*(ind+1)) ; nth < N-1 ; nth += multipleOf*(stride+1) )
		{	
			array[nth]=0;
		}
		multipleOf++;
	}
}
//----------------------------------

// SHOOT-LOOP
void shootLoop( uint N, uint* array, uint numBlocks, uint threadsPerBlock ) // Increment through the numbers. If not shot, proceed to shoot using that number. Non-prime numbers will be shot long before they are reached, as can be mathematically induced.
{
	int limit = floor( (N+1) / 2); 	
	int multipleGroups = limit/16;
	shoot<<<numBlocks, threadsPerBlock, 0>>>(N, 2, array, multipleGroups);		
	for (int stream = 1; stream < 16; stream++) {
		shoot<<<numBlocks, threadsPerBlock, stream>>>(N, multipleGroups * stream, array, multipleGroups * (stream+1));		
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
		cudaSetDevice(2);
		cudaMalloc((void **) &device_array, (N-1)*sizeof(uint));
		cudaMemset(device_array, 0, (N-1)*sizeof(uint));
		generate<<<numBlocks, threadsPerBlock>>>(N, device_array);
		cudaDeviceSynchronize();	
		shootLoop(N, device_array, numBlocks, threadsPerBlock);
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
	return 0;
}
