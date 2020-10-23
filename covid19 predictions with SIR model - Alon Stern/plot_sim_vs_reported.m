function plot_sim_vs_reported(simulated_time, simulated_total_cases, I_total, simulation_length, first_date)
    % plot simulated vs. reported total cases
    plot(I_total,'*','LineWidth',1, 'Color','red')
    
    xticks(0:simulation_length/10:simulation_length);
%     xlabel('Date','FontWeight','bold');
    xlim([0 simulation_length])
    ylabel('Number of total infected','FontWeight','bold');
    hold on
    plot(simulated_time,simulated_total_cases,'linewidth',2,'Color','blue')
    
    dateaxis('x', 1, first_date);
    xtickangle(30);
    set(gca,'fontsize',9);
%     set(gcf,'color','w');
    hold on;
    load_constants
    y=ylim;
    plot(polyshape([simulation_length-number_of_prediction_days simulation_length-number_of_prediction_days simulation_length simulation_length], [y(2) y(1) y(1) y(2)]),'FaceColor', [0.5 0.5 0.5], 'FaceAlpha',0.7);
    legend({'simulated','reported'}, 'FontSize', 12, 'Location','northwest');
    ylim([y(1) y(2)])
    grid on;
    box on;
    hold off;
    hold off;
end
