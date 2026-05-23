function plot_Qeff_vs_R0(res_R0_sweep)
% PLOT_QEFF_VS_R0  Efektyvios talpos Q_eff priklausomybė nuo vidinės
%                 ominės varžos R0.
%
% Vidinė ominė varža R0 sukelia tiesioginį įtampos kritimą pagal Omo
% dėsnį: delta_V = I * R0. Dėl to didėjant R0 gnybtų įtampa mažėja
% ir atjungimo įtampa pasiekiama šiek tiek anksčiau. Šis poveikis
% talpai yra nežymus (< 2 %), nes R0 nekeičia OCV kreivės formos –
% tik pastumia visą V(t) profilį žemyn pastoviu dydžiu.
%
% Skripte palyginamos tiesinė ir kvadratinė aproksimacijos pagal R^2;
% grafike vaizduojama ta, kurios R^2 didesnis. Abu rezultatai
% išspausdinami į komandinį langą.
%
% Įvestis:
%   res_R0_sweep - rezultatų struktūra iš run_param_sweep('R0', ...)

    R0_vals = arrayfun(@(r) r.value, res_R0_sweep.runs) * 1000; % Ω → mΩ
    Q_vals  = arrayfun(@(r) r.Q_eff, res_R0_sweep.runs);

    SS_tot = sum((Q_vals - mean(Q_vals)).^2);

    % --- Tiesinė aproksimacija ---
    coeffs_lin = polyfit(R0_vals, Q_vals, 1);
    Q_pred_lin = polyval(coeffs_lin, R0_vals);
    R2_lin     = 1 - sum((Q_vals - Q_pred_lin).^2) / SS_tot;

    % --- Kvadratinė aproksimacija ---
    coeffs_quad = polyfit(R0_vals, Q_vals, 2);
    Q_pred_quad = polyval(coeffs_quad, R0_vals);
    R2_quad     = 1 - sum((Q_vals - Q_pred_quad).^2) / SS_tot;

    fprintf('--- Q_eff vs R_0 aproksimacijų palyginimas ---\n');
    fprintf('Tiesinė:    Q = %.5f*R0 + %.4f                R^2 = %.4f\n', ...
            coeffs_lin(1), coeffs_lin(2), R2_lin);
    fprintf('Kvadratinė: Q = %.2e*R0^2 + %.5f*R0 + %.4f    R^2 = %.4f\n', ...
            coeffs_quad(1), coeffs_quad(2), coeffs_quad(3), R2_quad);

    % Pasirenkama aproksimacija su geresniu R^2
    if R2_quad > R2_lin
        coeffs  = coeffs_quad;
        R2_best = R2_quad;
        is_quad = true;
        fprintf('Pasirinkta: kvadratinė\n');
    else
        coeffs  = coeffs_lin;
        R2_best = R2_lin;
        is_quad = false;
        fprintf('Pasirinkta: tiesinė\n');
    end

    R0_fit = linspace(min(R0_vals), max(R0_vals), 200);
    Q_fit  = polyval(coeffs, R0_fit);

    % --- Grafikas ---
    figure('Name', 'Q_eff vs R0', 'Color', 'w', 'Position', [200 200 700 450]);

    % Aproksimacijos kreivė
    h_fit = plot(R0_fit, Q_fit, 'r--', 'LineWidth', 1.4); hold on;

    % Tik markeriai, be jungiamosios linijos
    h_pts = plot(R0_vals, Q_vals, 'o', 'MarkerSize', 8, ...
                 'MarkerEdgeColor', [0.1 0.2 0.5], ...
                 'MarkerFaceColor', [0.2 0.4 0.8], ...
                 'LineStyle', 'none');
    grid on; box on;

    % Aproksimacijos formulė ir R^2
    if is_quad
        formula = sprintf('Q_{eff} = %.2e \\cdot R_0^2 + %.5f \\cdot R_0 + %.3f', ...
                          coeffs(1), coeffs(2), coeffs(3));
        leg_fit = 'Kvadratinė aproksimacija';
    else
        formula = sprintf('Q_{eff} = %.5f \\cdot R_0 + %.3f', ...
                          coeffs(1), coeffs(2));
        leg_fit = 'Tiesinė aproksimacija';
    end

    text(0.04, 0.95, {formula; sprintf('R^2 = %.4f', R2_best)}, ...
         'Units', 'normalized', 'FontSize', 10, 'Color', 'r', ...
         'VerticalAlignment', 'top');

    % Skaitinės reikšmės prie taškų
    for k = 1:numel(R0_vals)
        text(R0_vals(k)+3, Q_vals(k), sprintf('%.3f Ah', Q_vals(k)), ...
             'FontSize', 9, 'VerticalAlignment', 'middle');
    end

    xlabel('R_0 (m\Omega)', 'FontSize', 11);
    ylabel('Q_{eff} (Ah)', 'FontSize', 11);
    title('Efektyvios talpos priklausomybė nuo vidinės ominės varžos R_0', ...
          'FontSize', 11);
    legend([h_pts, h_fit], {'Simuliacijos taškai', leg_fit}, ...
           'Location', 'northeast');
    set(gca, 'FontSize', 10);
    ylim([1.80, 1.86]);
end
