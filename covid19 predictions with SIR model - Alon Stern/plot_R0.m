function plot_R0(simulated_time, best_fitted_params, simulation_length, first_date)
    [beta_total beta1 beta2 beta3 beta4] = beta_func(best_fitted_params, simulated_time); 
% figure;
% hold on;plot(beta1,'r');plot(beta2,'g');plot(beta3,'b');plot(beta4,'y');plot(beta_total,'k','LineWidth',3);hold off;    
% legend({'Beta0 (start of outbreak)','Beta1 (Government measures at t1)', 'Beta2 (Government measures at t2)','Beta3 (Government measures at t3)','Final Beta (sum of beta0-bate4'}, 'FontSize',11);
% grid on; 
% xticks(0:simulation_length/6:simulation_length);
% xlim([0 simulation_length])
% ylabel('Infection rate','FontWeight','bold');
% dateaxis('x', 1, first_date);
% xtickangle(30);
% set(gca,'fontsize',9);

    
    R0=beta_total'./best_fitted_params(9);
%     hold on
    plot(simulated_time,R0, 'linewidth',2)
    grid on; 
    xticks(0:simulation_length/6:simulation_length);
    xlim([0 simulation_length])
    yticks(0:1:1+floor(max(R0)));
    ylabel('Reproduction Number R_0 = \beta/\gamma','FontWeight','bold');
    dateaxis('x', 1, first_date);
    xtickangle(30);
    set(gca,'fontsize',9);
    line([1 length(simulated_time)],[1 1],'Color','red','LineStyle','-.');
    hold on;
    load_constants
    y=ylim;
    plot(polyshape([simulation_length-number_of_prediction_days simulation_length-number_of_prediction_days simulation_length simulation_length], [y(2) y(1) y(1) y(2)]),'FaceColor', [0.5 0.5 0.5], 'FaceAlpha',0.7);
    ylim([y(1) y(2)])
    hold off;
%     hold off;
end
