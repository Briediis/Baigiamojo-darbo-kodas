function print_sweep_table(res, title_str)
% PRINT_SWEEP_TABLE  Spausdina parametrų tyrimo rezultatų lentelę.
%
% Kiekvienai parametro reikšmei pateikiami keturi kiekybiniai rodikliai:
%   V_0      (V)   – pradinė gnybtų įtampa
%   V_min    (V)   – mažiausia įtampa (paprastai = atjungimo įtampa)
%   t_iskr   (min) – iškrovos trukmė iki atjungimo
%   Q_eff    (Ah)  – efektyviai iškrauta talpa
%
% Stulpelio formatas automatiškai parenkamas pagal parametro tipą.
%
% Įvestis:
%   res       - rezultatų struktūra iš run_param_sweep.m
%   title_str - lentelės pavadinimas

    switch res.param_name
        case 'Ds_p'
            col_hdr = 'D_{s,p} (m^2/s)';
            col_fmt = @(v) sprintf('%.2e', v);
        case 'R0'
            col_hdr = 'R_0 (mOhm)';
            col_fmt = @(v) sprintf('%.1f', v*1000);
        case 'kp'
            col_hdr = 'k_p';
            col_fmt = @(v) sprintf('%.2e', v);
        case 'I'
            col_hdr = 'I (A) [C-rate]';
            col_fmt = @(v) sprintf('%.1f [%.1fC]', v, v/2);
        otherwise
            col_hdr = res.param_name;
            col_fmt = @(v) sprintf('%.4g', v);
    end

    line = repmat('-', 1, 76);
    fprintf('\n  %s\n', title_str);
    fprintf('  %s\n', line);
    fprintf('  %-18s %-10s %-10s %-14s %-10s\n', ...
            col_hdr, 'V_0 (V)', 'V_min (V)', 't_iskr (min)', 'Q_eff (Ah)');
    fprintf('  %s\n', line);

    for k = 1:numel(res.runs)
        r = res.runs(k);
        fprintf('  %-18s %-10.3f %-10.3f %-14.2f %-10.3f\n', ...
                col_fmt(r.value), r.V0, r.Vmin, r.t_disch, r.Q_eff);
    end
    fprintf('  %s\n', line);
end
