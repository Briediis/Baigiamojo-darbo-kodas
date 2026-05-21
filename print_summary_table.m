function print_summary_table(res_Ds, res_R0, res_kp, res_I)
% PRINT_SUMMARY_TABLE  Apibendrinanti parametrų įtakos tyrimo lentelė.
%
% Spausdina lentelę su keturių tirtų parametrų maksimaliais pokyčiais:
%   delta_V0       (mV)  – pradinės gnybtų įtampos pokytis
%   delta_t_iskr   (min) – iškrovos trukmės pokytis
%   delta_Q_eff    (Ah)  – efektyvios talpos pokytis
%
% Leidžia palyginti parametrų įtaką ir nustatyti, kurie iš jų veikia
% tik įtampos lygį (R0, kp), o kurie – ir talpą (Ds_p, I).
%
% Įvestis:
%   res_Ds, res_R0, res_kp, res_I - rezultatai iš run_param_sweep.m

    line = repmat('-', 1, 72);
    fprintf('\n  8 lentelė. Parametrų įtakos tyrimo apibendrinimas\n');
    fprintf('  %s\n', line);
    fprintf('  %-20s %-15s %-18s %-15s\n', ...
            'Parametras', 'Delta V_0 (mV)', 'Delta t_iskr (min)', 'Delta Q_eff (Ah)');
    fprintf('  %s\n', line);

    print_row('D_{s,p}',       res_Ds);
    print_row('R_0',           res_R0);
    print_row('k_p',           res_kp);
    print_row('I (0.5-3 C)',   res_I);

    fprintf('  %s\n', line);
end

% ------------------------------------------------------------------
function print_row(label, res)
% Apskaičiuoja ir spausdina maksimalius pokyčius vienai parametrų grupei.

    V0s    = arrayfun(@(r) r.V0,      res.runs);
    ts     = arrayfun(@(r) r.t_disch, res.runs);
    Qs     = arrayfun(@(r) r.Q_eff,   res.runs);

    dV_mV  = (max(V0s) - min(V0s)) * 1000;
    dt_min = max(ts) - min(ts);
    dQ_Ah  = max(Qs) - min(Qs);

    fprintf('  %-20s %-15.1f %-18.1f %-15.3f\n', ...
            label, dV_mV, dt_min, dQ_Ah);
end
