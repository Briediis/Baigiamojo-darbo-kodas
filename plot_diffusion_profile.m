function plot_diffusion_profile(res_Ds)
% PLOT_DIFFUSION_PROFILE  Difuzinio apribojimo poveikio analizė.
%
% Du paneliai:
%
%   (a) Teigiamo elektrodo paviršiaus stoichiometrija x_{p,surf}(t)
%       skirtingoms D_{s,p} reikšmėms. Esant mažam difuzijos koeficientui
%       paviršius greičiau prisotinamas ličiu ir atjungimo įtampa
%       pasiekiama anksčiau.
%
%   (b) Skirtumas tarp paviršiaus ir vidutinės stoichiometrijos:
%       delta_x_p = x_{p,surf} - x_{p,avg}. Didelė delta_x_p rodo stiprų
%       difuzinį apribojimą – paviršius prisotinamas, kai dalelės vidus
%       dar turi laisvų intercaliacijos vietų.
%
% Įvestis:
%   res_Ds - rezultatų struktūra iš run_param_sweep('Ds_p', ...)

    figure('Name', '13 pav. Difuzijos profilio analizė', ...
           'Color', 'w', 'Position', [220 220 1150 430]);

    colors = lines(numel(res_Ds.runs));
    leg_txt = cell(numel(res_Ds.runs), 1);

    for k = 1:numel(res_Ds.runs)
        leg_txt{k} = sprintf('D_{s,p} = %.0e m^2/s', res_Ds.runs(k).value);
    end

    %% --- (a) Paviršiaus stoichiometrija ---
    subplot(1, 2, 1);
    hold on; grid on; box on;
    for k = 1:numel(res_Ds.runs)
        r = res_Ds.runs(k);
        plot(r.t/60, r.sim.x_surf_p(1:numel(r.t)), ...
             'Color', colors(k,:), 'LineWidth', 1.3);
    end
    xlabel('Laikas (min)', 'FontSize', 11);
    ylabel('x_{p,surf}', 'FontSize', 11);
    title('(a) Teig. el. paviršiaus stoichiometrija x_{p,surf}(t)', ...
          'FontSize', 11);
    legend(leg_txt, 'Location', 'best', 'FontSize', 8);
    set(gca, 'FontSize', 10);

    %% --- (b) Skirtumas tarp paviršiaus ir vidutinės stoichiometrijos ---
    subplot(1, 2, 2);
    hold on; grid on; box on;
    for k = 1:numel(res_Ds.runs)
        r = res_Ds.runs(k);
        n = numel(r.t);
        delta_x = r.sim.x_surf_p(1:n) - r.sim.x_avg_p(1:n);
        plot(r.t/60, delta_x, 'Color', colors(k,:), 'LineWidth', 1.3);
    end
    xlabel('Laikas (min)', 'FontSize', 11);
    ylabel('\Deltax_p = x_{p,surf} - x_{p,avg}', 'FontSize', 11);
    title('(b) Paviršiaus ir vidutinės stoich. skirtumas \Deltax_p(t)', ...
          'FontSize', 11);
    legend(leg_txt, 'Location', 'best', 'FontSize', 8);
    set(gca, 'FontSize', 10);

    if exist('sgtitle', 'file')
        sgtitle('Difuzinio apribojimo poveikis paviršinei stoichiometrijai', ...
                'FontSize', 11, 'FontWeight', 'bold');
    end
end
