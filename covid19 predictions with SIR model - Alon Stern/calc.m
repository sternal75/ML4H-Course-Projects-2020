% simulate SIR model for Covid19
% Author: Alon Stern
% % % % % % % % % % % % % % % % % % % % % 
function result = calc(country)

    % select country to simulate SIR model
    % country = 'Israel';   

    % load constant variables
    load_constants

    % download last updated Corona data from European Centre for Disease
    % Prevention and Control (An agency of the European Union)
    outputExcelFileName = ['ecdc_covid19_' datestr(date) ['.xlsx']];
    websave(outputExcelFileName,'https://www.ecdc.europa.eu/sites/default/files/documents/COVID-19-geographic-disbtribution-worldwide.xlsx');

    % input_data = readtable(outputExcelFileName, 'ReadVariableNames', true);
    % input_data = readtable('ecdc_covid19_20-Aug-2020.xlsx', 'ReadVariableNames', true);
%     input_data = readtable('ecdc_covid19_25-Aug-2020.xlsx', 'ReadVariableNames', true);

    country_indices = find(strcmpi(country, input_data.countriesAndTerritories));   % find the indices of the selected country in the ECDC data file
    country_data = flipud(input_data(country_indices',:));                          % selected country data
    country_data.all_cases = cumsum(country_data.cases);                            % all positive corona cases
    country_data(country_data.all_cases==0,:) = [];                                 % data starts on the first person infected
    I_per_day = country_data.cases;                                                 % number of cases each day
    I_total   = country_data.all_cases;                                             % total infected for each day
    time_in_days  = 1:length(I_total);                                              
    N = country_data.popData2019(1);                                                % population for the SIR model


    %-------------------             %------------------             %-----------------
    % S (Susceptible) --  ==Beta==>  % I (Infections) --  ==Gamma==> % R (Recovered) --
    %-------------------             %------------------             %-----------------

    % curve fitting of cumulative cases, using SIR model
    lb = [0; 0; 0; 0; 0; 0; 0; 0; gamma_lb]; 
    ub = [1; 1; 1; 1; Inf; Inf; Inf; Inf; gamma_ub];
    % initial SIR state values (number of S,I,and R at t=0)
    initial_sir_state_values  = [N-I_per_day(1); I_per_day(1); 0];     

    simulation_length   = length(time_in_days)+number_of_prediction_days; 
    simulated_time      = 1:simulation_length;

    score_vector=inf(9,1);
    fitted_params_array=nan(9,MAX_ITERATIONS);
    for(i=1:MAX_ITERATIONS)
    %     beta_initial_params = [0.2 0.3 0.2 0.2];
    %     time_shift_initial_params = [0 length(I_total)/2 length(I_total)/2];
    %     gain_initial_params = 0.1;
    %     gamma_initial_params = (gamma_lb+gamma_ub)/2;

        % Initial values for 'lsqcurvefit'
        beta_initial_params = [rand() rand() rand() rand()];
        time_shift_1 = rand()*length(I_total)/2;
        time_shift_2 = time_shift_1+rand()*(length(I_total)-time_shift_1);
        time_shift_3 = time_shift_1+rand()*(length(I_total)-time_shift_1);
        time_shift_initial_params = [time_shift_1 time_shift_2 time_shift_3];
        gain_initial_params = rand()*2;
        gamma_initial_params = gamma_lb+rand()*(gamma_ub-gamma_lb);

        initial_fitting_parameters = [beta_initial_params time_shift_initial_params gain_initial_params gamma_initial_params]; 
        % call optimization function to fit the curve
        try
            [fitted_params_array(:,i) score_vector(i)] = fit_cumulative_cases(lb,ub,time_in_days,I_total,initial_fitting_parameters,initial_sir_state_values,N);     
        catch
            fprintf('error in lsqcurvfit\n');
            fitted_params_array(:,i)=nan;
            score_vector(i)=Inf;
        end
        fprintf('Iteration %d finished with score %d\n',i,score_vector(i))
    end

    [best_score best_score_index] = min(score_vector);
    best_fitted_params = fitted_params_array(:,best_score_index);

    result.best_fitted_params=best_fitted_params;
        
    fprintf(1,'\tFitted parameters:\n')
    for i = 1:length(best_fitted_params)
        fprintf(1, '\t\tfitted_param(%d) = %8.5f\n', i, best_fitted_params(i))
    end


    % plot results
    % plot_results
    first_date = country_data.dateRep(1); 
    simulated_SIR_values = solve_sir(best_fitted_params, simulated_time,initial_sir_state_values,N);
    simulated_S             = simulated_SIR_values(:,1);
    simulated_I             = simulated_SIR_values(:,2);
    simulated_R             = simulated_SIR_values(:,3);
    simulated_total_cases   = simulated_I+simulated_R;
    Simulated_N             = simulated_S+simulated_I+simulated_R;

    figure;
    plot_S(simulated_time, simulated_S, simulation_length, first_date);
    figure;
    plot_I(simulated_time, simulated_I, simulation_length, first_date);
    figure;
    plot_R(simulated_time, simulated_R, simulation_length, first_date);
    figure;
    plot_sim_vs_reported(simulated_time, simulated_total_cases, I_total, simulation_length, first_date);
    figure;
    plot_sim_vs_reported_per_day(simulated_time, simulated_total_cases, I_per_day, simulation_length, first_date);
    figure;
    [beta_total beta1 beta2 beta3 beta4] = beta_func(best_fitted_params, simulated_time); 
    hold on;plot(beta1,'r');plot(beta2,'g');plot(beta3,'b');plot(beta4,'y');plot(beta_total,'m');hold off;    
    figure;
    plot_R0(simulated_time, result.best_fitted_params, simulation_length, first_date);
    
    
    
end


