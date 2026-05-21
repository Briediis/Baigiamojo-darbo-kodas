function plot_states(t_exp, sim)
% PLOT_STATES  Įkrovos būsenos ir stoichiometrijų vizualizavimas.
%
% Du paneliai:
%
%   (viršuje) SOC palyginimas: SPM modelio SOC (iš vidutinių
%   stoichiometrijų) ir Kulono skaičiavimo SOC (iš srovės integralo).
%   Abu metodai turėtų sutapti – skirtumas atsiranda dėl nominalios
%   ir realios talpos neatitikimo.
%
%   (apačioje) Paviršiaus ir vidutinės stoichiometrijos abiejuose
%   elektroduose. Skirtumas tarp jų parodo difuzinio apribojimo
%   intensyvumą – iškrovos pabaigoje jis didėja dėl koncentracijos
%   gradientų dalelių viduje.
%
% Įvestis:
%   t_exp - laiko vektorius (s)
%   sim   - simuliacijos struktūra iš simulate_SPM.m

    figure('Name', '5 pav. Įkrovos būsena ir stoichiometrijos', ...
           'Color', 'w', 'Position', [200 200 1100 600]);

    t_min = t_exp / 60;

    % --- SOC palyginimas ---
    subplot(2, 1, 1);
    plot(t_min, sim.SOC, 'r-', 'LineWidth', 1.5); hold on;
    plot(t_min, sim.SOC_CC, 'b--', 'LineWidth', 1.3);
    grid on;
    xlabel('Laikas (min)');
    xlim([0,54]);
    ylabel('SOC (%)');
    title('Įkrovos būsena (SOC)');
    ylim([-5, 105]);
    legend('SPM modelis', 'Kulonų skaičiavimas', 'Location', 'best');

    % --- Stoichiometrijos ---
    % Ištisinės linijos = paviršiaus stoichiometrija (naudojama V skaičiavimui)
    % Brūkšninės linijos = vidutinė stoichiometrija (naudojama SOC skaičiavimui)
    subplot(2, 1, 2);
    plot(t_min, sim.x_surf_p, 'r-', 'LineWidth', 1.4); hold on;
    plot(t_min, sim.x_avg_p, 'r--', 'LineWidth', 1.2);
    plot(t_min, sim.x_surf_n, 'b-', 'LineWidth', 1.4);
    plot(t_min, sim.x_avg_n, 'b--', 'LineWidth', 1.2);
    grid on;
    xlabel('Laikas (min)');
    ylabel('Stoichiometrija x');
    title('Elektrodų stoichiometrijos kitimas');
    xlim([0,54]);
    ylim([0, 1]);
    legend('x_{p,surf}', 'x_{p,avg}', 'x_{n,surf}', 'x_{n,avg}', ...
           'Location', 'best');
end
