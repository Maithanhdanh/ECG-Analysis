#include <math.h>
#include <stdlib.h>
#include <stdio.h>

//convolution
 float *conv(float *A, float *B, int lenA, int lenB, int *lenC);
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

//Highpass filter
float hpf (float data, int n)
{
	if(n<1) 
		return daf(n)= -data(n);
	else if(n<16)
		return daf(n)= -data(n) + daf(n-1);
	else if(n<17)
		return daf(n)= -data(n) + 32*data(n-16) + daf(n-1);
	else if(n<32)
		return daf(n)= -data(n) + 32*data(n-16) - 32*data(n-17) + daf(n-1);
	else return daf(n)= -data(n) + 32*data(n-16) - 32*data(n-17) + data(n-32) + daf(n-1);
}

//Lowpass filter
float lpf (float data, int n)
{
	if(n<1)
		return daf(n)= data(n);
	else if(n<2)
		return daf(n)= data(n) + 2*daf(n-1);
	else if(n<6)
		return daf(n)= data(n) + 2*daf(n-1) - daf(n-2);
	else if(n<12)
		return daf(n)= data(n) - 2*data(n-6) + 2*daf(n-1) - daf(n-2);
	else return daf(n)= data(n) - 2*data(n-6) + data(n-12) + 2*daf(n-1) - daf(n-2);
}

//find max
float max(float data)
{
	
}