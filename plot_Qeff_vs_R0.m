function plot_Qeff_vs_R0(res_R0_sweep)
% PLOT_QEFF_VS_R0  Efektyvios talpos Q_eff priklausomybė nuo vidinės
%                 ominės varžos R0.
%
% Vidinė ominė varža R0 sukelia tiesioginį įtampos kritimą pagal Omo
% dėsnį: delta_V = I * R0. Dėl to didėjant R0 gnybtų įtampa mažėja
% ir atjungimo įtampa pasiekiama šiek tiek anksčiau. Tačiau šis
% poveikis talpai yra nežymus (< 2 %), nes R0 nekeičia OCV kreivės
% formos – tik pastumia visą V(t) profilį žemyn pastoviu dydžiu.
%
% Įvestis:
%   res_R0_sweep - rezultatų struktūra iš run_param_sweep('R0', ...)

    R0_vals = arrayfun(@(r) r.value, res_R0_sweep.runs) * 1000; % Ω → mΩ
    Q_vals  = arrayfun(@(r) r.Q_eff, res_R0_sweep.runs);

    figure('Name', 'Q_eff vs R0', 'Color', 'w', 'Position', [200 200 700 450]);
    plot(R0_vals, Q_vals, 'b-o', 'LineWidth', 1.5, 'MarkerSize', 8, ...
         'MarkerFaceColor', [0.2 0.4 0.8]);
    hold on; grid on; box on;

    % Tiesinė aproksimacija Q_eff(R0)
    coeffs = polyfit(R0_vals, Q_vals, 1);
    R0_fit = linspace(min(R0_vals), max(R0_vals), 100);
    Q_fit  = polyval(coeffs, R0_fit);
    plot(R0_fit, Q_fit, 'r--', 'LineWidth', 1.2);

    % Aproksimacijos formulė ant grafiko
    formula = sprintf('Q_{eff} = %.5f \\cdot R_0 + %.3f', coeffs(1), coeffs(2));
    text(50, 1.822, formula, 'FontSize', 10, 'Color', 'r');

    % Skaitinės reikšmės prie taškų
    for k = 1:numel(R0_vals)
        text(R0_vals(k)+3, Q_vals(k), sprintf('%.3f Ah', Q_vals(k)), ...
             'FontSize', 9, 'VerticalAlignment', 'middle');
    end

    xlabel('R_0 (m\Omega)', 'FontSize', 11);
    ylabel('Q_{eff} (Ah)', 'FontSize', 11);
    title('Efektyvios talpos priklausomybė nuo vidinės ominės varžos R_0', ...
          'FontSize', 11);
    legend('Simuliacijos taškai', 'Tiesinė aproksimacija', 'Location', 'northeast');
    set(gca, 'FontSize', 10);
    ylim([1.80, 1.86]);
end
