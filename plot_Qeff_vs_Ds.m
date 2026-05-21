function plot_Qeff_vs_Ds(res_Ds)
% PLOT_QEFF_VS_DS  Efektyvios talpos Q_eff priklausomybė nuo difuzijos
%                 koeficiento D_s,p (teigiamas elektrodas).
%
% Grafikas atskleidžia du režimus:
%   - Difuzinio apribojimo zona (mažos D_s,p reikšmės): talpa stipriai
%     mažėja, nes ličio jonai nespėja pasiskirstyti tolygiai dalelėje –
%     paviršiaus koncentracija pasiekia ribą anksčiau nei vidus.
%   - Saturacijos zona (didelės D_s,p reikšmės): tolesnis koeficiento
%     didinimas talpos nebepagerina, nes difuzija nebėra ribojantis veiksnys.
%
% Įvestis:
%   res_Ds - rezultatų struktūra iš run_param_sweep('Ds_p', ...)

    Ds_vals = arrayfun(@(r) r.value, res_Ds.runs);
    Q_vals  = arrayfun(@(r) r.Q_eff, res_Ds.runs);

    figure('Name', 'Q_eff vs D_s,p', 'Color', 'w', 'Position', [200 200 700 450]);
    semilogx(Ds_vals, Q_vals, 'b-o', 'LineWidth', 1.5, 'MarkerSize', 8, ...
             'MarkerFaceColor', [0.2 0.4 0.8]);
    hold on; grid on; box on;

    % Skaitinės reikšmės prie taškų
    text(Ds_vals(1)*1.15, Q_vals(1)-0.04, sprintf('%.3f Ah', Q_vals(1)), ...
         'FontSize', 9, 'VerticalAlignment', 'top');
    text(Ds_vals(2)*1.15, Q_vals(2)+0.02, sprintf('%.3f Ah', Q_vals(2)), ...
         'FontSize', 9, 'VerticalAlignment', 'bottom');
    for k = 3:numel(Ds_vals)
        text(Ds_vals(k)*1.15, Q_vals(k)-0.02, sprintf('%.3f Ah', Q_vals(k)), ...
             'FontSize', 9, 'VerticalAlignment', 'top');
    end

    % Režimų žymėjimas
    text(1.2e-15, 1.75, 'Difuzinio apribojimo zona', ...
         'FontSize', 9, 'Color', [0.8 0.2 0.2]);
    text(2e-14, 1.95, 'Saturacijos zona', ...
         'FontSize', 9, 'Color', [0.2 0.6 0.2]);

    % Vertikali riba tarp režimų
    xline(5e-15, 'k:', 'LineWidth', 1.0, 'HandleVisibility', 'off');

    xlabel('D_{s,p} (m^2/s)', 'FontSize', 11);
    ylabel('Q_{eff} (Ah)', 'FontSize', 11);
    title('Efektyvios talpos priklausomybė nuo difuzijos koeficiento D_{s,p}', ...
          'FontSize', 11);
    set(gca, 'FontSize', 10);
    ylim([0.9, 2.0]);
end
