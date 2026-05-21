function plot_concentrations(sim, p)
% PLOT_CONCENTRATIONS  Ličio jonų koncentracijų dinamika dalelėse.
%
% Keturių panelių grafikas:
%
%   (a) Teigiamo elektrodo (LCO) paviršiaus c_{s,surf,p} ir vidutinė
%       c_{s,avg,p} koncentracija laike. Paviršiaus koncentracija auga
%       sparčiau – tai tiesioginė difuzinio apribojimo pasekmė.
%
%   (b) Neigiamo elektrodo (grafito) koncentracijos laike. Paviršiaus
%       koncentracija mažėja sparčiau – Li atiduodama iš paviršiaus
%       greičiau, nei difuzija atnešа naujų jonų iš vidaus.
%
%   (c) Teigiamo elektrodo radialinis koncentracijos profilis skirtingais
%       laiko momentais. Profilio forma artima parabolinei, kaip pranašauja
%       analitinės aproksimacijos.
%
%   (d) Neigiamo elektrodo radialinis profilis. Iškrovos pabaigoje
%       paviršiaus ir centro koncentracijų skirtumas paaiškina staigų
%       gnybtų įtampos kritimą.
%
% Įvestis:
%   sim - simuliacijos struktūra iš simulate_SPM.m
%   p   - parametrų struktūra (reikia cs_max_p, cs_max_n)

    figure('Name', '8 pav. Koncentracijų dinamika', ...
           'Color', 'w', 'Position', [150 150 1100 800]);

    t_min = sim.t / 60;

    %% --- (a) Teigiamas elektrodas: paviršius vs vidurkis ---
    subplot(2, 2, 1);
    plot(t_min, sim.cs_surf_p, 'r-', 'LineWidth', 1.4); hold on;
    plot(t_min, sim.cs_avg_p, 'b--', 'LineWidth', 1.4);
    yline(p.cs_max_p, 'k:', 'LineWidth', 1.0);
    grid on;
    xlabel('Laikas (min)');
    ylabel('c_{s,p} (mol/m^3)');
    title('Teigiamo elektrodo (LCO) koncentracija');
    legend('Paviršiaus c_{s,surf,p}', 'Vidutinė c_{s,avg,p}', ...
           'c_{s,max,p}', 'Location', 'best');

    %% --- (b) Neigiamas elektrodas ---
    subplot(2, 2, 2);
    plot(t_min, sim.cs_surf_n, 'r-', 'LineWidth', 1.4); hold on;
    plot(t_min, sim.cs_avg_n, 'b--', 'LineWidth', 1.4);
    yline(p.cs_max_n, 'k:', 'LineWidth', 1.0);
    grid on;
    xlabel('Laikas (min)');
    ylabel('c_{s,n} (mol/m^3)');
    title('Neigiamo elektrodo (grafito) koncentracija');
    legend('Paviršiaus c_{s,surf,n}', 'Vidutinė c_{s,avg,n}', ...
           'c_{s,max,n}', 'Location', 'best');

    %% --- (c) Teigiamo elektrodo radialinis profilis ---
    % Šeši tolygiai išdėstyti laiko momentai, kad būtų matoma
    % koncentracijos profilio evoliucija iškrovos eigoje.
    Nt = size(sim.c_p, 1);
    ksnap = unique(round(linspace(1, Nt, 6)));
    cmap = cool(numel(ksnap));

    subplot(2, 2, 3);
    hold on; grid on;
    legend_txt = cell(numel(ksnap), 1);
    for i = 1:numel(ksnap)
        k = ksnap(i);
        plot(sim.r_p * 1e6, sim.c_p(k, :), 'Color', cmap(i,:), 'LineWidth', 1.2);
        legend_txt{i} = sprintf('t = %.1f min', sim.t(k)/60);
    end
    xlabel('Radialinis atstumas r (μm)');
    ylabel('c_{s,p}(r) (mol/m^3)');
    title('Teigiamo el. radialinis profilis');
    legend(legend_txt, 'Location', 'best', 'FontSize', 8);

    %% --- (d) Neigiamo elektrodo radialinis profilis ---
    subplot(2, 2, 4);
    hold on; grid on;
    for i = 1:numel(ksnap)
        k = ksnap(i);
        plot(sim.r_n * 1e6, sim.c_n(k, :), 'Color', cmap(i,:), 'LineWidth', 1.2);
    end
    xlabel('Radialinis atstumas r (μm)');
    ylabel('c_{s,n}(r) (mol/m^3)');
    title('Neigiamo el. radialinis profilis');
    legend(legend_txt, 'Location', 'best', 'FontSize', 8);

    sgtitle('Ličio jonų koncentracijų dinamika dalelėse (SPM)', ...
            'FontSize', 11, 'FontWeight', 'bold');
end
