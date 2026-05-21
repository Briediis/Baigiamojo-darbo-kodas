function plot_consolidated_results(res_Ds, res_R0, res_kp, res_I)
% PLOT_CONSOLIDATED_RESULTS  Apibendrinantis parametrų įtakos grafikas.
%
% Visi keturi parametrų tyrimai pateikiami vienoje 2x2 figūroje,
% leidžiančioje vizualiai palyginti kiekvieno parametro poveikį
% gnybtų įtampos charakteristikai V(t).
%
% Įvestis:
%   res_Ds - D_{s,p} tyrimo rezultatai iš run_param_sweep.m
%   res_R0 - R_0 tyrimo rezultatai
%   res_kp - k_p tyrimo rezultatai
%   res_I  - iškrovos srovės tyrimo rezultatai

    figure('Name', '18 pav. Apibendrinantis parametrų įtakos tyrimas', ...
           'Color', 'w', 'Position', [100 100 1200 820]);

    subplot(2, 2, 1);
    plot_sub_panel(res_Ds, 'D_{s,p}', 'm^2/s', '(a) D_{s,p} įtaka');

    subplot(2, 2, 2);
    plot_sub_panel(res_R0, 'R_0', 'm\Omega', '(b) R_0 įtaka');

    subplot(2, 2, 3);
    plot_sub_panel(res_kp, 'k_p', '', '(c) k_p įtaka');

    subplot(2, 2, 4);
    plot_sub_panel(res_I, 'I', 'A', '(d) Iškrovos srovės I įtaka');

    if exist('sgtitle', 'file')
        sgtitle('Apibendrinantis SPM modelio parametrų įtakos tyrimas', ...
                'FontSize', 12, 'FontWeight', 'bold');
    end
end

% ------------------------------------------------------------------
function plot_sub_panel(res, param_label, unit_str, panel_title)
% Vienos panelės V(t) grafikas su kompaktiška legenda.

    hold on; grid on; box on;
    colors = lines(numel(res.runs));
    leg_txt = cell(numel(res.runs), 1);

    for k = 1:numel(res.runs)
        r = res.runs(k);
        plot(r.t/60, r.V, 'Color', colors(k,:), 'LineWidth', 1.25);

        switch res.param_name
            case 'R0'
                leg_txt{k} = sprintf('%.1f %s', r.value*1000, unit_str);
            case 'I'
                leg_txt{k} = sprintf('%.1f A (%.1fC)', r.value, r.value/2);
            otherwise
                leg_txt{k} = format_compact(r.value);
        end
    end

    xl = xlim;
    plot(xl, [2.7 2.7], 'k--', 'LineWidth', 0.9, 'HandleVisibility', 'off');
    xlabel('Laikas (min)', 'FontSize', 10);
    ylabel('V(t), V', 'FontSize', 10);
    title(panel_title, 'FontSize', 10, 'FontWeight', 'normal');
    legend(leg_txt, 'Location', 'best', 'FontSize', 7);
    set(gca, 'FontSize', 9);
end

% ------------------------------------------------------------------
function s = format_compact(val)
% Kompaktiškas mokslinis formatas: pvz. 1e-14 → "10^{-14}"
    if val == 0, s = '0'; return; end
    exp_val = floor(log10(abs(val)));
    mantissa = val / 10^exp_val;
    if abs(mantissa - 1) < 1e-3
        s = sprintf('10^{%d}', exp_val);
    else
        s = sprintf('%.1g\\cdot10^{%d}', mantissa, exp_val);
    end
end
