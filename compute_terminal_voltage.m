function V = compute_terminal_voltage(sim, I, p)
% COMPUTE_TERMINAL_VOLTAGE  Gnybtų įtampos V(t) skaičiavimas pagal SPM.
%
% Realizuoja pagrindinę SPM gnybtų įtampos formulę:
%   V = U_p(x_surf,p) - U_n(x_surf,n) - eta_p - eta_n - I·R0
%
% Skaičiavimas atliekamas trimis žingsniais:
%   1. Atviros grandinės potencialai U_p ir U_n iš paviršiaus
%      stoichiometrijų per empirines OCP funkcijas.
%   2. Mainų srovės tankiai i0_p ir i0_n pagal Butlerio-Volmerio kinetikos
%      lygtį (koncentracijų priklausomybė).
%   3. Peržengimo potencialai eta_p ir eta_n iš invertuotos
%      Butlerio-Volmerio lygties (hiperbolinio arkussinuso forma).
%
% Naudojama PAVIRŠIAUS stoichiometrija (ne vidutinė), nes
% elektrocheminė reakcija vyksta dalelės paviršiuje.
%
% Įvestis:
%   sim - simuliacijos struktūra iš simulate_SPM.m
%   I   - srovės vektorius (A), teigiamas = iškrova
%   p   - parametrų struktūra

    %% 1. Atviros grandinės potencialai
    Up = OCP_pos(sim.x_surf_p);   % LCO [V vs. Li/Li+]
    Un = OCP_neg(sim.x_surf_n);   % grafitas [V vs. Li/Li+]

    %% 2. Mainų srovės tankiai i0
    % i0 = F · k · c_e^(1-α) · (c_max - c_surf)^(1-α) · c_surf^α
    % Fizinė prasmė: i0 maksimalus kai c_surf = c_max/2,
    % t.y. kai pusė intercaliacijos vietų užimta.
    a = p.alpha;   % = 0,5 (simetrinė Butlerio-Volmerio prielaida)

    % Apsauga nuo skaitinių singuliarumų: kai c_surf artėja prie 0
    % arba c_max, formulė turi 0^0,5 formos narius. Apribojame į
    % saugų diapazoną [1, c_max-1] mol/m³.
    cs_p_safe = min(max(sim.cs_surf_p, 1.0), p.cs_max_p - 1.0);
    cs_n_safe = min(max(sim.cs_surf_n, 1.0), p.cs_max_n - 1.0);

    i0_p = p.F * p.kp * p.ce^(1-a) ...
         .* (p.cs_max_p - cs_p_safe).^(1-a) ...
         .* cs_p_safe.^a;
    i0_n = p.F * p.kn * p.ce^(1-a) ...
         .* (p.cs_max_n - cs_n_safe).^(1-a) ...
         .* cs_n_safe.^a;

    % Papildoma apsauga nuo dalybo iš nulio
    i0_p = max(i0_p, 1e-10);
    i0_n = max(i0_n, 1e-10);

    %% 3. Peržengimo potencialai eta
    % Konvertuojame molinį srautą [mol/(m²·s)] į srovės tankį [A/m²]:
    %   i = j · F
    i_p = sim.j_p * p.F;
    i_n = sim.j_n * p.F;

    % Invertuota Butlerio-Volmerio lygtis (α = 0,5 atvejui):
    %   eta = (2RT/F) · asinh(i / (2·i0))
    % Daugiklis 2RT/F ≈ 51,4 mV esant 25 °C (terminis potencialas).
    % asinh naudojamas vietoj atvirkštinės eksponentės dėl geresnio
    % skaitinio stabilumo.
    eta_p = (2 * p.R * p.T / p.F) .* asinh(i_p ./ (2 * i0_p));
    eta_n = (2 * p.R * p.T / p.F) .* asinh(i_n ./ (2 * i0_n));

    %% 4. Gnybtų įtampa
    % Poilsio metu (I = 0): eta → 0 ir V → OCV = U_p - U_n.
    % Tai vadinamas "įtampos atsistatymo" efektas, matomas NASA
    % duomenyse po atjungimo įtampos pasiekimo.
    V = Up - Un - eta_p - eta_n - I(:) * p.R0;
end
