function plot_SOH_analysis(data, Q_nominal, res_LLI, res_LAM, res_R0)
% PLOT_SOH_ANALYSIS  Sveikatos būklės (SOH) vertinimo grafikai.
%
% Sukuria keturių panelių grafiką (2x2):
%
%   (a) Empirinis SOH iš NASA B0005 talpos matavimų per visus ciklus.
%       Raudona brūkšninė linija žymi EOL kriterijų (SOH = 80 %).
%
%   (b) Gnybtų įtampos profiliai V(t) esant skirtingiems LLI lygiams.
%       LLI (Loss of Lithium Inventory) – ličio jonų kiekio praradimas
%       dėl SEI plėvelės augimo; modeliuojamas mažinant x_ini_n.
%
%   (c) Gnybtų įtampos profiliai V(t) esant skirtingiems LAM lygiams.
%       LAM (Loss of Active Material) – aktyviosios medžiagos praradimas
%       dėl dalelių fragmentacijos; modeliuojamas mažinant Sp ir Sn.
%
%   (d) Modeliu grįstas SOH visų trijų degradacijos mechanizmų
%       palyginimas. Pagrindinis rezultatas: LLI ir LAM stipriai mažina
%       talpą, o R0 augimas talpos praktiškai nepaveikia.
%
% Įvestis:
%   data     - NASA duomenų struktūra iš load_NASA_data.m
%   Q_nominal - nominali celės talpa (Ah)
%   res_LLI  - LLI scenarijų rezultatai iš simulate_aging_scenarios.m
%   res_LAM  - LAM scenarijų rezultatai
%   res_R0   - R0 augimo scenarijų rezultatai

    figure('Name', '6 pav. SOH analizė', ...
           'Color', 'w', 'Position', [220 100 1200 900]);

    %% --- (a) EMPIRINIS SOH ---
    subplot(2, 2, 1);
    [SOH_emp, cyc, EOL_cycle] = compute_empirical_SOH(data, Q_nominal);
    if ~isempty(SOH_emp)
        plot(cyc, SOH_emp, 'b-', 'LineWidth', 1); hold on;
        plot(cyc, SOH_emp, 'b.', 'MarkerSize', 4);
        yline(80, 'r--', 'EOL (80 %)', 'LineWidth', 1.2);
        if ~isnan(EOL_cycle)
            xline(EOL_cycle, 'r:', sprintf('Ciklas %d', EOL_cycle), ...
                  'LineWidth', 1.0);
        end
        grid on;
        xlabel('Ciklo numeris');
        ylabel('SOH (%)');
        title('(a) Empirinis SOH iš NASA talpos matavimų');
        ylim([min(55, min(SOH_emp)-3), 105]);
    end

    %% --- (b) V(t) ESANT LLI ---
    % Kiekvienam degradacijos lygiui (0–20 %) simuliuota 1 C iškrova.
    % Didėjant LLI celė pasiekia atjungimo įtampą anksčiau.
    subplot(2, 2, 2);
    cmap = cool(numel(res_LLI.scenarios));
    hold on; grid on;
    for k = 1:numel(res_LLI.scenarios)
        s = res_LLI.scenarios(k);
        plot(s.t/60, s.V, 'Color', cmap(k,:), 'LineWidth', 1.2);
    end
    yline(2.7, 'k--', 'V_{cutoff} = 2.7 V', 'LineWidth', 1.0);
    xlabel('Laikas (min)');
    ylabel('V (V)');
    title('(b) V(t) esant Li praradimui (LLI)');
    ylim([2.5, 4.3]);
    legend({res_LLI.scenarios.label}, 'Location', 'best', 'FontSize', 8);

    %% --- (c) V(t) ESANT LAM ---
    subplot(2, 2, 3);
    cmap = autumn(numel(res_LAM.scenarios));
    hold on; grid on;
    for k = 1:numel(res_LAM.scenarios)
        s = res_LAM.scenarios(k);
        plot(s.t/60, s.V, 'Color', cmap(k,:), 'LineWidth', 1.2);
    end
    yline(2.7, 'k--', 'V_{cutoff} = 2.7 V', 'LineWidth', 1.0);
    xlabel('Laikas (min)');
    ylabel('V (V)');
    title('(c) V(t) esant akt. medž. praradimui (LAM)');
    ylim([2.5, 4.3]);
    legend({res_LAM.scenarios.label}, 'Location', 'best', 'FontSize', 8);

    %% --- (d) SOH PALYGINIMAS PAGAL MECHANIZMĄ ---
    % Pagrindinis rezultatas: esant 20 % degradacijai,
    %   LLI ir LAM sumažina SOH iki ~78-79 %,
    %   o R0 augimas SOH praktiškai nekeičia (~99 %).
    subplot(2, 2, 4);
    LLI_x = arrayfun(@(s) s.fraction*100, res_LLI.scenarios);
    LLI_y = arrayfun(@(s) s.SOH_model,    res_LLI.scenarios);
    LAM_x = arrayfun(@(s) s.fraction*100, res_LAM.scenarios);
    LAM_y = arrayfun(@(s) s.SOH_model,    res_LAM.scenarios);
    R0_x  = arrayfun(@(s) s.fraction*100, res_R0.scenarios);
    R0_y  = arrayfun(@(s) s.SOH_model,    res_R0.scenarios);

    plot(LLI_x, LLI_y, 'b-o', 'LineWidth', 1.4, 'MarkerSize', 5); hold on;
    plot(LAM_x, LAM_y, 'r-s', 'LineWidth', 1.4, 'MarkerSize', 5);
    plot(R0_x,  R0_y,  'g-^', 'LineWidth', 1.4, 'MarkerSize', 5);
    yline(80, 'k--', 'EOL', 'LineWidth', 1.0);
    grid on;
    xlabel('Degradacijos lygis (%)');
    ylabel('Modeliu grįstas SOH (%)');
    title('(d) SOH vs. degradacijos mechanizmas');
    ylim([50, 105]);
    legend('LLI', 'LAM', 'R_0 padidėjimas', 'EOL', 'Location', 'best');

    sgtitle('Sveikatos būklės (SOH) vertinimas: empiriniai ir fizikiniai požiūriai', ...
            'FontSize', 11, 'FontWeight', 'bold');
end
