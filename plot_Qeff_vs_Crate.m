function plot_Qeff_vs_Crate(res_I, p_base)
% PLOT_QEFF_VS_CRATE  Efektyvios talpos Q_eff priklausomybė nuo C-rate.
%
% Atvaizduoja iškrautą talpą iki atjungimo įtampos kaip C-rate funkciją.
% Esant mažoms srovėms gaunama beveik visa nominali talpa; didėjant
% C-rate talpa mažėja dėl difuzinio apribojimo ir didesnių peržengimo
% potencialų (Peukerto efektas).
%
% Įvestis:
%   res_I  - rezultatų struktūra iš run_param_sweep('I', ...)
%   p_base - bazinė parametrų struktūra (reikia Qnom normavimui)

    Qnom   = p_base.Qnom;
    Q_eff  = arrayfun(@(r) r.Q_eff, res_I.runs);
    Crates = arrayfun(@(r) r.value, res_I.runs) / Qnom;

    % --- Tiesinė aproksimacija Q_eff(C-rate) ---
    coeffs = polyfit(Crates, Q_eff, 1);
    Q_pred = polyval(coeffs, Crates);
    R2     = 1 - sum((Q_eff - Q_pred).^2) / sum((Q_eff - mean(Q_eff)).^2);

    fprintf('--- Q_eff vs C-rate aproksimacija ---\n');
    fprintf('Q = %.4f*C-rate + %.4f,  R^2 = %.4f\n', ...
            coeffs(1), coeffs(2), R2);

    C_fit = linspace(min(Crates)*0.9, max(Crates)*1.1, 200);
    Q_fit = polyval(coeffs, C_fit);

    % --- Grafikas ---
    figure('Name', '19 pav. Q_{eff} vs C-rate', 'Color', 'w', ...
           'Position', [220 220 700 450]);

    % Aproksimacijos kreivė
    h_fit = plot(C_fit, Q_fit, 'r--', 'LineWidth', 1.4); hold on;

    % Tik markeriai, be jungiamosios linijos
    h_pts = plot(Crates, Q_eff, 'o', 'MarkerSize', 7, ...
                 'MarkerEdgeColor', [0.1 0.2 0.5], ...
                 'MarkerFaceColor', [0.4 0.6 0.9], ...
                 'LineStyle', 'none');
    grid on; box on;

    formula = sprintf('Q_{eff} = %.3f \\cdot C-rate + %.3f', ...
                      coeffs(1), coeffs(2));
    text(0.04, 0.95, {formula; sprintf('R^2 = %.4f', R2)}, ...
         'Units', 'normalized', 'FontSize', 10, 'Color', 'r', ...
         'VerticalAlignment', 'top');

    % Skaitinės reikšmės prie kiekvieno taško
    for k = 1:numel(Crates)
        text(Crates(k) + 0.05, Q_eff(k), ...
             sprintf('%.3f Ah', Q_eff(k)), ...
             'FontSize', 9, 'VerticalAlignment', 'middle');
    end

    xlabel('C-rate', 'FontSize', 11);
    ylabel('Q_{eff} (Ah)', 'FontSize', 11);
    title('Efektyvios talpos priklausomybė nuo iškrovos C-rate', ...
          'FontSize', 11);
    legend([h_pts, h_fit], {'Simuliacijos taškai', 'Tiesinė aproksimacija'}, ...
           'Location', 'northeast');
    set(gca, 'FontSize', 10);
    xlim([0, max(Crates) * 1.15]);
    ylim([min(Q_eff)*0.93, max(Q_eff)*1.05]);
end
