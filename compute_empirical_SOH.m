function [SOH, cycleNumbers, EOL_cycle] = compute_empirical_SOH(data, Q_nominal)
% COMPUTE_EMPIRICAL_SOH  Empirinis sveikatos būklės (SOH) skaičiavimas
%                        iš NASA talpos matavimų.
%
% Kiekvieno iškrovos ciklo matuota talpa normalizuojama į pradinę
% talpos reikšmę, išreiškiant SOH procentais. Taip pat nustatomas
% ciklas, kuriame SOH pirmą kartą nukrenta žemiau EOL kriterijaus
% (80 %).
%
% Tai empirinis metodas – jis parodo KAS vyksta (talpa mažėja),
% bet neatskleidžia KODĖL (degradacijos mechanizmo). Fizikiniam SOH
% vertinimui naudojamas simulate_aging_scenarios.m.
%
% Įvestis:
%   data      - NASA duomenų struktūra iš load_NASA_data.m
%   Q_nominal - nominali celės talpa (Ah); naudojama SOH normavimui
%
% Išvestis:
%   SOH          - SOH reikšmių vektorius (%)
%   cycleNumbers - atitinkamų ciklų numeriai
%   EOL_cycle    - ciklo numeris, kai SOH pirmą kartą < 80 %;
%                  NaN jei EOL nepasiektas duomenų rinkinyje

    cap = data.capacity_vs_cycle;
    if isempty(cap)
        SOH = [];
        cycleNumbers = [];
        EOL_cycle = NaN;
        return;
    end

    cycleNumbers = cap(:, 1);
    SOH = 100 * cap(:, 2) / Q_nominal;

    % Randamas pirmasis ciklas, kuriame SOH nukrenta žemiau 80 %
    below_EOL = find(SOH < 80, 1, 'first');

    if isempty(below_EOL)
        EOL_cycle = NaN;
    else
        EOL_cycle = cycleNumbers(below_EOL);
    end
end
