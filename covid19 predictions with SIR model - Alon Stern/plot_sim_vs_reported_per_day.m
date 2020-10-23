function plot_sim_vs_reported_per_day(simulated_time, simulated_total_cases, I_per_day, simulation_length, first_date)
    % plot simulated vs. reported cases per day
    temp_vector = zeros(size(simulated_total_cases));
    temp_vector(1)=0;
    temp_vector(2:end)=simulated_total_cases(1:end-1);
    simulated_daily_cases = simulated_total_cases-temp_vector;
    plot(I_per_day,'*','LineWidth',1, 'Color','red')
    xticks(0:simulation_length/10:simulation_length);
%     xlabel('Date','FontWeight','bold');
    xlim([0 simulation_length])
    ylabel('Number of daily infections','FontWeight','bold');
    hold on
    plot(simulated_time,simulated_daily_cases,'linewidth',2,'Color','blue')
    
    dateaxis('x', 1, first_date);
    xtickangle(30);
    set(gca,'fontsize',9);
%     set(gcf,'color','w');
    load_constants
    y=ylim;
    plot(polyshape([simulation_length-number_of_prediction_days simulation_length-number_of_prediction_days simulation_length simulation_length], [y(2) y(1) y(1) y(2)]),'FaceColor', [0.5 0.5 0.5], 'FaceAlpha',0.7);
    legend({'simulated','reported'}, 'FontSize',12, 'Location','northwest');
    ylim([y(1) y(2)])
    grid on;
    box on;
    hold off;
end
