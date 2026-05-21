function plot_OCV_comparison(p_guo, p_fit)
% PLOT_OCV_COMPARISON  OCV-SOC charakteristikos palyginimas prieš ir po
%                      parametrų identifikavimo.
%
% Atvaizduoja dvi celės atviros grandinės įtampos kreives:
%   - mėlyna ištisinė linija: originalūs Guo et al. (2011) parametrai
%   - raudona brūkšninė linija: parametrai pritaikyti NASA B0005 celei
%
% Kreivių skirtumą sukelia optimizuotos pradinės stoichiometrijos
% x_ini_p ir x_ini_n, kurios nusako, kurį OCP kreivės segmentą
% atitinka celės darbo diapazonas. Ribinės reikšmės x_p_0 ir x_n_0
% (pilnai iškrautos celės) išlieka nepakitusios.
%
% Įvestis:
%   p_guo - originalūs Guo et al. (2011) parametrai (kopija prieš
%           atnaujinant)
%   p_fit - parametrai po identifikavimo (su fit.x_ini_p, fit.x_ini_n)

    figure('Name', 'OCV-SOC palyginimas: Guo vs pritaikyti', ...
           'Color', 'w', 'Position', [150 150 760 440]);

    SOC = linspace(0, 1, 1001);

    % OCV kreivė su originaliais Guo et al. (2011) parametrais.
    % Stoichiometrija kinta tiesiškai tarp x_*_0 ir x_*_100.
    xp_guo = p_guo.x_p_0 + SOC * (p_guo.x_p_100 - p_guo.x_p_0);
    xn_guo = p_guo.x_n_0 + SOC * (p_guo.x_n_100 - p_guo.x_n_0);
    OCV_guo = arrayfun(@OCP_pos, xp_guo) - arrayfun(@OCP_neg, xn_guo);

    % OCV kreivė su identifikuotais B0005 celės parametrais.
    xp_fit = p_fit.x_p_0 + SOC * (p_fit.x_p_100 - p_fit.x_p_0);
    xn_fit = p_fit.x_n_0 + SOC * (p_fit.x_n_100 - p_fit.x_n_0);
    OCV_fit = arrayfun(@OCP_pos, xp_fit) - arrayfun(@OCP_neg, xn_fit);

    plot(SOC * 100, OCV_guo, 'b-',  'LineWidth', 1.6); hold on;
    plot(SOC * 100, OCV_fit, 'r--', 'LineWidth', 1.6);
    yline(2.7, ':k', 'V_{min} = 2.7 V', 'LabelHorizontalAlignment', 'left', ...
          'Alpha', 0.4);
    yline(4.2, ':k', 'V_{max} = 4.2 V', 'LabelHorizontalAlignment', 'left', ...
          'Alpha', 0.4);

    grid on; box on;
    xlabel('SOC (%)');
    ylabel('OCV (V)');
    title('Celės OCV–SOC charakteristika: originalūs vs pritaikyti parametrai');
    legend({sprintf('Guo et al. (2011):  x_{ini,p}=%.4f, x_{ini,n}=%.4f', ...
                    p_guo.x_ini_p, p_guo.x_ini_n), ...
            sprintf('Pritaikyti B0005: x_{ini,p}=%.4f, x_{ini,n}=%.4f', ...
                    p_fit.x_ini_p, p_fit.x_ini_n)}, ...
           'Location', 'southeast');
    xlim([0 100]); ylim([2.5 4.3]);

    % Diagnostinė išvestis: maksimalus skirtumas tarp kreivių
    [maxDiff, idxMax] = max(abs(OCV_guo - OCV_fit));
    fprintf('    OCV-SOC palyginimas: max skirtumas = %.1f mV (esant SOC = %.0f%%)\n', ...
            maxDiff * 1000, SOC(idxMax) * 100);
    fprintf('    SOC = 100%%: Guo = %.3f V,  Pritaikyta = %.3f V\n', ...
            OCV_guo(end), OCV_fit(end));
    fprintf('    SOC =   0%%: Guo = %.3f V,  Pritaikyta = %.3f V\n', ...
            OCV_guo(1), OCV_fit(1));
end
