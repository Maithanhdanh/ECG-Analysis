function window = blackmanwindow (order)
%% from order filter, this function calculates the length of the coefficient


window = zeros(1, order);
factor = pi / (order - 1);

for i = 1 : length(window)
    window(i) = 0.42 - (0.5 * cos(2 * factor * i)) + ...
        (0.08 * cos(4 * factor *i));
end
end
 