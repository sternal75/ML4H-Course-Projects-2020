function plot_S(simulated_time, simulated_S, simulation_length, first_date)
    % plot S 
    plot(simulated_time,simulated_S,'linewidth',2)
    xticks(0:simulation_length/10:simulation_length);
%     xlabel('Date','FontWeight','bold');
    xlim([0 simulation_length])
    ylabel('Number of susceptible','FontWeight','bold');
    dateaxis('x', 1, first_date);
    xtickangle(30);
    set(gca,'fontsize',9);
%     set(gcf,'color','w');
    hold on;
    load_constants
    y=ylim;
    plot(polyshape([simulation_length-number_of_prediction_days simulation_length-number_of_prediction_days simulation_length simulation_length], [y(2) y(1) y(1) y(2)]),'FaceColor', [0.5 0.5 0.5], 'FaceAlpha',0.7);
    ylim([y(1) y(2)])
    grid on;
    box on;
    hold off;
end
