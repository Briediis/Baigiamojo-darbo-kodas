function plot_Qeff_vs_kp(res_kp)
% PLOT_QEFF_VS_KP  Efektyvios talpos Q_eff priklausomybė nuo reakcijos
%                 greičio konstantos k_p (teigiamas elektrodas).
%
% Reakcijos konstanta k_p valdo aktyvacijos peržengimo potencialą eta_p
% per Butlerio-Volmerio kinetikos lygtį. Esant mažoms k_p reikšmėms
% peržengimo potencialas didelis, todėl gnybtų įtampa mažesnė ir celė
% pasiekia atjungimo įtampą anksčiau. Tačiau tipinėms LCO celėms
% (k_p ~ 10^-11 – 10^-10) modelis yra praktiškai nejautrus k_p
% pokyčiams – tai pagrindžia sprendimą šio parametro neoptimizuoti.
%
% Įvestis:
%   res_kp - rezultatų struktūra iš run_param_sweep('kp', ...)

    kp_vals = arrayfun(@(r) r.value, res_kp.runs);
    Q_vals  = arrayfun(@(r) r.Q_eff, res_kp.runs);

    figure('Name', 'Q_eff vs k_p', 'Color', 'w', 'Position', [200 200 700 450]);
    semilogx(kp_vals, Q_vals, 'b-o', 'LineWidth', 1.5, 'MarkerSize', 8, ...
             'MarkerFaceColor', [0.2 0.4 0.8]);
    hold on; grid on; box on;

    % Logaritminė aproksimacija Q_eff(log10(k_p))
    log_kp = log10(kp_vals);
    coeffs = polyfit(log_kp, Q_vals, 1);
    kp_fit = logspace(log10(min(kp_vals)), log10(max(kp_vals)), 100);
    Q_fit  = polyval(coeffs, log10(kp_fit));
    semilogx(kp_fit, Q_fit, 'r--', 'LineWidth', 1.2);

    % Aproksimacijos formulė ant grafiko
    formula = sprintf('Q_{eff} = %.4f \\cdot log_{10}(k_p) + %.3f', ...
                      coeffs(1), coeffs(2));
    text(1e-13, 1.842, formula, 'FontSize', 10, 'Color', 'r');

    % Skaitinės reikšmės prie taškų
    for k = 1:numel(kp_vals)
        text(kp_vals(k)*1.2, Q_vals(k), sprintf('%.3f Ah', Q_vals(k)), ...
             'FontSize', 9, 'VerticalAlignment', 'middle');
    end

    xlabel('k_p', 'FontSize', 11);
    ylabel('Q_{eff} (Ah)', 'FontSize', 11);
    title('Efektyvios talpos priklausomybė nuo reakcijos konstantos k_p', ...
          'FontSize', 11);
    legend('Simuliacijos taškai', 'Logaritminė aproksimacija', 'Location', 'southeast');
    set(gca, 'FontSize', 10);
    ylim([1.835, 1.855]);
end
