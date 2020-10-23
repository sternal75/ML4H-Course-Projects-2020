function [beta_total beta1 beta2 beta3 beta4] = beta_func(parameters, time)
    beta1  = parameters(1)*(sigmoid(time,0, -parameters(8)));
    beta2  = parameters(2)*(sigmoid(time,parameters(5), parameters(8)));
    beta3  = -parameters(3)*(sigmoid(time,parameters(6), parameters(8)));
    beta4  = parameters(4)*(sigmoid(time,parameters(7), parameters(8)));            
    
    beta_total   = beta1+beta2+beta3+beta4;
end

