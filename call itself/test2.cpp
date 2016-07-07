#include <stdio.h>
#include <conio.h>
#include <math.h>


int fibonaci(int n)
{
	int f;
	if(n<=2) return 1;
	else  return fibonaci(n-1)+fibonaci(n-2);
	
}

int main()
{
	int n;
	printf ("enter N");
	scanf("%d",&n);
	printf("%d ",fibonaci(n));
	getch();
	return 0;
}
