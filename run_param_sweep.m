function res = run_param_sweep(p_base, param_name, param_values, I_base, V_cutoff)
% RUN_PARAM_SWEEP  Parametrų įtakos tyrimas: vieno parametro keitimas.
%
% Kiekvienai param_values reikšmei paleidžiama atskira SPM simuliacija,
% o likę parametrai išlieka nepakitę (bazinis rinkinys p_base).
% Simuliacija sustabdoma pasiekus atjungimo įtampą V_cutoff arba kai
% teigiamo elektrodo paviršiaus stoichiometrija pasiekia 0,99.
%
% Tiriami parametrai:
%   'Ds_p' – teigiamo elektrodo difuzijos koeficientas [m²/s]
%   'R0'   – vidinė ominė varža [Ω]
%   'kp'   – reakcijos greičio konstanta (teigiamas elektrodas)
%   'I'    – iškrovos srovė [A]
%
% Įvestis:
%   p_base       - bazinė parametrų struktūra iš SP_parameters.m
%   param_name   - keičiamo parametro pavadinimas (žr. aukščiau)
%   param_values - parametro reikšmių masyvas
%   I_base       - bazinė iškrovos srovė (A); ignoruojama kai param_name = 'I'
%   V_cutoff     - atjungimo įtampa (V)
%
% Išvestis:
%   res - struktūra su laukais:
%     .param_name    - tirto parametro pavadinimas
%     .param_values  - parametro reikšmių masyvas
%     .runs          - struktūrų masyvas (vienas elementas per simuliaciją):
%        .value      - parametro reikšmė
%        .t          - laiko vektorius (s)
%        .V          - gnybtų įtampa (V)
%        .I          - srovė (A)
%        .sim        - pilna SPM simuliacijos struktūra
%        .V0         - pradinė įtampa (V)
%        .Vmin       - mažiausia įtampa (V)
%        .t_disch    - iškrovos trukmė iki atjungimo (min)
%        .Q_eff      - efektyviai iškrauta talpa (Ah)

    n = numel(param_values);
    res.param_name = param_name;
    res.param_values = param_values;
    res.runs = struct('value', {}, 't', {}, 'V', {}, 'I', {}, 'sim', {}, ...
                      'V0', {}, 'Vmin', {}, 't_disch', {}, 'Q_eff', {});

    for k = 1:n
        p = p_base;
        val = param_values(k);

        switch param_name
            case 'Ds_p'
                p.Ds_p  = val;
                I_const = I_base;
            case 'R0'
                p.R0    = val;
                I_const = I_base;
            case 'kp'
                p.kp    = val;
                I_const = I_base;
            case 'I'
                I_const = val;
            otherwise
                error('run_param_sweep:unknownParam', ...
                      'Nežinomas parametras: %s', param_name);
        end

        % Adaptyvus laiko žingsnis pagal Eulerio stabilumo sąlygą:
        %   dt ≤ dR² / (2·Ds)
        % Naudojamas saugos koeficientas 0,4 kad išvengti osciliacijų,
        % ypač esant didelėms Ds_p reikšmėms (>= 1e-13 m²/s).
        dr_p = p.Rp / p.Nr;
        dr_n = p.Rn / p.Nr;
        dt_stab_p = 0.4 * dr_p^2 / max(p.Ds_p, eps);
        dt_stab_n = 0.4 * dr_n^2 / max(p.Ds_n, eps);
        dt_stab = min(dt_stab_p, dt_stab_n);
        if dt_stab < p.dt_sim
            p.dt_sim = dt_stab;
        end

        % Simuliacijos trukmė: teorinė iškrova + 50 % atsarga,
        % kad atjungimo įtampa būtų tikrai pasiekta.
        t_max = ceil((p.Qnom / I_const) * 3600 * 1.5);
        t = (0:p.dt_sim:t_max)';
        I = I_const * ones(size(t));

        % SPM simuliacija ir gnybtų įtampos skaičiavimas
        sim = simulate_SPM(t, I, p);
        V   = compute_terminal_voltage(sim, I, p);

        % Simuliacija sustabdoma pagal du kriterijus:
        %   (a) V ≤ V_cutoff – pasiekta atjungimo įtampa
        %   (b) x_surf_p ≥ 0,99 – teigiamo elektrodo paviršius pilnai
        %       užpildytas; be šio kriterijaus esant mažoms Ds_p reikšmėms
        %       gali atsirasti nerealistiškas įtampos atsigavimas.
        below_V = find(V <= V_cutoff, 1, 'first');
        above_x = find(sim.x_surf_p >= 0.99, 1, 'first');

        ci = numel(t);
        if ~isempty(below_V), ci = min(ci, below_V); end
        if ~isempty(above_x), ci = min(ci, above_x); end

        t_cut = t(1:ci);
        V_cut = V(1:ci);
        I_cut = I(1:ci);

        % Pagrindinės metrikos
        V0       = V_cut(1);
        Vmin     = V_cut(end);
        t_disch  = t_cut(end) / 60;
        Q_eff    = trapz(t_cut, I_cut) / 3600;

        res.runs(k).value   = val;
        res.runs(k).t       = t_cut;
        res.runs(k).V       = V_cut;
        res.runs(k).I       = I_cut;
        res.runs(k).sim     = sim;
        res.runs(k).V0      = V0;
        res.runs(k).Vmin    = Vmin;
        res.runs(k).t_disch = t_disch;
        res.runs(k).Q_eff   = Q_eff;
    end
end
