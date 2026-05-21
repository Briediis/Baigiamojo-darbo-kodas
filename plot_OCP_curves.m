function plot_OCP_curves(p)
% PLOT_OCP_CURVES  Atviros grandinės potencialo kreivės.
%
% Trys panelės:
%
%   (a) Teigiamo elektrodo (LCO) OCP – U_p(x_p). Įtampa kinta nuo
%       ~4,4 V (x_p → 0) iki ~3,6 V (x_p → 1). Žalia zona žymi
%       naudojamą darbo stoichiometrijos diapazoną.
%
%   (b) Neigiamo elektrodo (grafito MCMB) OCP – U_n(x_n). Įtampa
%       sparčiai kyla artėjant x_n prie 0 – tai sukelia staigų
%       gnybtų įtampos kritimą iškrovos pabaigoje.
%
%   (c) Celės OCV-SOC charakteristika – skirtumas U_p - U_n kaip
%       SOC funkcija. LCO/grafito celės pasižymi monotoniškai
%       kintančia kreive (nuo ~3,0 V iki ~4,1 V), skirtingai nei
%       LFP celės su plokščia vidurine sritimi.
%
% Įvestis:
%   p - parametrų struktūra su x_p_0, x_p_100, x_n_0, x_n_100

    fs_axis  = 10;
    fs_label = 11;
    fs_title = 11;
    fs_super = 12;
    lw_curve = 1.6;
    lw_bound = 0.8;

    figure('Name', '6 pav. Atviros grandinės potencialo kreivės', ...
           'Color', 'w', 'Position', [120 120 1300 420]);

    %% --- (a) Teigiamas elektrodas (LCO) ---
    subplot(1, 3, 1);
    xp_range = linspace(p.x_p_100 - 0.05, min(p.x_p_0 + 0.01, 0.99), 500);
    Up = arrayfun(@OCP_pos, xp_range);

    ylims_a = [3.5, 4.4];

    % Žalia zona: naudojamas darbo stoichiometrijos diapazonas
    h_zone = fill([p.x_p_100 p.x_p_0 p.x_p_0 p.x_p_100], ...
                  [ylims_a(1) ylims_a(1) ylims_a(2) ylims_a(2)], ...
                  [0.7 0.95 0.7], 'EdgeColor', 'none', 'FaceAlpha', 0.25);
    hold on;
    h_curve = plot(xp_range, Up, 'r-', 'LineWidth', lw_curve);
    plot([p.x_p_100 p.x_p_100], ylims_a, 'k--', 'LineWidth', lw_bound);
    plot([p.x_p_0   p.x_p_0  ], ylims_a, 'k--', 'LineWidth', lw_bound);

    grid on; box on;
    xlabel('x_p = c_{s,surf,p} / c_{s,max,p}', 'FontSize', fs_label);
    ylabel('U_p (V vs. Li/Li^+)',              'FontSize', fs_label);
    title('(a) LCO teigiamas elektrodas',      'FontSize', fs_title);
    ylim(ylims_a);
    set(gca, 'FontSize', fs_axis);
    legend([h_curve, h_zone], {'U_p(x_p)', 'Darbo diapazonas'}, ...
           'Location', 'northeast', 'FontSize', fs_axis);

    %% --- (b) Neigiamas elektrodas (grafitas MCMB) ---
    % Sparčiai augantis U_n artėjant x_n prie 0 yra pagrindinė
    % priežastis staigiam gnybtų įtampos kritimui iškrovos pabaigoje.
    subplot(1, 3, 2);
    xn_range = linspace(max(p.x_n_0 - 0.01, 0.005), p.x_n_100 + 0.05, 500);
    Un = arrayfun(@OCP_neg, xn_range);

    ylims_b = [0, 1.2];

    h_zone = fill([p.x_n_0 p.x_n_100 p.x_n_100 p.x_n_0], ...
                  [ylims_b(1) ylims_b(1) ylims_b(2) ylims_b(2)], ...
                  [0.7 0.95 0.7], 'EdgeColor', 'none', 'FaceAlpha', 0.25);
    hold on;
    h_curve = plot(xn_range, Un, 'b-', 'LineWidth', lw_curve);
    plot([p.x_n_0   p.x_n_0  ], ylims_b, 'k--', 'LineWidth', lw_bound);
    plot([p.x_n_100 p.x_n_100], ylims_b, 'k--', 'LineWidth', lw_bound);

    grid on; box on;
    xlabel('x_n = c_{s,surf,n} / c_{s,max,n}',  'FontSize', fs_label);
    ylabel('U_n (V vs. Li/Li^+)',               'FontSize', fs_label);
    title('(b) Grafito (MCMB) neigiamas el.',   'FontSize', fs_title);
    ylim(ylims_b);
    set(gca, 'FontSize', fs_axis);
    legend([h_curve, h_zone], {'U_n(x_n)', 'Darbo diapazonas'}, ...
           'Location', 'northeast', 'FontSize', fs_axis);

    %% --- (c) Celės OCV-SOC charakteristika ---
    subplot(1, 3, 3);
    SOC = linspace(0, 1, 200);
    xp_soc = p.x_p_0 + SOC * (p.x_p_100 - p.x_p_0);
    xn_soc = p.x_n_0 + SOC * (p.x_n_100 - p.x_n_0);
    OCV = arrayfun(@OCP_pos, xp_soc) - arrayfun(@OCP_neg, xn_soc);

    plot(SOC * 100, OCV, 'k-', 'LineWidth', lw_curve);
    grid on; box on;
    xlabel('SOC (%)',                          'FontSize', fs_label);
    ylabel('OCV (V)',                          'FontSize', fs_label);
    title('(c) Celės OCV–SOC charakteristika', 'FontSize', fs_title);
    ylim([2.8, 4.3]);
    xlim([0, 100]);
    set(gca, 'FontSize', fs_axis);

    sgtitle('Atviros grandinės potencialo kreivės', ...
            'FontSize', fs_super, 'FontWeight', 'bold');
end
