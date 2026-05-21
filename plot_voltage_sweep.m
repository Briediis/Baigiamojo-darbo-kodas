function plot_voltage_sweep(res, param_label, unit_str, fig_title)
% PLOT_VOLTAGE_SWEEP  Gnybtų įtampos profiliai V(t) skirtingoms
%                    parametro reikšmėms.
%
% Vienoje figūroje atvaizduojamos n kreivės (po vieną kiekvienai
% parametro reikšmei) ir punktyrinė atjungimo įtampos linija.
% Naudojama parametrų įtakos tyrime (3 skyrius).
%
% Įvestis:
%   res         - rezultatų struktūra iš run_param_sweep.m
%   param_label - LaTeX formato parametro pavadinimas
%                 (pvz., 'D_{s,p}', 'R_0', 'k_p', 'I')
%   unit_str    - matavimo vienetas (pvz., 'm^2/s', 'm\Omega', '', 'A')
%   fig_title   - figūros pavadinimas

    figure('Name', fig_title, 'Color', 'w', 'Position', [200 200 850 520]);
    hold on; grid on; box on;

    colors = lines(numel(res.runs));
    leg_txt = cell(numel(res.runs), 1);

    for k = 1:numel(res.runs)
        r = res.runs(k);
        plot(r.t/60, r.V, 'Color', colors(k,:), 'LineWidth', 1.5);

        % Legendos formatas pagal parametro tipą
        switch res.param_name
            case 'R0'
                leg_txt{k} = sprintf('%s = %.1f %s', param_label, ...
                                     r.value*1000, unit_str);
            case 'I'
                leg_txt{k} = sprintf('%s = %.1f %s (%.1f C)', ...
                                     param_label, r.value, unit_str, r.value/2);
            otherwise
                leg_txt{k} = sprintf('%s = %s %s', param_label, ...
                                     format_sci(r.value), unit_str);
        end
    end

    % Atjungimo įtampos linija
    xl = xlim;
    plot(xl, [2.7 2.7], 'k--', 'LineWidth', 1.0, 'HandleVisibility', 'off');
    text(xl(1) + 0.02*(xl(2)-xl(1)), 2.76, 'V_{cutoff} = 2.7 V', ...
         'FontSize', 9, 'Color', [0.4 0.4 0.4]);

    xlabel('Laikas (min)', 'FontSize', 11);
    ylabel('V(t), V', 'FontSize', 11);
    title(sprintf('V(t) priklausomybė nuo %s', param_label), 'FontSize', 11);
    legend(leg_txt, 'Location', 'best', 'FontSize', 9);
    set(gca, 'FontSize', 10);
end

% ------------------------------------------------------------------
function s = format_sci(val)
% Formatuoja skaičių moksliniu žymėjimu: pvz. 1e-14 → "10^{-14}"
    if val == 0
        s = '0';
        return;
    end
    exp_val = floor(log10(abs(val)));
    mantissa = val / 10^exp_val;
    if abs(mantissa - 1) < 1e-3
        s = sprintf('10^{%d}', exp_val);
    else
        s = sprintf('%.2g\\cdot10^{%d}', mantissa, exp_val);
    end
end
