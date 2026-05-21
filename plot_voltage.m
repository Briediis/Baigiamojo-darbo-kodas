function plot_voltage(t_exp, V_exp, sim, V_guo)
% PLOT_VOLTAGE  Gnybtų įtampos modelio validacija.
%
% Du paneliai:
%
%   (viršuje) Matuota V_exp, modeliuota V_sim (su identifikuotais
%   parametrais) ir – jei pateikta – V_guo (su originaliais Guo et al.
%   (2011) parametrais). Palyginimas parodo parametrų identifikavimo
%   poveikį: sisteminė paklaida sumažėja nuo ~200 mV iki ~25 mV.
%
%   (apačioje) Momentinės paklaidos delta_V = V_sim - V_exp laike.
%   Leidžia įvertinti, kurioje iškrovos fazėje modelis tiksliausias.
%
% Paklaidos metrikos (skaičiuojamos automatiškai):
%   RMSE  - vidutinė kvadratinė paklaida (mV)
%   MAE   - vidutinė absoliuti paklaida (mV)
%   MaxAE - maksimali absoliuti paklaida (mV)
%
% Įvestis:
%   t_exp - laiko vektorius (s)
%   V_exp - matuota gnybtų įtampa (V)
%   sim   - simuliacijos struktūra; sim.V = modelio V(t) su identifikuotais
%           parametrais
%   V_guo - (neprivalomas) modelio V(t) su originaliais Guo et al. parametrais

    if nargin < 4 || isempty(V_guo)
        has_guo = false;
    else
        has_guo = true;
    end

    figure('Name', '4 pav. Gnybtų įtampos validacija', ...
           'Color', 'w', 'Position', [180 180 1100 600]);

    t_min = t_exp / 60;
    err = sim.V - V_exp;

    % NaN filtras: paskutiniame taške interp1 gali grąžinti NaN
    % jei t_exp(end) tiksliai nesutampa su tolygiu simuliacijos tinkleliu.
    ok_fit = ~isnan(err) & ~isnan(sim.V) & ~isnan(V_exp);
    rmse = 1000 * sqrt(mean(err(ok_fit).^2));
    mae  = 1000 * mean(abs(err(ok_fit)));
    maxe = 1000 * max(abs(err(ok_fit)));

    if has_guo
        err_guo  = V_guo - V_exp;
        ok_guo   = ~isnan(err_guo) & ~isnan(V_guo) & ~isnan(V_exp);
        rmse_guo = 1000 * sqrt(mean(err_guo(ok_guo).^2));
        mae_guo  = 1000 * mean(abs(err_guo(ok_guo)));
    end

    %% --- Viršutinė panelė: matuota vs modeliuota ---
    subplot(2, 1, 1);
    hold on; grid on;

    plot(t_min, V_exp, 'k-',  'LineWidth', 1.6);
    if has_guo
        plot(t_min, V_guo, 'b-.', 'LineWidth', 1.3);
    end
    plot(t_min, sim.V, 'r--', 'LineWidth', 1.4);

    xlabel('Laikas (min)');
    ylabel('Gnybtų įtampa V (V)');

    if has_guo
        title(sprintf(['SPM modelio validacija: prieš ir po parametrų ' ...
                       'identifikavimo (RMSE: %.0f mV \\rightarrow %.0f mV)'], ...
                       rmse_guo, rmse));
        legend('Matuota V_{exp}', ...
               'Guo et al. (2011) V_{guo}', ...
               'Identifikuoti B0005 V_{sim}', ...
               'Location', 'best');
    else
        title(sprintf('SPM modelio validacija (RMSE = %.0f mV)', rmse));
        legend('Matuota V_{exp}', 'SPM modelio V_{sim}', 'Location', 'best');
    end

    %% --- Apatinė panelė: paklaidos laike ---
    subplot(2, 1, 2);
    hold on; grid on;

    if has_guo
        plot(t_min, 1000 * err_guo, 'b-.', 'LineWidth', 1.1);
    end
    plot(t_min, 1000 * err, 'r--', 'LineWidth', 1.1);
    yline(0, 'k:', 'Alpha', 0.5);

    xlabel('Laikas (min)');
    ylabel('Paklaida \DeltaV (mV)');

    if has_guo
        title(sprintf(['Modelio paklaidos: Guo RMSE = %.0f mV (MAE = %.0f mV)  vs  ' ...
                       'identifikuoti RMSE = %.0f mV (MAE = %.0f mV)'], ...
                      rmse_guo, mae_guo, rmse, mae));
        legend('\DeltaV_{guo} = V_{guo} - V_{exp}', ...
               '\DeltaV_{sim} = V_{sim} - V_{exp}', ...
               'Location', 'best');
    else
        title(sprintf(['Modelio paklaida: RMSE = %.0f mV, MAE = %.0f mV, ' ...
                       'maks. |\\DeltaV| = %.0f mV'], rmse, mae, maxe));
    end
end
