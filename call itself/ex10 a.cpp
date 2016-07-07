#include <stdio.h>
#include <conio.h>
#include <math.h>

int fibonaci(int n)
{
	if(n>2) return fibonaci(n-1)+fibonaci(n-2);
	else return 1;
}
 int main()
 {
 	int i,n,a,b;
 	printf ("enter n: ");
 	scanf("%d",&n);
 	a=0;
 	b=fibonaci(n)*fibonaci(n+1);
 	
	 //cau a
 	for (i=1;i<=n;i++)
 	{
 		a=a+fibonaci(i)*fibonaci(i);	
 	}
 	
 	if(a==b) printf("true\n");
 	else printf("faild");
 	
 	//cau b
 	b=fibonaci(2*n);
 	a=0;
 	for (i=1;i<=2*n;i=i+2)
 	{
 		a=a+fibonaci(i);
 	}
 	if(a==b) printf("true");
 	else printf("faild");
 	getch();
 	return 0;
 }
