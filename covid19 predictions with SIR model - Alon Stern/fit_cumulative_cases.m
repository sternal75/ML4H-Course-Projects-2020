function [fitted_params resnorm] = fit_cumulative_cases(lb,ub,time_in_days,I_total,initial_fitting_parameters,initial_sir_state_values,N)
    %options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt','Display', 'iter','FunctionTolerance',1e-15,'MaxFunctionEvaluations',100000*2,'MaxIterations',500,'OptimalityTolerance',1e-15); 
    options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt','FunctionTolerance',1e-15,'MaxFunctionEvaluations',100000*2,'MaxIterations',500,'OptimalityTolerance',1e-15); 

    % call curve fitting optimization
    [fitted_params,resnorm,residual,exitflag,output] = lsqcurvefit(@(initial_fitting_parameters,time_in_days)opt_function(initial_fitting_parameters,time_in_days,initial_sir_state_values,N),initial_fitting_parameters,time_in_days,I_total, lb, ub, options);    
end

function simulated_total_cases = opt_function(params,time,initial_sir_state_values,N)
    result = solve_sir(params,time,initial_sir_state_values,N);
    simulated_total_cases = result(:,2)+result(:,3);
end
