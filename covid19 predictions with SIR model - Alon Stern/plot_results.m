first_date = country_data.dateRep(1); 
simulated_SIR_values = solve_sir(best_fitted_params, simulated_time,initial_sir_state_values,N);
simulated_S             = simulated_SIR_values(:,1);
simulated_I             = simulated_SIR_values(:,2);
simulated_R             = simulated_SIR_values(:,3);
simulated_total_cases   = simulated_I+simulated_R;
Simulated_N             = simulated_S+simulated_I+simulated_R;

% plot S 
figure;
plot(simulated_time,simulated_S,'linewidth',2)
xticks(0:simulation_length/10:simulation_length);
xlabel('Date','FontWeight','bold');
xlim([0 simulation_length])
ylabel('Number of susceptible','FontWeight','bold');
dateaxis('x', 17, first_date);
xtickangle(30);
set(gca,'fontsize',16);
set(gcf,'color','w');
grid on;
box on;

% plot I
figure;
plot(simulated_time,simulated_I,'linewidth',2)
xticks(0:simulation_length/10:simulation_length);
xlabel('Date','FontWeight','bold');
xlim([0 simulation_length])
ylabel('Number of currently infected','FontWeight','bold');
dateaxis('x', 17, first_date);
xtickangle(30);
set(gca,'fontsize',16);
set(gcf,'color','w');
grid on;
box on;

% plot R
figure;
plot(simulated_time,simulated_R,'linewidth',2)
xticks(0:simulation_length/10:simulation_length);
xlabel('Date','FontWeight','bold');
xlim([0 simulation_length])
ylabel('Number of recovered (removed)','FontWeight','bold');
dateaxis('x', 17, first_date);
xtickangle(30);
set(gca,'fontsize',16);
set(gcf,'color','w');
grid on;
box on;

% plot simulated vs. reported total cases
figure;
plot(simulated_time,simulated_total_cases,'linewidth',2)
xticks(0:simulation_length/10:simulation_length);
xlabel('Date','FontWeight','bold');
xlim([0 simulation_length])
ylabel('Number of total infected','FontWeight','bold');
hold on
plot(I_total,'*','LineWidth',1, 'Color','red')
legend({'simulated','reported'}, 'FontSize',12);
dateaxis('x', 17, first_date);
xtickangle(30);
set(gca,'fontsize',16);
set(gcf,'color','w');
grid on;
box on;

% plot simulated vs. reported cases per day
figure;
temp_vector = zeros(size(simulated_total_cases));
temp_vector(1)=0;
temp_vector(2:end)=simulated_total_cases(1:end-1);
simulated_daily_cases = simulated_total_cases-temp_vector;
plot(simulated_time,simulated_daily_cases,'linewidth',2)
xticks(0:simulation_length/10:simulation_length);
xlabel('Date','FontWeight','bold');
xlim([0 simulation_length])
ylabel('Number of daily infections','FontWeight','bold');
hold on
plot(I_per_day,'*','LineWidth',1, 'Color','red')
legend({'simulated','reported'}, 'FontSize',12);
dateaxis('x', 17, first_date);
xtickangle(30);
set(gca,'fontsize',16);
set(gcf,'color','w');
grid on;
box on;





%==================================R0======================================
[beta_total beta1 beta2 beta3 beta4] = beta_func(best_fitted_params, simulated_time); 

figure;
hold on;plot(beta1,'r');plot(beta2,'g');plot(beta3,'b');plot(beta4,'y');plot(beta_total,'m');hold off;

R0=beta_total'./best_fitted_params(9);
figure('Color',[1 1 1],'units','normalized','outerposition',[0 0 1 1])
plot(simulated_time,R0, 'linewidth',2)
grid on; grid minor; set(gca,'fontsize',16);
xticks(0:simulation_length/10:simulation_length);
xlabel('Time (day)','FontSize',16,'FontWeight','bold');
xlim([0 simulation_length])
ylabel('Reproduction Number R_0 = \beta/\gamma','FontSize',16,'FontWeight','bold');
dateaxis('x', 17, first_date)

