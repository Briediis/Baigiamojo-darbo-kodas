function sim = simulate_SPM(t, I, p)
% Realizuoja vienos dalelės modelio (SPM) skaitinį sprendimą,
% taikant baigtinių tūrių diskretizavimo metodą sferinėms koordinatėms
% pagal Plett (2015) ir Xu et al. (2023).
%
% Sprendžiamas antrasis Fiko dėsnis kietojoje fazėje:
%   dc/dt = (Ds/r²) * d/dr(r² * dc/dr)
%
% Algoritmo žingsniai:
%   1. Sudaromas tolygus laiko tinklelis (dt = 1 s)
%   2. Kiekvienas elektrodas dalijamas į Nr koncentrinių sluoksnių
%   3. Kiekviename laiko žingsnyje:
%      a) Skaičiuojami difuzijos srautai tarp gretimų sluoksnių
%      b) Atnaujinamos koncentracijos (aiškioji Eulerio schema)
%      c) Taikoma kraštinė sąlyga paviršiniame sluoksnyje
%   4. Rezultatai interpoliuojami į eksperimentinį laiko tinklelį


    % Sudaromas tolygus laiko tinklelis su žingsniu dt = 1 s.
    % Aiškiosios Eulerio schemos stabilumo sąlyga:
    % dt ≤ dR² / (2·Ds) tenkinama su didele atsarga.
    dt = p.dt_sim;
    t_sim = (t(1):dt:t(end)).';
    I_sim = interp1(t, I, t_sim, 'linear', 'extrap');
    Nt = numel(t_sim);
    Nr = p.Nr;                         % radialinių sluoksnių skaičius = 20

    % Kiekvienas elektrodas dalijamas į Nr vienodo storio
    % sferinius sluoksnius. Išoriniai sluoksniai turi didesnį
    % tūrį nei vidiniai dėl sferinės geometrijos (tūris ~ r²·dr).

    % TEIGIAMAS ELEKTRODAS (LCO)
    dR_p = p.Rp / Nr;                  % vieno sluoksnio storis [m]
    r_p  = (1:Nr) * dR_p;             % išorinių paviršių spinduliai [m]
    Sa_p = 4*pi*r_p.^2;               % sluoksnių išorinių paviršių plotai [m²]
    dV_p = (4/3)*pi*((r_p).^3 - (r_p - dR_p).^3);  % sluoksnių tūriai [m³]

    % NEIGIAMAS ELEKTRODAS (grafitas)
    dR_n = p.Rn / Nr;
    r_n  = (1:Nr) * dR_n;
    Sa_n = 4*pi*r_n.^2;
    dV_n = (4/3)*pi*((r_n).^3 - (r_n - dR_n).^3);

    % Pradinė sąlyga: koncentracija vienoda per visą dalelę
    % pradiniame laiko momente t = 0.
    c_p = p.c0_p * ones(1, Nr);
    c_n = p.c0_n * ones(1, Nr);

    % Rezultatų masyvai: saugoma visa koncentracijų evoliucija
    % laike ir erdvėje (Nt × Nr matrica kiekvienam elektrodui).
    C_p = zeros(Nt, Nr);  C_p(1,:) = c_p;
    C_n = zeros(Nt, Nr);  C_n(1,:) = c_n;
    j_p = zeros(Nt, 1);
    j_n = zeros(Nt, 1);

    % Reakcijos srauto tankiai:
    %   j_n =  I / (Sn·F) > 0  – neigiamas elektrodas atiduoda Li⁺
    %   j_p = -I / (Sp·F) < 0  – teigiamas elektrodas priima Li⁺
    j_n_series = I_sim / (p.Sn * p.F);
    j_p_series = -I_sim / (p.Sp * p.F);
    j_p(1) = j_p_series(1);
    j_n(1) = j_n_series(1);

    % Pagrindinis laiko integravimo ciklas.
    % Kiekviename žingsnyje taikoma aiškioji Eulerio schema.
    for k = 1:Nt-1

        % TEIGIAMAS ELEKTRODAS

        % Difuzijos srauto tankiai tarp gretimų sluoksnių
        % pagal pirmojo laipsnio baigtinių skirtumų aproksimaciją:
        %   N ≈ -Ds · (c_{n+1} - c_n) / dR
        N_p = -p.Ds_p * diff(c_p) / dR_p;     % [mol/(m²·s)]

        % Bendras molių srautas per kiekvieno sluoksnio paviršių [mol/s]:
        M_p = N_p .* Sa_p(1:end-1);

        % Koncentracijos atnaujinimas:
        %   c_n(t+dt) = c_n(t) + (M_{n-1} - M_n) · dt / dV_n
        % Centrinio sluoksnio kraštinė sąlyga:
        %   srautas per vidinį paviršių lygus nuliui → [0, M_p]
        c_p = c_p + ([0, M_p] - [M_p, 0]) * dt ./ dV_p;

        % Paviršinio sluoksnio kraštinė sąlyga:
        % reakcijos srautas per dalelės paviršių koreguoja
        % tik paskutinio sluoksnio koncentraciją.
        c_p(end) = c_p(end) - j_p_series(k) * Sa_p(end) * dt / dV_p(end);

        % NEIGIAMAS ELEKTRODAS (analogiška procedūra)
        N_n = -p.Ds_n * diff(c_n) / dR_n;
        M_n = N_n .* Sa_n(1:end-1);
        c_n = c_n + ([0, M_n] - [M_n, 0]) * dt ./ dV_n;
        c_n(end) = c_n(end) - j_n_series(k) * Sa_n(end) * dt / dV_n(end);

        % Fiziniai apribojimai: koncentracija negali būti neigiama
        % ar viršyti maksimalios leistinos reikšmės.
        c_p = min(max(c_p, 0), p.cs_max_p);
        c_n = min(max(c_n, 0), p.cs_max_n);

        C_p(k+1, :) = c_p;
        C_n(k+1, :) = c_n;
        j_p(k+1) = j_p_series(k+1);
        j_n(k+1) = j_n_series(k+1);
    end

    % Rezultatų interpoliavimas į eksperimentinį laiko tinklelį.
    sim.t          = t(:);
    sim.c_p        = interp1(t_sim, C_p, t(:), 'linear');
    sim.c_n        = interp1(t_sim, C_n, t(:), 'linear');

    % Paviršiaus koncentracijos (paskutinis sluoksnis) –
    % naudojamos gnybtų įtampos skaičiavimui per OCP funkcijas.
    sim.cs_surf_p  = sim.c_p(:, end);
    sim.cs_surf_n  = sim.c_n(:, end);

    % Tūrio svorinis vidurkis –
    % naudojamas SOC skaičiavimui.
    w_p = dV_p / sum(dV_p);
    w_n = dV_n / sum(dV_n);
    sim.cs_avg_p = sim.c_p * w_p(:);
    sim.cs_avg_n = sim.c_n * w_n(:);

    % Stoichiometrijos – koncentracija normalizuota į maksimumą:
    %   paviršiaus stoich. → gnybtų įtampos skaičiavimui
    %   vidutinė stoich.   → SOC skaičiavimui
    sim.x_surf_p = sim.cs_surf_p / p.cs_max_p;
    sim.x_surf_n = sim.cs_surf_n / p.cs_max_n;
    sim.x_avg_p  = sim.cs_avg_p  / p.cs_max_p;
    sim.x_avg_n  = sim.cs_avg_n  / p.cs_max_n;

    sim.j_p = interp1(t_sim, j_p, t(:), 'linear');
    sim.j_n = interp1(t_sim, j_n, t(:), 'linear');

    sim.r_p = r_p;
    sim.r_n = r_n;
end