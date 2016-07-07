/*
 * convolution.c
 *
 *  Created on: Nov 24, 2011
 *      Author: toto
 *	Website: http://toto-share.com
 */
#include <math.h>
#include <stdlib.h>
#include <stdio.h>

float *conv(float *A, float *B, int lenA, int lenB, int *lenC);
void printData(char *cvar, float *Data, int lenData);

int main(int argc, char **argv)
{
	float *A, *B, *C;
	int lenA, lenB, lenC;
	int idx;
	int i;

	//get input parameter
	if(argc!=3)
	{
		printf("use command : \n");
		printf("./convolution length_vector1 length_vector_2 \n");
		printf("example : ./convolution 6 4");
		return;
	}
	sscanf(argv[1],"%i", &lenA);
	sscanf(argv[2],"%i", &lenB);
	
	//allocate memeory for input array/vector
	A = (float*) calloc(lenA, sizeof(float));
	B = (float*) calloc(lenB, sizeof(float));

	//fill array/vector A
	idx = 1;
	for(i=0; i<lenA; i++)
	{
		A[i] = (float) idx;
		idx++;
	}

	//fill array/vector B
	for(i=0; i<lenB; i++)
	{
		B[i] = (float) idx;
		idx++;
	}

	//convolution A with B
	C = conv(A, B, lenA, lenB, &lenC);

	//print value of array
	printData("A", A, lenA);
	printData("B", B, lenB);
	printData("C", C, lenC);

	//free allocated memory	
	free(A);
	free(B);
	free(C);
	return(1);
}

//convolution algorithm
float *conv(float *A, float *B, int lenA, int lenB, int *lenC)
{
	int nconv;
	int i, j, i1;
	float tmp;
	float *C;

	//allocated convolution array	
	nconv = lenA+lenB-1;
	C = (float*) calloc(nconv, sizeof(float));

	//convolution process
	for (i=0; i<nconv; i++)
	{
		i1 = i;
		tmp = 0.0;
		for (j=0; j<lenB; j++)
		{
			if(i1>=0 && i1<lenA)
				tmp = tmp + (A[i1]*B[j]);

			i1 = i1-1;
			C[i] = tmp;
		}
	}
	
	//get length of convolution array	
	(*lenC) = nconv;
	
	//return convolution array
	return(C);
}

//print data
void printData(char *cvar, float *Data, int lenData)
{
	int i;

	printf("Vector '%s' , Size=%i \n", cvar, lenData);
	for(i=0; i<lenData; i++)
		printf("%5.3f \t", Data[i]);

	printf("\n\n");
}