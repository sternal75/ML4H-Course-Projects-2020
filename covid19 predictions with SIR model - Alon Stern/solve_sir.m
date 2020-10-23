function result = solve_sir(params,time,initial_sir_state_values,N)
    [~,result] = ode45(@(time,initial_sir_state_values)ode_func(N,params,time,initial_sir_state_values),time,initial_sir_state_values);
end


function dSIRdt=ode_func(N,params,time,sir_state_values)            
        [beta_total beta1 beta2 beta3 beta4] = beta_func(params, time);             

        dSIRdt    = zeros(3,1);
        % dS/dt
        dSIRdt(1) = -beta_total/N*sir_state_values(1)*sir_state_values(2);
        % dI/dt
        dSIRdt(2) = beta_total/N*sir_state_values(1)*sir_state_values(2)-params(9)*sir_state_values(2);         
        % dR/dt
        dSIRdt(3) = params(9)*sir_state_values(2);                           
end

