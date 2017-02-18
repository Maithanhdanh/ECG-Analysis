function ker = lowpasskernel(order, cutofffreq, window)
%% this function calculates coefficients of cutoffrequency

ker = zeros(1, order + 1);
factor = 2 * pi * cutofffreq;
sum = 0;

for i = 1 : length(ker)
   d = i - length(ker)/2;
   if d==0
       ker(i) = factor;
   else
       ker(i) = sin(factor * d)/d;
   end
    ker(i) = ker(i) * window(i);
    sum = sum + ker(i);
end
%% normalize the kernel
    for i = 1 : length(ker)
        ker(i) = ker(i)/sum;
    end
end