function SOC = compute_SOC(sim, p)
% COMPUTE_SOC  Įkrovos būsenos (SOC) skaičiavimas iš SPM modelio.
%
% SOC apskaičiuojamas iš abiejų elektrodų vidutinių stoichiometrijų,
% normalizuojant į pilno įkrovimo ir iškrovimo ribas. Vidutinė
% stoichiometrija (ne paviršiaus) naudojama todėl, kad ji atspindi
% bendrą ličio kiekį dalelėje, o ne tik paviršiaus būseną.
%
% Iš kiekvieno elektrodo gaunama atskira SOC reikšmė, o galutinis
% SOC – jų aritmetinis vidurkis. Nedidelis skirtumas tarp SOC_n ir
% SOC_p atsiranda dėl skirtingų difuzijos koeficientų ir skaitinių
% paklaidų.
%
% Įvestis:
%   sim - simuliacijos struktūra iš simulate_SPM.m
%   p   - parametrų struktūra su x_n_0, x_n_100, x_p_0, x_p_100

    % SOC iš neigiamo elektrodo (grafitas)
    SOC_n = (sim.x_avg_n - p.x_n_0) / (p.x_n_100 - p.x_n_0);

    % SOC iš teigiamo elektrodo (LCO).
    % LCO atveju x_p_0 > x_p_100, nes teigiamas elektrodas
    % prisipildo ličiu iškrovos (ne įkrovimo) metu.
    SOC_p = (sim.x_avg_p - p.x_p_0) / (p.x_p_100 - p.x_p_0);

    % Galutinis SOC – aritmetinis vidurkis iš abiejų elektrodų
    SOC = 100 * 0.5 * (SOC_n + SOC_p);

    % Apribojimas į fiziškai prasmingą diapazoną [0, 100] %
    % (skaitinės paklaidos gali sukelti nežymų viršijimą)
    SOC = min(max(SOC, 0), 100);
end
