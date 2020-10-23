% sigmoid function with gain and time shift
function sigmoid_func = sigmoid(time,time_shift,gain)
    sigmoid_func = 1./(1 + exp(-gain.*(time-time_shift)));
end
