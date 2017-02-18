function res = filterjava(signal, kernel)
%%


res = zeros(1, length(signal));
for r = 1 : length(res)
    m = min(length(kernel), r);
    for k = 1 : m
        res(r) = res(r) + kernel(k) * signal(r - k + 1);
    end
end