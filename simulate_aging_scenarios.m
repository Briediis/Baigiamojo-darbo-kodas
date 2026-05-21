function results = simulate_aging_scenarios(p_base, mode, fractions, dt_sim_total)
% SIMULATE_AGING_SCENARIOS  Fizikinis SOH vertinimas per modelio parametrų
%                           pokyčius.
%
% Modeliuojami trys degradacijos mechanizmai:
%
%   LLI (Loss of Lithium Inventory) – ličio jonų kiekio praradimas.
%     Fizikinis pagrindas: SEI plėvelės augimas negrįžtamai suriša Li.
%     Modeliavimas: mažinama pradinė stoichiometrija x_ini_n, atspindinti
%     sumažėjusį prieinamą ličio rezervą neigiamame elektrode.
%
%   LAM (Loss of Active Material) – aktyviosios medžiagos praradimas.
%     Fizikinis pagrindas: dalelių fragmentacija ir kontakto su srovės
%     kolektoriumi praradimas dėl mechaninių įtempių.
%     Modeliavimas: mažinami abiejų elektrodų paviršiaus plotai Sp ir Sn.
%
%   R0_rise – vidinės varžos augimas.
%     Fizikinis pagrindas: SEI plėvelės storėjimas, elektrolito
%     dekompozicija, srovės kolektorių korozija.
%     Modeliavimas: didinamas R0.
%
% Pagrindinis rezultatas (esant 20 % degradacijai):
%   LLI:     SOH ≈ 78 % (talpa stipriai mažėja)
%   LAM:     SOH ≈ 79 % (talpa stipriai mažėja)
%   R0_rise: SOH ≈ 99 % (talpos praktiškai nemažina)
%
% Įvestis:
%   p_base        - bazinė parametrų struktūra
%   mode          - degradacijos mechanizmas: 'LLI', 'LAM' arba 'R0_rise'
%   fractions     - degradacijos lygių masyvas (pvz., [0 0.05 0.10 0.15 0.20])
%   dt_sim_total  - simuliacijos trukmė sekundėmis (numatytasis: 4200)

    if nargin < 4 || isempty(dt_sim_total), dt_sim_total = 4200; end
    if nargin < 3 || isempty(fractions),    fractions = [0 0.05 0.10 0.15 0.20]; end
    if nargin < 2, error('Reikia nurodyti režimą: LLI, LAM arba R0_rise'); end

    % Visiems scenarijams naudojama vienoda 1 C iškrova,
    % kad palyginimas būtų korektiškas.
    I_const = p_base.Qnom;
    t = (0:p_base.dt_sim:dt_sim_total)';
    I = I_const * ones(size(t));

    % Bazinė talpa Q0 (nauja celė) – referencija SOH skaičiavimui.
    p0 = p_base;
    sim0 = simulate_SPM(t, I, p0);
    V0 = compute_terminal_voltage(sim0, I, p0);
    Q0 = compute_effective_capacity(t, I, V0, 2.7);

    results.scenarios = struct('fraction', {}, 't', {}, 'V', {}, ...
                               'Q_eff', {}, 'SOH_model', {}, 'label', {});
    results.mode = mode;
    results.Q_nominal = Q0;

    for k = 1:numel(fractions)
        f = fractions(k);
        p_aged = p_base;

        switch mode
            case 'LLI'
                % Prieinamas Li rezervas mažėja proporcingai f.
                % Pvz., f=0.20: x_ini_n sumažėja 20 %.
                p_aged.x_ini_n = p_base.x_ini_n * (1 - f);
                p_aged.c0_n    = p_aged.x_ini_n * p_aged.cs_max_n;
                p_aged.x_n_100 = p_aged.x_ini_n;
                label = sprintf('LLI = %d %%', round(f*100));

            case 'LAM'
                % Abiejų elektrodų aktyvūs paviršiai mažėja proporcingai f.
                % Pvz., f=0.20: Sp ir Sn sumažėja 20 %.
                p_aged.Sp = p_base.Sp * (1 - f);
                p_aged.Sn = p_base.Sn * (1 - f);
                label = sprintf('LAM = %d %%', round(f*100));

            case 'R0_rise'
                % Vidinė varža auga su daugikliu 4, kad f=0.20 atitiktų
                % ~80 % R0 padidėjimą (realistiškas senėjimo diapazonas).
                % Pvz., f=0.20: R0 padidėja 80 %.
                p_aged.R0 = p_base.R0 * (1 + 4*f);
                label = sprintf('R_0 × (1+%.1f)', 4*f);

            otherwise
                error('Nežinomas režimas: %s', mode);
        end

        sim = simulate_SPM(t, I, p_aged);
        V = compute_terminal_voltage(sim, I, p_aged);
        Q_eff = compute_effective_capacity(t, I, V, 2.7);
        SOH_model = 100 * Q_eff / Q0;

        results.scenarios(k).fraction   = f;
        results.scenarios(k).t          = t;
        results.scenarios(k).V          = V;
        results.scenarios(k).Q_eff      = Q_eff;
        results.scenarios(k).SOH_model  = SOH_model;
        results.scenarios(k).label      = label;
    end
end

% ------------------------------------------------------------------
function Q = compute_effective_capacity(t, I, V, V_cutoff)
% Skaičiuoja efektyvią iškrautą talpą iki atjungimo įtampos V_cutoff.
%   Q_eff = (1/3600) * integral(I dt) nuo 0 iki t_cutoff
% Integracija trapecijų metodu (SI vienetai: C → Ah).

    below = find(V <= V_cutoff, 1, 'first');
    if isempty(below)
        Q = trapz(t, I) / 3600;
    else
        Q = trapz(t(1:below), I(1:below)) / 3600;
    end
end
