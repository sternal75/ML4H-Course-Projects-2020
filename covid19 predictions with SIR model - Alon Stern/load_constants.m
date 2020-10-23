% SIR model parameters
% % % % % % % % % % % % % % % % % % % % % % % % % % 

%average number of days to recover from corona
number_of_days_for_corona_recovery = 14;            
%recovery rate (gamma parameter in SIR model)
gamma_lb=1/(number_of_days_for_corona_recovery+1);  
gamma_ub=1/(number_of_days_for_corona_recovery-1);

%number of prediction days
number_of_prediction_days = 10;

%max number of iterations to find global minimum
MAX_ITERATIONS = 50;