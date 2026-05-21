%  VIENOS DALELĖS (SPM) LIČIO JONŲ BATERIJOS MODELIO REALIZACIJA
clear; clc; close all;

% =====================================================================
% GRAFIKŲ IŠSAUGOJIMO NUSTATYMAI
% =====================================================================
SAVE_FIGURES = true;
SAVE_PATH    = 'C:\Users\danie\Desktop\Bakis\kodas\Modelis';

fprintf('=================================================\n');
fprintf('  SPM modelio simuliacija (LCO/grafito celė)\n');
fprintf('=================================================\n\n');

%% ===================================================================
% 1. PARAMETRŲ NUSTATYMAS
% ===================================================================
p = SP_parameters();
fprintf('[1] Parametrai sėkmingai sukrauti.\n');
fprintf('    Teigiamas elektrodas: LiCoO2, Rp = %.1f um\n', p.Rp*1e6);
fprintf('    Neigiamas elektrodas: grafitas (MCMB), Rn = %.1f um\n\n', p.Rn*1e6);

%% ===================================================================
% 2. NASA DUOMENŲ UŽKROVIMAS IR VIZUALIZAVIMAS
%===================================================================
data = load_NASA_data('B0005.mat');
fprintf('[2] Užkrauti NASA duomenys (%d iškrovos ciklai).\n', ...
        numel(data.dischargeCycles));

% 1 paveikslas: NASA matavimai (3x2 tinklelis)
plot_experimental_data(data);
fprintf('    Nubraižyti eksperimentiniai duomenys (1 pav.).\n');
if SAVE_FIGURES, save_figure(SAVE_PATH, '01_NASA_eksperimentiniai_duomenys'); end

% 2 paveikslas: OCP ir OCV-SOC kreivės
plot_OCP_curves(p);
fprintf('    Nubraižytos atviros grandinės potencialo kreivės (2 pav.).\n\n');
if SAVE_FIGURES, save_figure(SAVE_PATH, '02_OCP_kreives'); end

%% ===================================================================
% 3. ĮVESTIES SROVĖS PROFILIO PARINKIMAS
% ===================================================================
cyc = data.dischargeCycles(1);
t_exp = cyc.time(:);                  % laikas (s)
I_exp = cyc.current(:);               % srovė (A), teigiama = iškrova
V_exp = cyc.voltage(:);               % gnybtų įtampa (V)
T_exp = cyc.temperature(:);           % celės temperatūra (°C)

% NASA duomenys turi POILSIO fazes pradžioje ir gale (kai I ≈ 0).
% Tos fazės iškreiptų simuliaciją, todėl atfiltruojam jas.
% Filtras: |I| > 0.1 A reiškia "aktyvi iškrova".
active = abs(I_exp) > 0.1;
if any(active)
    i0 = find(active, 1, 'first');     % pirmas aktyvus indeksas
    i1 = find(active, 1, 'last');      % paskutinis aktyvus
    t_exp = t_exp(i0:i1) - t_exp(i0);  % apkarpom ir pernuliname laiką
    I_exp = I_exp(i0:i1);
    V_exp = V_exp(i0:i1);
    T_exp = T_exp(i0:i1);
end

fprintf('[3] Parinktas iškrovos ciklas Nr.1:\n');
fprintf('    Trukmė: %.0f s (%.2f h)\n', t_exp(end), t_exp(end)/3600);
fprintf('    Vidutinė srovė: %.3f A (~ %.2f C)\n', mean(I_exp), mean(I_exp)/p.Qnom);
fprintf('    Pradinė įtampa: %.3f V\n', V_exp(1));
fprintf('    Galutinė įtampa: %.3f V\n\n', V_exp(end));

%% ===================================================================
% 3.1. PARAMETRŲ PRISITAIKYMAS CELĖS DUOMENIMS
% Guo (2011) parametrai išmatuoti maišelinei celei (1.656 Ah),
% bet NASA B0005 yra 18650 cilindrinė (2 Ah). Geometrijos skirtumai
% sukelia ~209 mV sisteminę paklaidą.
% Sprendimas: paleisti Nelder-Mead optimizaciją ir surasti
% trijų parametrų (R0, x_ini_p, x_ini_n) optimalias vertes.
% Po prisitaikymo paklaida nukrenta nuo 209 mV iki ~33 mV.

USE_FITTED_PARAMS = true;

if USE_FITTED_PARAMS && contains(data.source, 'B0005', 'IgnoreCase', true)
    fprintf('[3.1] Atliekamas parametrų prisitaikymas B0005 celei...\n');

    % Iškvietimas funkcijos, kuri vidiniam Nelder-Mead algoritmui
    % perduoda objektyvią funkciją (V(t) RMSE) kaip minimizavimo tikslą.
    fit = fit_parameters_to_cell(data, 1, p);

    % Išsaugom originalius Guo parametrus PRIEŠ atnaujinimą,
    % kad galėtume nubraižyti palyginimo grafiką žemiau.
    p_guo = p;

    % Atnaujinam parametrų struktūrą su prisitaikytais R0, x_ini_p, x_ini_n
    p.R0      = fit.R0;
    p.x_ini_p = fit.x_ini_p;
    p.x_ini_n = fit.x_ini_n;

    % Atnaujinam priklausomus parametrus (pradines koncentracijas, ribas)
    p.c0_p    = p.x_ini_p * p.cs_max_p;
    p.c0_n    = p.x_ini_n * p.cs_max_n;
    p.x_n_100 = p.x_ini_n;
    p.x_p_100 = p.x_ini_p;

    % Naujas grafikas: OCV-SOC palyginimas prieš ir po prisitaikymo
    plot_OCV_comparison(p_guo, p);
    fprintf('    Nubraižytas OCV-SOC palyginimas (Guo vs pritaikyti).\n');
    if SAVE_FIGURES, save_figure(SAVE_PATH, '02b_OCV_palyginimas'); end
    fprintf('\n');
end

%% ===================================================================
% 4. SPM MODELIO SIMULIACIJA - KONCENTRACIJŲ DINAMIKA
fprintf('[4] Simuliuojama SPM modelio koncentracijų dinamika...\n');
tic;
sim = simulate_SPM(t_exp, I_exp, p);
fprintf('    Simuliacija baigta per %.2f s.\n\n', toc);

%% ===================================================================
% 5. GNYBTŲ ĮTAMPOS V(t) SKAIČIAVIMAS
% Iš paviršiaus stoichiometrijų (sim.x_surf_p, sim.x_surf_n)
% pagal pagrindinę formulę:
%     V = U_p - U_n - eta_p - eta_n - I*R0

fprintf('[5] Skaičiuojama gnybtų įtampa V(t)...\n');
sim.V = compute_terminal_voltage(sim, I_exp, p);

% Vidutinė ir RMSE paklaidos (palyginimui su eksperimentu).
% NaN-saugus skaičiavimas - paskutinis taškas gali būti NaN dėl interp1.
ok_v = ~isnan(sim.V) & ~isnan(V_exp);
fprintf('    Vidutinė modelio paklaida: %.3f V (RMSE = %.4f V)\n', ...
    mean(abs(sim.V(ok_v) - V_exp(ok_v))), ...
    sqrt(mean((sim.V(ok_v) - V_exp(ok_v)).^2)));

ss_res = sum((sim.V(ok_v) - V_exp(ok_v)).^2);
ss_tot = sum((V_exp(ok_v) - mean(V_exp(ok_v))).^2);
r2_fit = 1 - ss_res / ss_tot;
fprintf('    R² = %.6f\n\n', r2_fit);
maxe_fit = 1000 * max(abs(sim.V(ok_v) - V_exp(ok_v)));
fprintf('    Maks. absoliuti paklaida: %.1f mV\n\n', maxe_fit);

%% ===================================================================
% 6. SOC IR COULOMBŲ SKAIČIAVIMAS
% Du SOC vertinimo metodai palyginimui:
%
%   a) SPM SOC (sim.SOC) - iš vidutinės stoichiometrijos
%   b) Coulombų skaičiavimas (SOC_CC) - iš srovės integralo:
%      SOC_CC(t) = 100 * (1 - cumtrapz(I) / (Q_nom * 3600))
% Idealiame modelyje abu metodai turi sutapti.
fprintf('[6] Skaičiuojama SOC būsena...\n');
sim.SOC = compute_SOC(sim, p);

% Coulombų skaičiavimas - integralas srovės iki tam tikro laiko
sim.SOC_CC = 100 * (1 - cumtrapz(t_exp, I_exp) / (p.Qnom * 3600));

fprintf('    Modelio pradinis SOC: %.1f %%\n', sim.SOC(1));
fprintf('    Modelio galutinis SOC: %.1f %%\n\n', sim.SOC(end));

%% ===================================================================
% 6.1. PAPILDOMA SIMULIACIJA SU ORIGINALIAIS GUO PARAMETRAIS
% Jei buvo atliktas parametrų prisitaikymas (3.1 skyrius), papildomai
% paleidžiame V(t) simuliaciją su NEPAKEISTAIS Guo (2011) parametrais.
% Gauta V_guo kreivė bus parodyta 4 pav. (dok. 7 pav.) kartu su matuota
% ir pritaikyta, kad būtų vizualiai matoma ~200 mV sisteminė paklaida,
% kuri minima dokumento 2.7 poskyryje.
% ===================================================================
if exist('p_guo', 'var')
    fprintf('[6.1] Skaičiuojama V(t) su originaliais Guo parametrais (palyginimui)...\n');
    sim_guo = simulate_SPM(t_exp, I_exp, p_guo);
    V_guo   = compute_terminal_voltage(sim_guo, I_exp, p_guo);

    % NaN-saugus RMSE
    ok_g = ~isnan(V_guo) & ~isnan(V_exp);
    ok_f = ~isnan(sim.V) & ~isnan(V_exp);
    rmse_guo_mV = 1000 * sqrt(mean((V_guo(ok_g) - V_exp(ok_g)).^2));
    rmse_fit_mV = 1000 * sqrt(mean((sim.V(ok_f) - V_exp(ok_f)).^2));

    fprintf('    V(t) RMSE su Guo parametrais:        %6.1f mV\n', rmse_guo_mV);
    fprintf('    V(t) RMSE su pritaikytais B0005:     %6.1f mV\n', rmse_fit_mV);
    fprintf('    Pagerinimas: %.1fx (%.0f mV -> %.0f mV)\n\n', ...
        rmse_guo_mV / rmse_fit_mV, rmse_guo_mV, rmse_fit_mV);
else
    V_guo = [];      % prisitaikymas neatliktas - rodoma tik viena kreivė
end

%% ===================================================================
% 7. REZULTATŲ ATVAIZDAVIMAS - GRAFIKAI 3-5
plot_concentrations(sim, p);                    % 3 pav. - koncentracijos
if SAVE_FIGURES, save_figure(SAVE_PATH, '03_koncentraciju_dinamika'); end

plot_voltage(t_exp, V_exp, sim, V_guo);         % 4 pav. - V(t) validacija + palyginimas
if SAVE_FIGURES, save_figure(SAVE_PATH, '04_V_validacija'); end

plot_states(t_exp, sim);                        % 5 pav. - SOC ir stoichiometrijos
if SAVE_FIGURES, save_figure(SAVE_PATH, '05_SOC_stoichiometrijos'); end

%% ===================================================================
% 8. SVEIKATOS BŪKLĖS (SOH) ANALIZĖ
% Du požiūriai:
%   a) Empirinis SOH iš NASA talpos matavimų - kas vyksta
%   b) Fizikinis SOH per parametrų scenarijus - kodėl vyksta

fprintf('[8] Atliekama SOH analizė (3 degradacijos mechanizmai)...\n');

% --- (a) EMPIRINIS SOH IŠ NASA DUOMENŲ ---
[SOH_emp, ~, EOL_cyc] = compute_empirical_SOH(data, p.Qnom);
if ~isempty(SOH_emp)
    fprintf('    Empirinis SOH: pradžioje %.1f %%, pabaigoje %.1f %%\n', ...
        SOH_emp(1), SOH_emp(end));
    if ~isnan(EOL_cyc)
        fprintf('    EOL (80 %%) pasiektas cikle Nr. %d\n', EOL_cyc);
    end
end

% --- (b) FIZIKINIS SOH PER PARAMETRŲ DEGRADACIJĄ ---
% Kiekvienam scenarijui simuliuojam 5 degradacijos lygius (0-20%)
fprintf('    Simuliuojami scenarijai: LLI, LAM, R0 padidėjimas...\n');
deg_levels = [0 0.05 0.10 0.15 0.20];

% LLI (Loss of Lithium Inventory) - Li kiekio praradimas
res_LLI = simulate_aging_scenarios(p, 'LLI',     deg_levels, 4200);

% LAM (Loss of Active Material) - akt. medž. praradimas
res_LAM = simulate_aging_scenarios(p, 'LAM',     deg_levels, 4200);

% R0_rise - vidinės varžos augimas
res_R0_aging  = simulate_aging_scenarios(p, 'R0_rise', deg_levels, 4200);

% 6 paveikslas su visais 4 paneliais
plot_SOH_analysis(data, p.Qnom, res_LLI, res_LAM, res_R0_aging);
if SAVE_FIGURES, save_figure(SAVE_PATH, '06_SOH_analize'); end

% Konsolės išvestis - SOH reikšmės esant 20 % degradacijai
fprintf('    Modeliuotas SOH esant 20 %% degradacijai:\n');
fprintf('      LLI:            %.1f %%\n', res_LLI.scenarios(end).SOH_model);
fprintf('      LAM:            %.1f %%\n', res_LAM.scenarios(end).SOH_model);
fprintf('      R0 padidėjimas: %.1f %%\n', res_R0_aging.scenarios(end).SOH_model);

fprintf('\n');

%% ===================================================================
% 9. PARAMETRŲ ĮTAKOS TYRIMAS (3 SKYRIUS)
% Tiria, kaip atskirų SPM parametrų pokyčiai veikia gnybtų įtampos
% profilį. Naudoja pritaikytus B0005 celės parametrus iš [3.1] sekcijos
% kaip bazinį rinkinį.
%
% Tiriami parametrai (kiekvienam po 5 reikšmes):
%   D_{s,p} – teigiamo elektrodo difuzijos koeficientas
%   R_0     – vidinė ominė varža
%   k_p     – reakcijos konstanta
%   I       – iškrovos srovė / C-rate
% ===================================================================
fprintf('=================================================\n');
fprintf('[9] PARAMETRŲ ĮTAKOS TYRIMAS (3 skyrius)\n');
fprintf('=================================================\n\n');

% --- 9.1. PARAMETRŲ REIKŠMĖS (galima keisti) ---
Ds_p_values = [1e-15, 3e-15, 1e-14, 3e-14, 1e-13];
R0_values   = [0.0162, 0.060, 0.1132, 0.180, 0.250];
kp_values   = [6.67e-14, 6.67e-13, 6.67e-12, 6.67e-11, 6.67e-10];
I_values    = [1.0, 2.0, 3.0, 4.0, 6.0];

I_base   = p.Qnom;       % = 2 A = 1 C
V_cutoff = 2.7;

% --- 9.2. Difuzijos koeficiento įtaka ---
fprintf('[9.2] Tiriama D_{s,p} įtaka (%d reikšmės)...\n', numel(Ds_p_values));
res_Ds = run_param_sweep(p, 'Ds_p', Ds_p_values, I_base, V_cutoff);
plot_voltage_sweep(res_Ds, 'D_{s,p}', 'm^2/s', ...
                   'V(t) skirtingoms D_{s,p} reikšmėms');
if SAVE_FIGURES, save_figure(SAVE_PATH, '12_V_Ds_p'); end
plot_Qeff_vs_Ds(res_Ds);
if SAVE_FIGURES, save_figure(SAVE_PATH, '13_Qeff_vs_Ds'); end
fprintf('\n');

% --- 9.3. Vidinės ominės varžos įtaka ---
fprintf('[9.3] Tiriama R_0 įtaka (%d reikšmės)...\n', numel(R0_values));
res_R0_sweep = run_param_sweep(p, 'R0', R0_values, I_base, V_cutoff);
plot_voltage_sweep(res_R0_sweep, 'R_0', 'm\Omega', ...
                   'V(t) skirtingoms R_0 reikšmėms');
if SAVE_FIGURES, save_figure(SAVE_PATH, '14_V_R_0'); end
plot_Qeff_vs_R0(res_R0_sweep);
if SAVE_FIGURES, save_figure(SAVE_PATH, '15_Qeff_vs_R0'); end
fprintf('\n');

% --- 9.4. Reakcijos konstantos įtaka ---
fprintf('[9.4] Tiriama k_p įtaka (%d reikšmės)...\n', numel(kp_values));
res_kp = run_param_sweep(p, 'kp', kp_values, I_base, V_cutoff);
plot_voltage_sweep(res_kp, 'k_p', '', ...
                   'V(t) skirtingoms k_p reikšmėms');
if SAVE_FIGURES, save_figure(SAVE_PATH, '16_V_k_p'); end
plot_Qeff_vs_kp(res_kp);
if SAVE_FIGURES, save_figure(SAVE_PATH, '17_Qeff_vs_kp'); end
fprintf('\n');

% --- 9.5. Iškrovos srovės įtaka ---
fprintf('[9.5] Tiriama iškrovos srovės I įtaka (%d reikšmės)...\n', numel(I_values));
res_I = run_param_sweep(p, 'I', I_values, NaN, V_cutoff);
plot_voltage_sweep(res_I, 'I', 'A', ...
                   'V(t) skirtingoms iškrovos srovėms');
if SAVE_FIGURES, save_figure(SAVE_PATH, '18_V_I'); end
plot_Qeff_vs_Crate(res_I, p);
if SAVE_FIGURES, save_figure(SAVE_PATH, '19_Qeff_vs_Crate'); end
fprintf('\n');

% --- 9.6. Apibendrinimas ---
fprintf('[9.6] Apibendrinantis grafikas...\n');
plot_consolidated_results(res_Ds, res_R0_sweep, res_kp, res_I);
if SAVE_FIGURES, save_figure(SAVE_PATH, '20_apibendrinimas'); end

% ===================================================================
fprintf('\n=================================================\n');
fprintf('  Simuliacija baigta.\n');
fprintf('  Sugeneruoti grafikai:\n');
fprintf('    2 skyrius: 1, 2 pav., OCV palyginimas, 3, 4, 5, 6 pav.\n');
fprintf('    3 skyrius: 12, 13, 14, 15, 16, 17, 18 pav.\n');
if SAVE_FIGURES
    fprintf('  Grafikai išsaugoti į: %s\n', SAVE_PATH);
end
fprintf('=================================================\n');